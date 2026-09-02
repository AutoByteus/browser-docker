# Handoff Summary

## Current Delivery State

- Ticket: `BRD-UBUNTU24-001`
- Current delivery revision: `DR-006`
- User verification: received on 2026-09-02 — “verified. fianlze and release”; the later bounded push-readiness correction did not materially change the verified image/runtime handoff.
- Integrated source/release input commit: `18bb92e2c9784a4222ff734ffd47d89d877b5c59`.
- Repository finalization: completed and remotely verified on `main`.
- Docker Hub publication: completed and remotely verified.
- Acceptance: `AC-001` through `AC-013` pass for this ticket; `AC-012` records the now-verified dependency identity without changing server source.
- Terminal classification: `Delivered`.
- Post-finalization cleanup: completed; the dedicated ticket worktree and local/remote ticket branches were removed after the release record reached `main`.

## Authoritative Gate Package

- Requirements: `RER-007` approved.
- Design and architecture: `SR-002` / `ARCH-REV-002 Pass`.
- Implementation: `IR-006`/`IR-007` at `14fb215b1ad0b48dd486658ca7fd7757ceb06d16`.
- Implementation review: `CRR-010 Pass`, 97.0%; `CR-F-001` resolved.
- API/E2E: `API-REV-007 Pass`, 97%, including the required broader non-publishing wrapper matrix.
- Post-API/E2E test review: `CRR-011 Not Applicable`; API/E2E made no repository-resident durable-test change after CRR-010.
- Delivery integration/finalization evidence: `delivery-dr006-integration-refresh.log`; source plus cumulative evidence committed at `18bb92e` and pushed to both the ticket branch and `main` before publication.

## Published Identities

| Variant | Tags | OCI index digest | linux/amd64 child | linux/arm64 child |
| --- | --- | --- | --- | --- |
| default | `1.4.0`, `latest` | `sha256:cb49a54d8e745a45351ecab1e5f47db0eee71b30ab2e15e8c3745b91f2941af1` | `sha256:9cf057cce95cf6624eff5142424754135aac2298af3a70146807f941ed0b4ba1` | `sha256:2ee3f7665f8bc663f29474e1c211fd9080149f83e56a071a7a03d7578685a345` |
| `zh` | `1.4.0-zh`, `zh` | `sha256:597c8702e0a2418078aca64a7f4bc19e2a26af277af119a893d51a9215837c48` | `sha256:7e35ac854ea8609a033222ce552a4ebe956a781926af2f1fd50c77acfd972e4f` | `sha256:7cba7bf2be52a4c613c74237a1774244c7feced9637785882025975fd83d38f6` |

The immutable and rolling tags match within each variant. BuildX also published normal provenance attestation descriptors; these appear as `unknown/unknown` auxiliary descriptors and do not replace either required runtime platform.

## Remote Verification

- `./build-multi-arch.sh --push`: passed; published `1.4.0` and `latest`.
- `./build-multi-arch.sh --variant zh --push`: passed; published `1.4.0-zh` and `zh`.
- `docker buildx imagetools inspect`: passed for all four tags; each index contains exactly one `linux/amd64` and one `linux/arm64` runtime manifest.
- Pull/run by each exact child digest: passed for default/AMD64, default/ARM64, `zh`/AMD64, and `zh`/ARM64.
- Every exact published runtime reports Ubuntu 24.04 Noble, public Python 3.13.15, Noble OS Python 3.12.3, Supervisor 4.3.0, the expected architecture, and the expected variant.
- Exact evidence: `delivery-dr006-publish-default.log`, `delivery-dr006-publish-zh.log`, `delivery-dr006-remote-manifests.log`, and `delivery-dr006-published-runtime-identities.log`.

## Rollback Visibility

The pre-release rolling baselines were retained as immutable `1.3.8` and `1.3.8-zh` artifacts. Their recorded index digests are:

- default: `sha256:f5a12a4fc553d40158b6d6c5f87e3ea0a2bcfbc71e3cb8153f7a3aa310241029`
- `zh`: `sha256:24ca92cb4a274be088901f679ae9bb31317d2b73c3ab954d2fc8f631e6713071`

Rollback is not indicated by current verification. If required, rolling tags can be restored from those retained immutable release identities through the documented publication process.

## Scope Boundary And Next Ticket

AutoByteus server source was not accessed or modified. The separate server-adoption ticket may now start using the verified immutable browser-image identities above. Floating tags alone should not be used as the dependency evidence.
