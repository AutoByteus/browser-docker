# Delivery / Release / Deployment Report

## Release Scope And Result

- Ticket: `BRD-UBUNTU24-001`
- Version: `1.4.0` / `1.4.0-zh`
- Registry: `docker.io/autobyteus/chrome-vnc`
- Final result: `Completed`
- Current delivery revision: `DR-006`
- Source/release input commit: `18bb92e2c9784a4222ff734ffd47d89d877b5c59`
- Git tag: not part of this repository's documented release method; none created.

## User Verification

- Explicit verification/finalization authorization: received on 2026-09-02 — “verified. fianlze and release”.
- Renewed verification after IR-006/IR-007: not required. The reviewed correction only removed an obsolete Docker-output authentication heuristic and added fixture cleanup; it did not materially change the previously verified image/runtime contract.
- Continuation confirmation: user instructed Delivery to continue after the default publication completed.

## Delivery Re-entry Integration Refresh

- Initial re-entry HEAD: `14fb215b1ad0b48dd486658ca7fd7757ceb06d16`.
- Latest tracked `origin/main` and remote ticket branch before finalization continuation: `01a07b203472049695e870b2865fcd5df9ec5844`.
- Ahead/behind: 2 ahead / 0 behind; `origin/main` was already an ancestor.
- Integration method: already current; no merge or rebase required.
- Focused checks: Bash syntax, `tests/validate-build-wrapper.sh`, `tests/validate-source-contract.sh`, and repository diff checks passed.
- Evidence: `requirements/ubuntu-24-minimal-base/evidence/delivery-dr006-integration-refresh.log`.

## Repository Finalization Continuation

- Cumulative fix/review/API-E2E/evidence commit: `18bb92e2c9784a4222ff734ffd47d89d877b5c59` (`test: validate Docker push wrapper fix`).
- Ticket branch push: completed and remote-ref verified at `18bb92e`.
- `main` refresh: current at `01a07b2`; no new conflicting target commit.
- `main` update: fast-forwarded through `24a61a8`, `14fb215`, and `18bb92e`.
- Target checks: build-wrapper and source-contract suites passed.
- `main` push: completed and remote-ref verified at `18bb92e` before publication.
- Repository finalization result: `Completed`.

## Publication Steps

1. `./build-multi-arch.sh --push` — passed; published `1.4.0` and `latest`.
2. `./build-multi-arch.sh --variant zh --push` — passed; published `1.4.0-zh` and `zh`.
3. `docker buildx imagetools inspect` plus raw-index assertions — passed for every tag.
4. Pull and run each exact platform child digest — passed for all four platform/variant combinations.

The corrected wrapper reached real BuildX in both authorized push paths, let BuildX perform registry authentication/authorization, propagated status correctly, and emitted success only after both tag manifests were pushed.

## Published Manifest Identities

| Variant | Immutable tag | Rolling tag | Index digest | linux/amd64 child | linux/arm64 child |
| --- | --- | --- | --- | --- | --- |
| default | `1.4.0` | `latest` | `sha256:cb49a54d8e745a45351ecab1e5f47db0eee71b30ab2e15e8c3745b91f2941af1` | `sha256:9cf057cce95cf6624eff5142424754135aac2298af3a70146807f941ed0b4ba1` | `sha256:2ee3f7665f8bc663f29474e1c211fd9080149f83e56a071a7a03d7578685a345` |
| `zh` | `1.4.0-zh` | `zh` | `sha256:597c8702e0a2418078aca64a7f4bc19e2a26af277af119a893d51a9215837c48` | `sha256:7e35ac854ea8609a033222ce552a4ebe956a781926af2f1fd50c77acfd972e4f` | `sha256:7cba7bf2be52a4c613c74237a1774244c7feced9637785882025975fd83d38f6` |

- Immutable/rolling equality: `Pass` for both variants.
- Required runtime platform cardinality: exactly one `linux/amd64` and one `linux/arm64` descriptor per tag.
- Auxiliary `unknown/unknown` descriptors: expected BuildX provenance attestations referencing the two runtime manifests.

## Published Runtime Verification

Every exact child digest was pulled and run independently. All four checks passed:

| Variant | Platform | Ubuntu | Public Python | OS Python | Supervisor | Variant/architecture |
| --- | --- | --- | --- | --- | --- | --- |
| default | `linux/amd64` | 24.04 Noble | 3.13.15 | 3.12.3 | 4.3.0 | pass |
| default | `linux/arm64` | 24.04 Noble | 3.13.15 | 3.12.3 | 4.3.0 | pass |
| `zh` | `linux/amd64` | 24.04 Noble | 3.13.15 | 3.12.3 | 4.3.0 | pass |
| `zh` | `linux/arm64` | 24.04 Noble | 3.13.15 | 3.12.3 | 4.3.0 | pass |

The checks also confirmed the public and OS Python selectors, `/opt/browser-tools` ownership for Supervisor/websockify/`uv`, exact `IMAGE_VARIANT`, native container architecture reporting, and `fcitx5` presence only in `zh`.

## Acceptance And Rollout

- AC-011: `Pass`.
- AC-012: `Pass` as a delivery-record condition; the exact dependency identities are recorded and the separate server ticket can now begin.
- Server deployment/adoption: `Not in scope`; no AutoByteus server repository or environment was accessed or mutated.
- Persisted data/profile transition: none.

## Evidence

- `requirements/ubuntu-24-minimal-base/evidence/delivery-dr006-publish-default.log`
- `requirements/ubuntu-24-minimal-base/evidence/delivery-dr006-publish-zh.log`
- `requirements/ubuntu-24-minimal-base/evidence/delivery-dr006-remote-manifests.log`
- `requirements/ubuntu-24-minimal-base/evidence/delivery-dr006-published-runtime-identities.log`
- `requirements/ubuntu-24-minimal-base/evidence/delivery-dr006-cleanup.log`

## Rollback

Rollback is not required. The recorded pre-release rolling baselines remain available through immutable `1.3.8`/`1.3.8-zh` identities:

- default index: `sha256:f5a12a4fc553d40158b6d6c5f87e3ea0a2bcfbc71e3cb8153f7a3aa310241029`
- `zh` index: `sha256:24ca92cb4a274be088901f679ae9bb31317d2b73c3ab954d2fc8f631e6713071`

If post-release evidence later requires rollback, restore `latest` and `zh` from those retained immutable releases and verify their remote indexes before downstream adoption.

## Cleanup

- Exact digest image references pulled solely for DR-006 verification: removed; evidence passed.
- Pre-existing rolling local tags: not targeted or altered by cleanup.
- Ticket worktree/local and remote ticket branches: pending safe cleanup after this final delivery record is committed and pushed to `main`.

## Final Status

- Explicit user verification: `Complete`
- Repository finalization: `Complete`
- Docker Hub publication: `Complete`
- Remote manifest verification: `Complete`
- Published runtime identity verification: `Complete`
- Final release-record push: pending this report commit
- Safe ticket cleanup: pending the final release-record push
- Unresolved release blocker: `None`
