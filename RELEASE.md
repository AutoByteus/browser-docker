# Release Guide

How a verified change in this repository is finalized, released and rolled out.
Read it before merging a ticket into `main`, publishing an image or changing the
images' tags. A generic delivery process covers the order of the steps; this
file holds what is specific to this repository.

It holds what every future release follows. One release's runs, digests and
incidents belong in that release's ticket report; a lesson from one goes in
here as a step or rule.

## Finalization Target

- Remote `origin` (`AutoByteus/browser-docker`), branch `main`. Ticket branches
  are `codex/<ticket-name>`.
- `main` has a linear history: a ticket branch lands on `main` as a
  fast-forward. When `main` has moved, bring the ticket branch current first
  and rerun the checks below.
- Order: push the ticket branch, fetch `origin/main` and check that it has not
  moved since you last integrated it, fast-forward `main` to the ticket branch,
  push `main`. Then delete the remote ticket branch.
- Before pushing `main`, on the final state:

  ```bash
  bash tests/validate-source-contract.sh
  bash tests/validate-build-wrapper.sh
  ```

- Commit no build output, local image archives or container logs outside a
  ticket's `evidence/` folder. Ticket evidence names use `-`, never `:` (a
  Windows checkout cannot hold `:`).
- `VERSION` is the image version. The fix or feature commit that needs a
  release bumps it; bumping it publishes nothing.

## Release Decision

- A release is published only on the founder's explicit word. The default is
  no release: the change waits on `main` for the next one.
- A release publishes both variants (default and `zh`) for `linux/amd64` and
  `linux/arm64`.

## Cutting The Release

From `main` at the finalized commit, with Docker Hub push access:

```bash
./build-multi-arch.sh --push --no-cache
./build-multi-arch.sh --variant zh --push --no-cache
```

- `build-multi-arch.sh` reads `VERSION` and tags `autobyteus/chrome-vnc:X.Y.Z`
  and `:latest` (default), and `:X.Y.Z-zh` and `:zh` (`zh`).
- It builds and pushes. It runs no check (`tests/validate-build-wrapper.sh`
  tests only how it calls BuildX).
- No git tag is created; the image tags are the release.
- Never push over a published `X.Y.Z` tag: consumers pin images by digest, and
  a fix goes out as the next patch version.
- Release notes come from the ticket's `release-notes.md`. Record the source
  commit and every published digest there.

## Checks After Publishing

The checks a ticket runs cover the host architecture and the default variant;
the other architecture and the `zh` variant are proven only here (TESTING.md
"Choosing The Layer"). For each variant, inspect the published index and run
the checks against each platform's exact child digest:

```bash
docker buildx imagetools inspect autobyteus/chrome-vnc:X.Y.Z      # and :X.Y.Z-zh
# for each linux/amd64 and linux/arm64 child digest:
docker pull --platform linux/<arch> autobyteus/chrome-vnc@sha256:<child>
bash tests/validate-image.sh autobyteus/chrome-vnc@sha256:<child> <default|zh>
docker run -d --platform linux/<arch> --name <name> --label chrome-vnc.test=throwaway \
  --cap-add SYS_ADMIN --security-opt seccomp=unconfined autobyteus/chrome-vnc@sha256:<child>
bash tests/validate-running-container.sh <name> <default|zh>
bash tests/validate-restart-recovery.sh <name> <default|zh>
```

- Check that `X.Y.Z` and `latest` (and `X.Y.Z-zh` and `zh`) resolve to the same
  index, with exactly one `linux/amd64` and one `linux/arm64` runtime manifest.
  The two `unknown/unknown` entries are BuildX attestations.
- The release is not done until every variant and architecture has passed.
  Do not start the downstream rollout before that.
- Remove the throwaway containers and pulled images afterwards.

## Watching The Rollout

This repository has no CI. The base image reaches users through the AutoByteus
server image, which pins it by digest in the workspace repository
(`autobyteus-workspace`, `autobyteus-server-ts/docker/`):

1. Bump the server's base digest: `system-level.json` `baseImages`, the
   `Dockerfile.monorepo` default and `systemInputsSha256`.
2. Rebuild and publish the server image through that repository's release
   (its `RELEASE.md`). Re-publishing an existing server version on the new base
   uses `gh workflow run release-server-docker.yml --repo AutoByteus/autobyteus-workspace -f release_tag=<vX.Y.Z>`
   (and `-f publish_zh=true` for the `zh` server image).
3. Nodes pick up the new server image when they are recreated
   (`autobyteus-docker upgrade --all`).

A base published without step 1 and 2 reaches no AutoByteus node.

## Recovery

- A failed push leaves the immutable tag unpublished or partial: read the
  BuildX output. A registry or network failure is rerun with the same
  command. A build failure is a defect: fix it on `main` first.
- A published image that fails a check after publishing is not rolled out
  downstream. Point the rolling tags back (Rollback) and fix forward with the
  next patch version.

## Rollback

- Point a rolling tag back at the previous release's index digest:

  ```bash
  docker buildx imagetools create -t autobyteus/chrome-vnc:latest autobyteus/chrome-vnc@sha256:<previous index>
  docker buildx imagetools create -t autobyteus/chrome-vnc:zh autobyteus/chrome-vnc@sha256:<previous zh index>
  ```

- Each ticket's release notes record the previous digests as its rollback
  baseline.
- The server image pins the base by digest, so it rolls back by reverting its
  digest bump and rebuilding.

## Deployment

This repository deploys no service. Users receive a release as the
`autobyteus/chrome-vnc` images on Docker Hub, and AutoByteus nodes through the
server image (Watching The Rollout).
