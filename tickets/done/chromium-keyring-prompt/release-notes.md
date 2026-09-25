# Release Notes

- Release version: `1.4.1` / `1.4.1-zh`
- Rolling tags: `latest` / `zh`
- Platforms: `linux/amd64`, `linux/arm64`
- Publication status: `Completed and remotely verified` on 2026-09-25 (user verified: "i thjink its already verified. so finalize and release").
- Source commit: `6d4aa757b16279449e5c7e2b3ca198789b0f9deb` (`fix(image): stop the keyring dialog from blocking agent Chromium`); release input `main` @ `6e02d7e6855b988d48b5ed44a0316b7ba34b5bf4`, built `--no-cache`.
- Default index (`1.4.1`, `latest`): `sha256:b2fde77f3bd7c73d412ea59d42e3b65290bae9f39d1ce85b5aaaac5d869596f4`.
  - `linux/amd64`: `sha256:31e3d3d8d15e16cba0187a74fd017a59e35ec70f5729d5dcb47acfe7144713e0`
  - `linux/arm64`: `sha256:f35358e25b29fac65b31b58e8024d4449e75c6db4af65281943f50a9114514ce`
- `zh` index (`1.4.1-zh`, `zh`): `sha256:19d4c0164e5c7006e38a81c0260611cbf26f871f2d3e749d574016676f4f9a67`.
  - `linux/amd64`: `sha256:12046d628acb55680a493a6f1066f5cd25542e49efc5985c45dd3501b429b454`
  - `linux/arm64`: `sha256:ef303811c7cbf5d0452cd899f47fe0d640a0e463455be3f5e82c1d219303f565`
- Downstream: AutoByteus server `1.4.80`/`latest` (`sha256:f42018efc2253507575034001b477f108c4a166ff3bd1769d662c47e8d78cfb7`) and `1.4.80-zh`/`latest-zh` (`sha256:dc3efc572f201984cb34779671c69d8c137e475b1b509bedbddd4645d739aa01`) re-published on this base (same server code); local operator nodes upgraded.
- Rollback baselines (retained immutable): `1.4.0` / `latest` index `sha256:cb49a54d8e745a45351ecab1e5f47db0eee71b30ab2e15e8c3745b91f2941af1`; `1.4.0-zh` / `zh` index `sha256:597c8702e0a2418078aca64a7f4bc19e2a26af277af119a893d51a9215837c48`.

## Fixed

- Chromium no longer stops on a GNOME "Choose password for new keyring … Default Keyring" dialog at startup, and website navigation no longer stalls behind it (regression introduced with the Ubuntu 24.04 base in `1.4.0`).

## Changed

- The image no longer ships an interactive keyring (Secret Service) provider: `gnome-keyring` and `libpam-gnome-keyring`, pulled in by Ubuntu 24.04 desktop extras as apt Recommends, are purged during the build. `evolution-data-server`, which hard-depends on `gnome-keyring`, is removed with them. Any keyring request from any process now fails immediately ("not provided by any .service files") instead of opening a dialog.
- Every Chromium launch (Supervisor autostart, `xdg-open`/AutoByteus server URL bridge, desktop menu) runs with `--password-store=basic` through the new drop-in `/etc/chromium.d/autobyteus-password-store`, so Chromium never uses an OS keyring even if one is installed later.
- Validation scripts now assert the no-keyring invariant at source, image and runtime level.

## Upgrade Notes

- Chromium protects cookies and saved passwords with its built-in key (obfuscation, as on `1.3.x`); treat the Chromium profile volume as sensitive.
- Containers upgraded from `1.4.0` keep their profile volume. Where someone typed a password into the `1.4.0` keyring dialog, cookies encrypted with that keyring are no longer readable, so affected sites need one re-login.
- Downstream images must not re-configure Chromium's password store.
- AutoByteus server images pick up this fix only after they are rebuilt on the new base; local server builds must `docker pull autobyteus/chrome-vnc:latest` (and `:zh`) first.

## Preserved

- Chromium autostart, DevTools 9222/9223, persistent profile and stale-lock recovery, mobile-safe profile, XFCE/TigerVNC/noVNC desktop, Python 3.13 runtime, default/`zh` variants on amd64/arm64.
