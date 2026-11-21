# Design

How this image is built and the design rules a change here follows. Read it
before designing a change, and during implementation and review. General
design practice is not repeated here.

## Architecture Overview

This repository builds `autobyteus/chrome-vnc`: an Ubuntu 24.04 desktop
container that people view over VNC and agents drive through Chromium's
DevTools. It comes in two variants, default and `zh` (Chinese fonts and fcitx5),
for `linux/amd64` and `linux/arm64`.

- **Build:** `Dockerfile` (variant chosen by build argument) and
  `build-multi-arch.sh`. `VERSION` is the single source of the image version.
- **Container start:** `/entrypoint.sh` runs as root. It prepares the shared
  runtime state that programs running as `vncuser` cannot prepare themselves:
  - the Supervisor and XDG runtime directories;
  - stale Chromium profile locks;
  - the DBus directories;
  - the X socket directory and stale `:99` X artifacts.

  It then `exec`s Supervisor as PID 1.
- **Programs:** `supervisord.conf` (root Supervisor) and `base.conf`. Every
  desktop program runs as `vncuser`:
  - DBus session bus;
  - TigerVNC `Xvnc :99` on 5900, through `start-vnc.sh`;
  - XFCE;
  - fcitx5 (`zh` only);
  - CopyQ;
  - Chromium with DevTools on 9222, through `start-chrome.sh`;
  - a `socat` proxy 9223 → 9222;
  - websockify 6080 → 5900.

  Program order comes from `priority` and Supervisor's restart retries.
- **Python tooling:** Supervisor 4.3.0, websockify and `uv` live in the
  isolated Python 3.13 environment `/opt/browser-tools`, exposed through
  `/usr/local/bin`. The distribution's `/usr/bin/python3` stays untouched.
- **Downstream:** the AutoByteus server image (superrepo
  `autobyteus-server-ts/docker/Dockerfile.monorepo`) builds `FROM
  autobyteus/chrome-vnc@<digest>`, pinned in its `system-level.json` per
  variant. Its entrypoint hands over to `/entrypoint.sh`, and it adds its own
  root Supervisor program. A base-image fix reaches server nodes only after a
  base release, a digest bump there, and a server-image rebuild.

## Conventions

- **Root prepares, `vncuser` runs.** State shared across programs or across
  container lives is set by `/entrypoint.sh` as root at every container start.
  A program's launcher does only what `vncuser` may do. It checks the state it
  needs and fails with a message that names what is wrong; it never relies on
  changing something it does not own, and never uses `sudo`. A launcher also
  runs on Supervisor restarts inside a running container, after the
  entrypoint, so it must not assume the entrypoint ran recently.
- **The X socket directory is `root:root 1777`.** It is built that way and set
  that way at every start. Root X servers that agents start in the container,
  such as `xvfb-run` or another `Xvnc`, enforce root ownership anyway, so the
  image follows the X convention instead of fighting it.
- **Every container start begins clean.** `/tmp` and other writable-layer
  state survive `docker restart`. Anything a previous life can leave behind
  (locks, sockets, ownership changes) is cleared or normalized by
  `/entrypoint.sh`. Leftovers that may belong to a live process are kept: the
  Chromium lock and the `:99` X lock are checked against their PID's process.
- **Unattended use.** Nothing may wait on an interactive dialog. For example,
  there is no OS keyring, and Chromium always runs with
  `--password-store=basic`.
- **Downstream images do not re-implement the base's startup.** They extend
  `/entrypoint.sh` by handing over to it, not by copying its steps.
- **Validation lives in `tests/` as `validate-*.sh` bash scripts**, one
  responsibility each:
  - source contract;
  - built image without Supervisor;
  - one running container;
  - restart recovery;
  - build wrapper.

  A script that restarts or kills a container refuses one that is not
  labelled as a throwaway test container.
- **Shell scripts** use `set -euo pipefail` (or `-eo` where unset variables
  are expected) and are normalized with `dos2unix` in the build.

## Project Design Documents

- `README.md`: features, build and publish commands, runtime use and recovery
  notes. Read it before changing a user-visible behavior or a documented
  command.

## Design Cases

### DC-001: A vncuser launcher changed a directory root may own (x11-unix-restart, 2026-11)

- **Problem:** `start-vnc.sh` (as `vncuser`) ran `chmod 1777 /tmp/.X11-unix`
  under `set -e`. After a root X server in the container took the directory
  over, every Xvnc start failed with EPERM, after container restarts and after
  Supervisor restarts alike, and the desktop programs went `FATAL`.
- **How it was found:** a live node's desktop stayed down after a restart.
- **Wrong assumption:** that the image alone decides who owns a shared
  runtime directory. Root processes started inside the container change it
  too, and the writable layer keeps the change across restarts.
- **Fix:** root defines the state at build and at every start
  (`root:root 1777`). The launcher changes the mode only when it owns the
  directory, and otherwise checks it is usable.
- **Lesson:** for any shared runtime path, decide its owner and mode once, set
  them as root at container start, and have unprivileged launchers check
  rather than change it. Test the in-life restart path as well as the
  container restart.
