/**
 * Santoso voice fragments — used by the bridge for in-character receipts
 * and heartbeat fallbacks. These are NOT the agent's own outputs; they're
 * the bridge speaking briefly on Santoso's behalf when:
 *
 *   1. A Telegram message just arrived (RECEIPT) and Santoso hasn't woken
 *      yet — we want the user to know we heard them within ~1s.
 *   2. 45 seconds have passed since receipt and Santoso still hasn't
 *      called /notify (HEARTBEAT) — we want to keep the user informed
 *      without spamming.
 *
 * Voice rules (from .claude/voice/santoso.md):
 *   - Terse. <60 chars per line.
 *   - In character. Never robotic ("Processing your request").
 *   - Anticipatory or grounding, never apologetic.
 *   - Occasional Indonesian touches ("Boleh, boss" / "Siap").
 *   - No emojis, no exclamation marks, no "Sure thing!" energy.
 */

const RECEIPTS = [
  "Boss. On it.",
  "Noted. Reading now.",
  "Got you. Standing up the team.",
  "Mm. Let me look.",
  "Boleh, boss — pulling context.",
  "Siap. One sec.",
  "Reading.",
  "On it.",
  "Heard. Working.",
  "Right. Pulling memory.",
];

const HEARTBEATS = [
  "Still on it. {agent} is up.",
  "Working — {agent} is mid-think.",
  "Holding for {agent} to finish.",
  "Mm. {agent} hasn't blinked yet. Standing by.",
  "Patience, boss — {agent} is on it.",
];

const HEARTBEATS_NO_AGENT = [
  "Still on it.",
  "Working.",
  "Mm. Give me another beat.",
  "Reading and routing. Standing by.",
];

function pick(arr) {
  return arr[Math.floor(Math.random() * arr.length)];
}

/**
 * Return one in-character receipt line.
 */
function receipt() {
  return pick(RECEIPTS);
}

/**
 * Return one in-character heartbeat line. If `agentName` is provided,
 * prefer the agent-aware fragment; otherwise fall back to a generic one.
 */
function heartbeat(agentName) {
  if (agentName && agentName.length > 0) {
    return pick(HEARTBEATS).replace("{agent}", agentName);
  }
  return pick(HEARTBEATS_NO_AGENT);
}

module.exports = { receipt, heartbeat };
