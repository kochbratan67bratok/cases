import { readFileSync } from "node:fs";
import { spawnSync } from "node:child_process";
import assert from "node:assert/strict";

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
check(/function attemptContract\s*\(/.test(html), "contract flow exists");
check(/function initYandex\s*\(/.test(html), "Yandex Games SDK initialization exists");
check(/function save\s*\(/.test(html) && /function loadState\s*\(/.test(html), "save/load functions exist");
check(/localStorage/.test(html), "local persistence is implemented");
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

console.log("\nStatic smoke checks passed. These checks do not replace browser or Yandex Games SDK testing.");
