/**
 * Santoso Telegram Bridge
 *
 * Connects the Gunawan HQ Telegram group to Paperclip (Santoso).
 * - Receives Telegram messages → creates Paperclip issues, wakes Santoso
 * - Receives /notify calls from agents inside the cluster → posts to Telegram
 * - Speaks briefly on Santoso's behalf (in voice) when:
 *     1. A new Telegram message arrives (RECEIPT) and Santoso hasn't replied yet
 *     2. 45 seconds pass without Santoso calling /notify (HEARTBEAT fallback)
 * - Throttles bursts of /notify calls into a single Telegram message (3s window)
 *
 * Ports:
 *   3200 — this bridge
 */

const express = require('express');
const voice = require('./lib/voice');

const app = express();
app.use(express.json());

// ---------------------------------------------------------------------------
// Environment
// ---------------------------------------------------------------------------

const {
  TELEGRAM_BOT_TOKEN,
  TELEGRAM_CHAT_ID,
  PAPERCLIP_API_URL = 'http://localhost:3100',
  PAPERCLIP_COMPANY_ID,
  PAPERCLIP_CEO_AGENT_ID,
  WEBHOOK_URL,
  PORT = 3200,
} = process.env;

const HEARTBEAT_FALLBACK_MS = parseInt(process.env.BRIDGE_HEARTBEAT_FALLBACK_MS || '45000', 10);
const THROTTLE_WINDOW_MS = parseInt(process.env.BRIDGE_THROTTLE_WINDOW_MS || '3000', 10);

function requireEnv(name) {
  if (!process.env[name]) {
    console.error(`[bridge] Missing required environment variable: ${name}`);
    process.exit(1);
  }
}

requireEnv('TELEGRAM_BOT_TOKEN');
requireEnv('TELEGRAM_CHAT_ID');
requireEnv('PAPERCLIP_COMPANY_ID');
requireEnv('PAPERCLIP_CEO_AGENT_ID');

const TELEGRAM_API = `https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}`;

// ---------------------------------------------------------------------------
// Conversation state (in-memory — single replica is fine for now)
// ---------------------------------------------------------------------------
//
// Tracks "is Santoso supposed to be working on something but hasn't replied
// yet?" per Telegram chat. We use this to fire the heartbeat fallback.

const activeTasks = new Map(); // chatId -> { startedAt, heartbeatTimer, issueId }

function startTask(chatId, issueId) {
  cancelTask(chatId);
  const timer = setTimeout(() => fireHeartbeat(chatId), HEARTBEAT_FALLBACK_MS);
  activeTasks.set(chatId, { startedAt: Date.now(), heartbeatTimer: timer, issueId });
}

function cancelTask(chatId) {
  const t = activeTasks.get(chatId);
  if (t) {
    clearTimeout(t.heartbeatTimer);
    activeTasks.delete(chatId);
  }
}

async function fireHeartbeat(chatId) {
  // Santoso hasn't called /notify in HEARTBEAT_FALLBACK_MS. Post a "still
  // working" beat citing whichever agent is in runtime-state, if any.
  const t = activeTasks.get(chatId);
  if (!t) return;

  const agentName = await getRunningAgentName();
  const beat = voice.heartbeat(agentName);
  console.log(`[bridge] heartbeat fallback (chat=${chatId}) -> ${beat}`);
  await sendTelegramMessage(beat);

  // Reschedule the heartbeat in case Santoso is still grinding. Cap at 3
  // total heartbeats per task to avoid infinite chatter.
  t.heartbeatCount = (t.heartbeatCount || 0) + 1;
  if (t.heartbeatCount < 3) {
    t.heartbeatTimer = setTimeout(() => fireHeartbeat(chatId), HEARTBEAT_FALLBACK_MS);
    activeTasks.set(chatId, t);
  } else {
    activeTasks.delete(chatId);
  }
}

async function getRunningAgentName() {
  // Query Paperclip for whichever agent is currently "running" in the
  // company. If multiple are running, pick the most recently updated one.
  // If none are running, return null and the heartbeat goes generic.
  try {
    const fetch = (await import('node-fetch')).default;
    const res = await fetch(
      `${PAPERCLIP_API_URL}/api/companies/${PAPERCLIP_COMPANY_ID}/agents`
    );
    if (!res.ok) return null;
    const agents = await res.json();
    const running = agents.filter((a) => a.status === 'running' || a.status === 'busy');
    if (running.length === 0) return null;
    running.sort((a, b) => (b.updatedAt || '').localeCompare(a.updatedAt || ''));
    return running[0].name;
  } catch (e) {
    console.warn('[bridge] runtime-state query failed:', e.message);
    return null;
  }
}

// ---------------------------------------------------------------------------
// Notify throttle / merge — coalesce bursts of /notify into one Telegram msg
// ---------------------------------------------------------------------------

let pendingBeats = [];
let pendingFlushTimer = null;

function queueBeat(text) {
  pendingBeats.push(text);
  if (pendingFlushTimer) return; // already scheduled
  pendingFlushTimer = setTimeout(flushBeats, THROTTLE_WINDOW_MS);
}

async function flushBeats() {
  pendingFlushTimer = null;
  if (pendingBeats.length === 0) return;
  const merged = pendingBeats.join('\n');
  pendingBeats = [];
  await sendTelegramMessage(merged);
}

// ---------------------------------------------------------------------------
// Paperclip integration
// ---------------------------------------------------------------------------

async function createPaperclipIssue(text, fromUsername) {
  const fetch = (await import('node-fetch')).default;

  const title = text.split('\n')[0].slice(0, 120);
  const description = `From Telegram (@${fromUsername || 'unknown'}):\n\n${text}`;
  const url = `${PAPERCLIP_API_URL}/api/companies/${PAPERCLIP_COMPANY_ID}/issues`;

  try {
    const response = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        title,
        description,
        assigneeAgentId: PAPERCLIP_CEO_AGENT_ID,
        // inbox-lite filters by status ∈ {todo, in_progress, blocked};
        // backlog (the default) would never be seen by Santoso's inbox poll.
        status: 'todo',
        priority: 'high',
      }),
    });

    if (!response.ok) {
      const err = await response.text();
      console.error('[bridge] Paperclip issue creation failed:', response.status, err);
      return null;
    }

    const issue = await response.json();
    const shortId = issue.shortId || issue.id;
    console.log(`[bridge] Created Paperclip issue ${shortId}: ${title}`);

    // Wake Santoso so he picks up the issue immediately.
    // Use the new issue id as the idempotency key so Paperclip doesn't spawn
    // duplicate runs for the same message.
    try {
      const wakeRes = await fetch(
        `${PAPERCLIP_API_URL}/api/agents/${PAPERCLIP_CEO_AGENT_ID}/wakeup`,
        {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            source: 'assignment',
            triggerDetail: 'callback',
            reason: `New Telegram message: ${title.slice(0, 80)}`,
            idempotencyKey: `telegram-msg-${issue.id}`,
            payload: { issueId: issue.id },
          }),
        }
      );
      if (!wakeRes.ok) {
        console.warn('[bridge] Santoso wakeup failed:', wakeRes.status, await wakeRes.text());
      } else {
        console.log('[bridge] Santoso wakeup requested.');
      }
    } catch (wakeErr) {
      console.warn('[bridge] Error waking Santoso:', wakeErr.message);
    }

    return { ...issue, displayId: shortId };
  } catch (err) {
    console.error('[bridge] Error creating Paperclip issue:', err.message);
    return null;
  }
}

// ---------------------------------------------------------------------------
// Telegram sender
// ---------------------------------------------------------------------------

async function sendTelegramMessage(text) {
  const fetch = (await import('node-fetch')).default;
  try {
    const response = await fetch(`${TELEGRAM_API}/sendMessage`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        chat_id: TELEGRAM_CHAT_ID,
        text,
        parse_mode: 'Markdown',
      }),
    });
    if (!response.ok) {
      const err = await response.text();
      console.error('[bridge] Telegram send failed:', response.status, err);
      return false;
    }
    console.log('[bridge] Telegram message sent.');
    return true;
  } catch (err) {
    console.error('[bridge] Error sending Telegram message:', err.message);
    return false;
  }
}

async function registerWebhook() {
  if (!WEBHOOK_URL) {
    console.warn('[bridge] WEBHOOK_URL not set — skipping webhook registration.');
    return;
  }
  const fetch = (await import('node-fetch')).default;
  const webhookEndpoint = `${WEBHOOK_URL}/telegram/webhook`;
  try {
    const response = await fetch(`${TELEGRAM_API}/setWebhook`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ url: webhookEndpoint }),
    });
    const result = await response.json();
    if (result.ok) {
      console.log(`[bridge] Telegram webhook registered: ${webhookEndpoint}`);
    } else {
      console.error('[bridge] Webhook registration failed:', result.description);
    }
  } catch (err) {
    console.error('[bridge] Error registering webhook:', err.message);
  }
}

// ---------------------------------------------------------------------------
// Routes
// ---------------------------------------------------------------------------

app.post('/telegram/webhook', async (req, res) => {
  res.sendStatus(200); // Telegram requires a fast 200

  const update = req.body;
  const message = update.message || update.channel_post;
  if (!message || !message.text) return;

  const chatId = String(message.chat.id);
  if (chatId !== String(TELEGRAM_CHAT_ID)) {
    console.log(`[bridge] Ignored message from chat ${chatId} (not Gunawan HQ)`);
    return;
  }

  const text = message.text;
  const fromUsername = message.from?.username;

  console.log(`[bridge] Received from @${fromUsername}: ${text.slice(0, 80)}...`);

  // STEP 1 — instant in-character RECEIPT beat (before we even create the issue)
  // The user should see the bridge talking back within ~1 second.
  await sendTelegramMessage(voice.receipt());

  // STEP 2 — create the Paperclip issue + wake Santoso
  const issue = await createPaperclipIssue(text, fromUsername);

  if (!issue) {
    await sendTelegramMessage(
      `⚠️ I heard you, but the Paperclip API choked. Boss, check the bridge logs.`
    );
    return;
  }

  // STEP 3 — start a heartbeat watchdog. If Santoso doesn't /notify within 45s,
  // the bridge auto-posts a "still working, X is up" beat.
  startTask(chatId, issue.id || issue.displayId);
});

app.post('/notify', async (req, res) => {
  const { text } = req.body;
  if (!text) {
    return res.status(400).json({ error: 'text is required' });
  }

  // Santoso is alive and talking — cancel any pending heartbeat for this chat.
  // (We only have one chat for now.)
  cancelTask(String(TELEGRAM_CHAT_ID));

  // Throttle: queue the beat and let the flush timer merge bursts.
  queueBeat(text);

  res.json({ success: true, queued: true });
});

app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    service: 'santoso-telegram-bridge',
    paperclip_url: PAPERCLIP_API_URL,
    webhook_url: WEBHOOK_URL || 'not set',
    telegram_chat_configured: !!TELEGRAM_CHAT_ID,
    active_tasks: activeTasks.size,
    pending_beats: pendingBeats.length,
    config: {
      heartbeat_fallback_ms: HEARTBEAT_FALLBACK_MS,
      throttle_window_ms: THROTTLE_WINDOW_MS,
    },
  });
});

app.listen(PORT, async () => {
  console.log(`[bridge] Santoso Telegram Bridge running on port ${PORT}`);
  console.log(`[bridge] Paperclip API: ${PAPERCLIP_API_URL}`);
  console.log(`[bridge] Heartbeat fallback: ${HEARTBEAT_FALLBACK_MS}ms`);
  console.log(`[bridge] Throttle window: ${THROTTLE_WINDOW_MS}ms`);
  console.log(`[bridge] Health check: http://localhost:${PORT}/health`);
  await registerWebhook();
});
