import { readFileSync } from "node:fs";
import { spawnSync } from "node:child_process";
import assert from "node:assert/strict";
import vm from "node:vm";

const html = readFileSync(new URL("../index.html", import.meta.url), "utf8");

function check(condition, message) {
  assert.ok(condition, message);
  console.log(`✓ ${message}`);
}

check(/<!doctype html>/i.test(html), "HTML document has a doctype");
check(/<meta name="viewport"/i.test(html), "mobile viewport is configured");
check(/id="fullscreenToggle"/.test(html), "fullscreen control exists");
check(/function openCase\s*\(/.test(html), "case-opening flow exists");
check(/function renderInventory\s*\(/.test(html), "inventory renderer exists");
check(/function attemptUpgrade\s*\(/.test(html), "upgrade flow exists");
check(/id="upgradeDial"/.test(html) && /id="upgradeDialNeedle"/.test(html), "CS2-style upgrade chance wheel exists");
check(/data-upgrade-multiplier="1\.5"/.test(html) && /data-upgrade-multiplier="10"/.test(html), "upgrade multipliers x1 through x10 including x1.5 are available");
check(/function catalogSkinPrice\s*\(/.test(html) && /function catalogCasePrice\s*\(/.test(html), "catalog skins and containers receive deterministic individual prices");
check(/caseLab\.catalog\.cache\.v4/.test(html) && /priceByName\.get\(item\.name\)/.test(html), "cached catalog is refreshed and saved inventory prices are migrated");
check(/id="loadMoreCases"/.test(html) && /caseVisibleCount=24/.test(html), "case feed renders in batches to reduce scrolling load");

check(/function attemptContract\s*\(/.test(html), "contract flow exists");
check(/function initYandex\s*\(/.test(html), "Yandex Games SDK initialization exists");
check(/game_api_pause/.test(html) && /game_api_resume/.test(html), "Yandex Games pause/resume events are handled");
check(/function stopAllSounds\s*\(/.test(html), "audio can be stopped when the game loses focus");
check(/function save\s*\(/.test(html) && /function loadState\s*\(/.test(html), "save/load functions exist");
check(/function normalizeState\s*\(/.test(html), "local and cloud saves are normalized before use");
check(/localStorage/.test(html), "local persistence is implemented");
check(/state\.coins===freshState\(\)\.coins/.test(html), "cloud save restore matches the actual fresh-state balance");
check(/prefers-reduced-motion/.test(html), "reduced-motion preference is respected");
check(/ArrowLeft/.test(html) && /ArrowRight/.test(html) && /ArrowUp/.test(html) && /ArrowDown/.test(html), "TV remote arrow-key navigation is present");

const inlineScripts = [...html.matchAll(/<script(?![^>]*\bsrc=)[^>]*>([\s\S]*?)<\/script>/gi)];
assert.ok(inlineScripts.length > 0, "at least one inline script exists");
for (const [index, match] of inlineScripts.entries()) {
  const result = spawnSync(process.execPath, ["--check"], {
    input: match[1],
    encoding: "utf8",
  });
  assert.equal(
    result.status,
    0,
    `inline script ${index + 1} has valid JavaScript syntax\n${result.stderr || ""}`,
  );
  console.log(`✓ inline script ${index + 1} has valid JavaScript syntax`);
}

const stateBlock = html.match(/function freshState\([\s\S]*?let state=loadState\(\);/);
assert.ok(stateBlock, "state initialization block can be isolated for logic tests");
const sandbox = { localStorage: { getItem: () => null } };
sandbox.globalThis = sandbox;
vm.runInNewContext(stateBlock[0] + "\nglobalThis.__normalizeState = normalizeState;", sandbox);
const normalizeState = sandbox.__normalizeState;
const normalized = normalizeState({
  coins: -20,
  xp: "invalid",
  opens: 4,
  inventory: [null, { uid: "broken" }, { uid: "ok", name: "Test item", value: "45" }],
  claimedPass: [1, 1, 31, "2"],
  missionClaims: ["open3", 7, "open3"],
});
assert.equal(normalized.coins, 0, "negative credits are clamped");
assert.equal(normalized.xp, 0, "invalid XP falls back safely");
assert.equal(normalized.inventory.length, 1, "malformed inventory entries are discarded");
assert.equal(normalized.inventory[0].value, 45, "inventory values are normalized to numbers");
assert.deepEqual(Array.from(normalized.claimedPass), [1], "battle-pass claims are deduplicated and bounded");
assert.deepEqual(Array.from(normalized.missionClaims), ["open3"], "mission claims are deduplicated and type-checked");
console.log("✓ saved-state normalization logic tests passed");

console.log("\nStatic smoke checks passed. These checks do not replace browser or Yandex Games SDK testing.");
