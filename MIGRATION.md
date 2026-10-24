# Migration notes

- Main Flutter application base: `vendor/CS2-Simulator` (upstream commit `bc0d4305a10f06f601e5ba9e29b04835eee61986`).
- CI builds and tests the upstream Flutter project from the submodule.
- The former Case Lab app at the repository root is intentionally retained for feature-porting reference.
- Not yet ported into the new base: bot duels, Battle Pass, missions, and the old chance-based upgrader.
- Before release, review AGPL-3.0 compliance and the licensing of all third-party game assets.
