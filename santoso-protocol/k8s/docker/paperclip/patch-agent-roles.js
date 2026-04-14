#!/usr/bin/env node
/*
 * Bakes the AGENT_ROLES enum patches into the globally-installed paperclipai
 * package so they survive image rebuilds. Idempotent — safe to run twice.
 *
 * Adds `analyst` and `marketing` to:
 *   - dist/index.js                                        (CLI bundle)
 *   - node_modules/@paperclipai/shared/dist/constants.js   (server validator)
 *
 * Also adds the matching entries to AGENT_ROLE_LABELS in constants.js so the
 * dashboard renders "Analyst" / "Marketing" instead of the raw enum key.
 *
 * Exits non-zero if any anchor is missing — that signals the upstream package
 * changed shape and the patch needs updating.
 */

const fs = require('node:fs');
const path = require('node:path');

const PKG_ROOT = '/usr/local/lib/node_modules/paperclipai';
const CLI_BUNDLE = path.join(PKG_ROOT, 'dist/index.js');
const SHARED_CONSTS = path.join(
  PKG_ROOT,
  'node_modules/@paperclipai/shared/dist/constants.js'
);

function patchFile(file, transforms) {
  if (!fs.existsSync(file)) {
    console.error(`[patch] missing: ${file}`);
    process.exit(1);
  }
  let src = fs.readFileSync(file, 'utf8');
  let changed = false;
  for (const { name, anchor, replacement, skipIf } of transforms) {
    if (skipIf && skipIf.test(src)) {
      console.log(`[patch] ${path.basename(file)}: ${name} already applied`);
      continue;
    }
    if (!anchor.test(src)) {
      console.error(
        `[patch] ${path.basename(file)}: anchor "${name}" not found — upstream changed?`
      );
      process.exit(1);
    }
    src = src.replace(anchor, replacement);
    changed = true;
    console.log(`[patch] ${path.basename(file)}: applied ${name}`);
  }
  if (changed) fs.writeFileSync(file, src);
}

// --- CLI bundle: splice analyst + marketing into AGENT_ROLES ---
patchFile(CLI_BUNDLE, [
  {
    name: 'AGENT_ROLES (cli)',
    skipIf: /AGENT_ROLES = \[[^\]]*"analyst"/,
    anchor: /("researcher",)(\s*)("general")/,
    replacement: '$1$2"analyst",$2"marketing",$2$3',
  },
]);

// --- Shared constants: splice into AGENT_ROLES and AGENT_ROLE_LABELS ---
patchFile(SHARED_CONSTS, [
  {
    name: 'AGENT_ROLES (shared)',
    skipIf: /AGENT_ROLES = \[[^\]]*"analyst"/,
    anchor: /("researcher",)(\s*)("general",)/,
    replacement: '$1$2"analyst",$2"marketing",$2$3',
  },
  {
    name: 'AGENT_ROLE_LABELS',
    skipIf: /AGENT_ROLE_LABELS = \{[^}]*analyst:/,
    anchor: /(researcher: "Researcher",)(\s*)(general: "General",)/,
    replacement: '$1$2analyst: "Analyst",$2marketing: "Marketing",$2$3',
  },
]);

console.log('[patch] done');
