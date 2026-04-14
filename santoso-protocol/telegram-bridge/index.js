/**
 * Santoso Telegram Bridge
 *
 * Connects the Gunawan HQ Telegram group to Paperclip (Santoso).
 * - Receives messages from Telegram → creates Paperclip issues
 * - Receives Paperclip agent updates → posts to Telegram group
 *
 * Ports:
 *   3200 — this bridge (does not conflict with Paperclip:3100 or Next.js:3000)
 */

const express = require('express');
const app = express();

app.use(express.json());

// ---------------------------------------------------------------------------
// Environment
// ---------------------------------------------------------------------------

const {
  TELEGRAM_BOT_TOKEN,
  TELEGRAM_CHAT_ID,
  PAPERCLIP_API_URL = 'http://localhost:3100',
  WEBHOOK_URL,
  PORT = 3200,
} = process.env;

function requireEnv(name) {
  if (!process.env[name]) {
    console.error(`[bridge] Missing required environment variable: ${name}`);
    process.exit(1);
  }
}

requireEnv('TELEGRAM_BOT_TOKEN');
requireEnv('TELEGRAM_CHAT_ID');

const TELEGRAM_API = `https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}`;

// ---------------------------------------------------------------------------
// Paperclip integration
// ---------------------------------------------------------------------------

/**
 * Creates a Paperclip issue from a Telegram message.
 * The issue title is the first line of the message; body is the full text.
 */
async function createPaperclipIssue(text, fromUsername) {
  const fetch = (await import('node-fetch')).default;

  const title = text.split('\n')[0].slice(0, 120);
  const body = `From Telegram (@${fromUsername || 'unknown'}):\n\n${text}`;

  try {
    const response = await fetch(`${PAPERCLIP_API_URL}/api/issues`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ title, body }),
    });

    if (!response.ok) {
      const err = await response.text();
      console.error('[bridge] Paperclip issue creation failed:', response.status, err);
      return null;
    }

    const issue = await response.json();
    console.log(`[bridge] Created Paperclip issue #${issue.id}: ${title}`);
    return issue;
  } catch (err) {
    console.error('[bridge] Error creating Paperclip issue:', err.message);
    return null;
  }
}

// ---------------------------------------------------------------------------
// Telegram integration
// ---------------------------------------------------------------------------

/**
 * Sends a message to the Gunawan HQ Telegram group.
 */
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

/**
 * Registers this server as the Telegram webhook.
 * Called once on startup if WEBHOOK_URL is set.
 */
async function registerWebhook() {
  if (!WEBHOOK_URL) {
    console.warn('[bridge] WEBHOOK_URL not set — skipping webhook registration.');
    console.warn('[bridge] Set WEBHOOK_URL to your ngrok/domain URL and restart.');
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

/**
 * POST /telegram/webhook
 * Receives updates from Telegram.
 * Creates a Paperclip issue for each text message from the group.
 */
app.post('/telegram/webhook', async (req, res) => {
  res.sendStatus(200); // Acknowledge immediately — Telegram requires fast response

  const update = req.body;

  // Only handle text messages from the configured chat
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

  // Create Paperclip issue
  const issue = await createPaperclipIssue(text, fromUsername);

  // Acknowledge back to Telegram
  if (issue) {
    await sendTelegramMessage(
      `✅ Santoso received your message.\nPaperclip issue *#${issue.id}* created: _${issue.title}_`
    );
  } else {
    await sendTelegramMessage(
      `⚠️ Santoso received your message but could not create a Paperclip issue. Is Paperclip running at ${PAPERCLIP_API_URL}?`
    );
  }
});

/**
 * POST /notify
 * Called by Paperclip agents to post updates back to Telegram.
 * Payload: { text: string }
 */
app.post('/notify', async (req, res) => {
  const { text } = req.body;
  if (!text) {
    return res.status(400).json({ error: 'text is required' });
  }

  const success = await sendTelegramMessage(text);
  res.json({ success });
});

/**
 * GET /health
 * Health check — used by Docker, Alpha's deployment verification, and verify-setup.sh
 */
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    service: 'santoso-telegram-bridge',
    paperclip_url: PAPERCLIP_API_URL,
    webhook_url: WEBHOOK_URL || 'not set',
    telegram_chat_configured: !!TELEGRAM_CHAT_ID,
  });
});

// ---------------------------------------------------------------------------
// Start
// ---------------------------------------------------------------------------

app.listen(PORT, async () => {
  console.log(`[bridge] Santoso Telegram Bridge running on port ${PORT}`);
  console.log(`[bridge] Paperclip API: ${PAPERCLIP_API_URL}`);
  console.log(`[bridge] Health check: http://localhost:${PORT}/health`);
  await registerWebhook();
});
