# CASE LAB — HTML5 / Yandex Games

Standalone browser-first case simulator prototype for Yandex Games. The root `index.html` is the entry point.

## Features
- Six virtual cases with rarity-weighted drops.
- Virtual credits, inventory, item valuation, filters and selling.
- Upgrade contract using five inventory items.
- 30-level seasonal battle pass with free rewards.
- Missions for opening cases, receiving rare drops and building an inventory.
- Daily virtual-credit reward.
- Local save (`localStorage`) and optional Yandex Games cloud save.
- Responsive desktop/mobile layout with a fixed five-section bottom navigation on phones.
- Animated case-opening roulette with synthesized sound effects (browser audio starts after a user click).
- Real CS2 skin names and images loaded from the public ByMykel/CSGO-API catalog, with built-in fallback items if the catalog request fails.
- Optional Yandex Games SDK initialization, cloud save and sticky-banner request.

## Run locally
From the repository root:
```bash
python3 -m http.server 8080
```
Open `http://localhost:8080`. The platform SDK is only available in a Yandex Games environment, so ads and cloud save must be tested in the Developer Console preview.

## Upload
1. Create a draft in Yandex Games Developer Console.
2. Zip the repository contents with `index.html` at the ZIP root.
3. Upload the ZIP and test SDK initialization, ads, cloud save, pause/resume and mobile layout.
4. Configure monetization in the console.
5. Replace emoji placeholders with original or properly licensed artwork before release.

## Skin catalog and pricing
The browser fetches `https://raw.githubusercontent.com/ByMykel/CSGO-API/main/public/api/en/skins.json` for item names, images and case artwork when available. A normalized subset is cached locally for seven days. The simulator assigns **virtual gameplay values**, not live Steam Market prices. The API is an unofficial community data source; third-party game assets remain the property of their respective owners. The app keeps a built-in fallback catalog when the external request fails.

## Important
This is a prototype, not a published or fully QA-tested game. Ads and cloud save require verification inside the Yandex Games Developer Console. Monetization requires platform configuration and approval. All credits/items are virtual; no real-money purchases, betting, player trading or cash-out exist. This is an unofficial fan project and is not affiliated with Valve or Counter-Strike 2.

Official docs:
- SDK: https://yandex.ru/dev/games/doc/ru/sdk
- SDK connection: https://yandex.ru/dev/games/doc/ru/sdk/sdk-about
- Ads: https://yandex.ru/dev/games/doc/ru/sdk/sdk-adv
