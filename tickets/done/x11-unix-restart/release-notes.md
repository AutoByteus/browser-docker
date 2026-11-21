# Release Notes

- Release version: `1.4.2` / `1.4.2-zh`
- Rolling tags: `latest` / `zh`
- Platforms: `linux/amd64`, `linux/arm64`
- Publication status: `Published` 2026-11-21 on the founder's word (autobyteus-598), from `main` @ `9c0356d` (`./build-multi-arch.sh [--variant zh] --push --no-cache`). Checked before the push (local builds) and after it (published child digests): image, running-container and restart-recovery checks, both variants, both architectures, all pass.

| Tags | Index digest | linux/amd64 | linux/arm64 |
| --- | --- | --- | --- |
| `1.4.2`, `latest` | `sha256:86b7891d3d1d74e1b3bd42c44df9729d56343127b6f745f1f3fda8d6a6e6a50b` | `sha256:730bcd148ce6abc66a7119285c6934177ff41f9409795562fbf723f660735561` | `sha256:fdd91bd5b93d45d47a0953583917704366d95542f911e75e8c603ea6b5fa1cb1` |
| `1.4.2-zh`, `zh` | `sha256:c381f2e82fc0f0da9a74367e1c4e5029e195c90016e0dd187f9269768dd68783` | `sha256:ceb3ab231290d84a05fdbf9c3d187839a611612c9573605b29ba735154e07ddd` | `sha256:2ea28997a55b2c1f4ee48801cadf477c85292eb1c4abb084b235d4836a292957` |

- Downstream: the AutoByteus server's base pins (`system-level.json`, `Dockerfile.monorepo`, level 2) point at these index digests on `personal`. The server image is not yet rebuilt.
- Rollback baselines: `1.4.1` / `latest` index `sha256:b2fde77f3bd7c73d412ea59d42e3b65290bae9f39d1ce85b5aaaac5d869596f4`; `1.4.1-zh` / `zh` index `sha256:19d4c0164e5c7006e38a81c0260611cbf26f871f2d3e749d574016676f4f9a67`.

## Fixed

- A root X server started inside the container no longer stops the desktop. Examples are `xvfb-run` or another `Xvnc`, which agents start for their own tests.
  - Such a server takes over the X socket directory `/tmp/.X11-unix` as root. On `1.4.1` and earlier, `start-vnc.sh` then failed with `chmod: changing permissions of '/tmp/.X11-unix': Operation not permitted`.
  - This happened after `docker restart` and after a Supervisor restart of Xvnc alike. TigerVNC, XFCE, Chromium and CopyQ ended `FATAL`.

## Changed

- `/tmp/.X11-unix` is now `root:root` with mode 1777, the X convention. The image is built that way, and `/entrypoint.sh` sets it again at every container start.
- `start-vnc.sh` changes the directory's mode only when `vncuser` owns it. Otherwise it checks that the directory is world-writable and sticky. When it is not, it exits before starting Xvnc, with one message naming the directory, its owner and its mode.
- New `tests/validate-restart-recovery.sh` proves recovery after a takeover: Supervisor restart of Xvnc, `docker restart`, and kill/start. It refuses containers not labelled `chrome-vnc.test=throwaway`. The image and source checks assert the directory state and the launcher's ownership test.

## Upgrade Notes

- AutoByteus server images pick up this fix only after this base is published, the server's base digest is bumped (`system-level.json` `baseImages`, the `Dockerfile.monorepo` default, `systemInputsSha256`), and the server image is rebuilt and published. Server nodes then need to be recreated.
- Running containers of older images whose desktop went `FATAL` after a takeover recover with:

  ```bash
  docker exec <container> sh -c 'chown vncuser:vncuser /tmp/.X11-unix && chmod 1777 /tmp/.X11-unix && supervisorctl restart tigervnc xfce chrome copyq'
  ```

  This hands the directory back to `vncuser`, because the launcher in those images needs to own it.

## Preserved

- Stale `:99` lock/socket recovery and the refusal to start a duplicate X server on a live `:99`.
- Chromium autostart, DevTools 9222/9223, persistent profile and stale-lock recovery, no OS keyring.
- XFCE/TigerVNC/noVNC desktop, Python 3.13 runtime, default/`zh` variants on amd64/arm64.
