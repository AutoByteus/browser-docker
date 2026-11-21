# Release Notes

- Release version: `1.4.2` / `1.4.2-zh`
- Rolling tags: `latest` / `zh`
- Platforms: `linux/amd64`, `linux/arm64`
- Publication status: `Not published`. Release only on the founder's word. Delivery fills in the source commit, digests and downstream rows at publication.
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
