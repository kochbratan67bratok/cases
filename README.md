# Case Lab — HTML5 / Yandex Games prototype

Standalone browser-first prototype based on the CS2 Simulator concept. The existing Flutter app is untouched; this version lives in `html5/` so it can be developed and tested independently.

## Included mechanics

- Three virtual cases with rarity-weighted drops.
- Virtual credits, inventory, item valuation and selling.
- Daily virtual-credit reward.
- Five-item upgrade contract.
- Local progress save with `localStorage`.
- Optional Yandex Games cloud save when SDK/player APIs are available.
- Rewarded-video integration: grants +150 virtual credits only in the SDK's `onRewarded` callback.
- Responsive layout for desktop and mobile.

## Run locally

The SDK is loaded from `/sdk.js`, as recommended for games uploaded to Yandex Games. For local testing that path will not resolve unless the Yandex development proxy/preview is used. The game is designed to continue in standalone mode without the SDK.

From the repository root, serve the folder with any static HTTP server, for example:

```bash
python3 -m http.server 8080 --directory html5
```

Open `http://localhost:8080`.

## Yandex Games publication checklist

1. Create a game draft in the Yandex Games Developer Console.
2. Upload the contents of `html5/` as a ZIP archive (the entry point is `index.html`).
3. Confirm SDK initialization in the platform debug panel.
4. Enable/configure monetization in the Developer Console.
5. Test rewarded ads, cloud saves, pause/resume, mobile layout and moderation requirements.
6. Replace placeholder emoji art with original/licensed assets before release.

Official documentation:
- SDK: https://yandex.ru/dev/games/doc/ru/sdk
- SDK connection: https://yandex.ru/dev/games/doc/ru/sdk/sdk-about
- Ads: https://yandex.ru/dev/games/doc/ru/sdk/sdk-adv

## Important

This is a prototype, not a published game. Ads do not show locally unless the platform SDK is initialized in an eligible Yandex Games environment. Credits and items are virtual only; there are no real-money purchases, trading or cash-outs. No revenue is guaranteed.