# CASE LAB — production-readiness checklist

This checklist distinguishes automated checks from tests that must be run in the Yandex Games Developer Console or on real devices.

## Automated checks

- [x] Parse the inline JavaScript for syntax errors.
- [x] Check that the core game flows and SDK hooks are present.
- [x] Check the save/load implementation and cloud-restore guard.
- [x] Check keyboard navigation for TV-style directional input.
- [x] Run smoke checks in GitHub Actions on pushes and pull requests.

## Required manual checks before release

### Core game
- [ ] Open every built-in case and capsule; verify the roulette finishes and exactly one item is awarded.
- [ ] Confirm insufficient-credit actions do not consume credits or change inventory.
- [ ] Sell one item and all items; verify the credited amounts and inventory count.
- [ ] Complete an upgrade successfully and unsuccessfully; verify the source item is consumed exactly once.
- [ ] Check upgrade multipliers x1, x1.5, x2–x10, selected target price, displayed success chance, wheel result colors, and success/failure inventory changes.
- [ ] Scroll through the case/capsule catalog on a phone; verify 24-item batches remain responsive and “show more” appends the next batch.
- [ ] Verify skin and catalog-container prices are stable after reload and differ by item.
- [ ] Complete a five-item contract with matching rarity; verify invalid selections are rejected and items are not duplicated.
- [ ] Claim each mission and battle-pass reward once; verify locked or already-claimed rewards cannot be claimed.
- [ ] Claim the daily reward, reload, and confirm it cannot be claimed twice on the same local date.

### Persistence
- [ ] Reload after changing credits and inventory; verify local save restoration.
- [ ] Test with browser storage blocked or full; the game should remain playable and show no fatal error.
- [ ] In Yandex Games preview, verify cloud save restore on a fresh session and after a later session.
- [ ] Test conflict behavior when local and cloud saves differ; do not assume a cloud save is valid just because the SDK returned data.

### Yandex Games SDK
- [ ] Open the draft with the Developer Console debug panel.
- [ ] Confirm the loader indicator reports the current SDK loader (IT, not IF).
- [ ] Confirm Game Ready turns green only when the game is playable.
- [ ] Confirm pause/resume events stop sounds and update GameplayAPI state correctly.
- [ ] Verify cloud saves and any ad placement in the platform preview; local browser tests cannot validate these platform services.
- [ ] Check the external skin catalog against the platform's CSP/network policy and confirm the built-in fallback works offline.

### Device and input compatibility
- [ ] Test touch controls and narrow portrait/landscape layouts on a phone.
- [ ] Test mouse and keyboard navigation in a desktop browser.
- [ ] Test directional navigation and confirm/Back keys with an actual TV browser or a TV remote emulator.
- [ ] Test focus visibility, scrolling, fullscreen behavior, and browser back behavior on target devices.
- [ ] Select only platforms and orientations that have actually been tested in the Developer Console.

### Release materials and policy
- [ ] Replace placeholder artwork with original or properly licensed artwork.
- [ ] Verify rights and terms for third-party item names/images used by the catalog.
- [ ] Prepare an icon and real gameplay screenshots at the dimensions requested by the console.
- [ ] Review the current Yandex Games requirements and complete the draft fields.
- [ ] Upload the ZIP with index.html at its root and test that exact uploaded build before submitting for moderation.

## Current limitations

- GitHub Actions smoke checks are static checks; they do not execute the game in a real browser.
- No successful Yandex Games Developer Console run has been recorded in this repository yet.
- TV remote behavior cannot be certified without a real target TV/browser or an equivalent input emulator.
- Publication, moderation approval, ad delivery, and cloud-save behavior cannot be confirmed from the repository alone.
