# Case Lab — CS2 Simulator

This repository is migrating to [Rarmash/CS2-Simulator](https://github.com/Rarmash/CS2-Simulator) as the main Flutter application, while keeping the existing Case Lab implementation available at the repository root as a reference for features to port back.

## Current app base

The upstream Flutter app is tracked as a Git submodule at `vendor/CS2-Simulator`, pinned to a specific commit. GitHub Actions builds and tests that app.

Initialize the source after cloning:

```sh
git submodule update --init --recursive
cd vendor/CS2-Simulator
flutter pub get
flutter run
```

## Android release build

```sh
cd vendor/CS2-Simulator
flutter build apk --release
```

The APK artifact is uploaded by GitHub Actions after a successful build.

## Features to port back

The previous Case Lab implementation is retained in the repository root during migration. Its unique features—especially bot duels, Battle Pass, missions, and its upgrade flow—must be ported and tested against the new app architecture before the old implementation is removed.

## Licensing and third-party assets

The upstream source code is licensed under AGPL-3.0. Keep the upstream license and copyright notices, and comply with source-sharing requirements when distributing modified builds. The upstream project explicitly notes that its license does not automatically grant rights to third-party CS/CS2 game assets, trademarks, or externally sourced content. See `vendor/CS2-Simulator/LICENSE` and the upstream README.
