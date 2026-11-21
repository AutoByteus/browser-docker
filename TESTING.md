# Testing

How this image is tested: which checks exist and what each proves, how to run
them, and the rules every test run follows. Read it before planning or running
validation. A ticket's results and evidence belong in that ticket's folder.

## Setup

- Docker with BuildX (Docker Desktop includes it). Run every command from the
  repository root.
- Build the image to test from the current source, under a local tag of your
  own, and never with `--push`:
  - default variant, host architecture: `docker build -t <local-tag> .`
  - `zh` variant: `docker build --build-arg IMAGE_VARIANT=zh -t <local-tag>-zh .`
  - `./build-multi-arch.sh` without `--push` also builds and loads for the
    host architecture (`--variant zh` for the `zh` variant).

## Test Layers

| Layer | What it proves | Command |
| --- | --- | --- |
| Source contract | The source files keep their rules: build and release inputs, runtime paths, ports, no keyring, the X socket directory (its state set by `entrypoint.sh`, and `start-vnc.sh` changing its mode only inside the ownership test), and documentation the code depends on | `bash tests/validate-source-contract.sh` |
| Build wrapper | `build-multi-arch.sh` passes push sessions to BuildX and propagates failures; it uses a fake `docker`, so nothing is built or pushed | `bash tests/validate-build-wrapper.sh` |
| Built image | The image's contents and the launcher without Supervisor: identity, Python and Supervisor ownership, packages, locale and variant, the X socket directory as built, `start-vnc.sh`'s refusal of an unusable directory, UID/GID | `bash tests/validate-image.sh <image> [default\|zh]` |
| Running container | A started container: every Supervisor program, VNC, websockify, DevTools, Chromium rendering and its profile, no keyring prompt | `bash tests/validate-running-container.sh <container> [default\|zh] [uid]` |
| Restart recovery | After a root X server takes over `/tmp/.X11-unix`, the desktop recovers from a Supervisor restart of Xvnc, `docker restart`, and kill/start. It restarts and kills the container | `bash tests/validate-restart-recovery.sh <container> [default\|zh] [uid]` |

The running-container and restart-recovery checks need a container started from
the image to test:

```bash
docker run -d --name <name> --label chrome-vnc.test=throwaway \
  --cap-add SYS_ADMIN --security-opt seccomp=unconfined <image>
```

`--cap-add SYS_ADMIN --security-opt seccomp=unconfined` is what Chromium needs
here. `tests/validate-restart-recovery.sh` refuses any container without the
`chrome-vnc.test=throwaway` label.

## Fresh-Start Build

The release builds with `./build-multi-arch.sh [--variant zh] --push` for
`linux/amd64` and `linux/arm64`. A change to any of these needs a real image
build and the image and container checks, not only the source contract:
`Dockerfile`, `*.sh` at the root, `supervisord.conf`, `base.conf`, `chromium.d/`,
`requirements/`, `VERSION`, `build-multi-arch.sh`.

## Choosing The Layer

- Shell or configuration change: source contract, then an image build with the
  image check and a running container.
- A change to how the desktop starts or restarts (entrypoint, launchers,
  Supervisor configuration, the X socket directory): also the restart-recovery
  check, and the same check against the last published image as a control when
  the change fixes a restart failure; the control must fail where the fix
  applies.
- The checks run on the host's architecture. The other architecture and the
  `zh` variant are proven only by building and checking them. Before a release,
  run the image check and the running-container check for each variant on each
  architecture the release builds. `build-multi-arch.sh` does not run them
  itself.

## Environments, Credentials And Data

- No credentials or accounts are needed to test.
- Test only throwaway containers you started, labelled
  `chrome-vnc.test=throwaway`, from images built for the test. Never run a check
  against containers you did not start, such as running AutoByteus nodes
  (`autobyteus-server-*`): the restart-recovery check restarts and kills its
  container.

## Rules

- Test a build of the current source, not a published image (except as a
  control).
- Never push and never build with `--push` while testing; publishing is a
  release step.
- Remove the containers and local images you created when you are done.

## Evidence

Command output goes to the ticket's `evidence/` folder; nothing from a test run
is committed outside the ticket folder.
