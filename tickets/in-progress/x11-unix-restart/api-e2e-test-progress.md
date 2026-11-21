# API/E2E Test Progress — autobyteus-596

| Time (local) | Case | Event | Result | Note |
| --- | --- | --- | --- | --- |
| 2026-11-21 16:45 | V | Started | | HEAD f3cfa3d (code 37edc71); building autobyteus-596-chrome-vnc:api; the founder's autobyteus-server-0/1/2 untouched |
| 2026-11-21 16:47 | V-01/V-12 | Completed | Pass | source contract PASS; build wrapper PASS |
| 2026-11-21 16:50 | V-01 | Completed | Pass | my four launcher mutations (unconditional chmod, -O replaced, `|| true` variant, indented chmod in another block) all fail the contract; restored |
| 2026-11-21 16:52 | V-02/V-03 | Completed | Pass | my build autobyteus-596-chrome-vnc:api (arm64, no push); validate-image.sh PASS |
| 2026-11-21 16:45 | V-04 | Completed | Pass | fresh container: validate-running-container exit 0; dir root root 1777 |
| 2026-11-21 16:46 | V-05 | Completed | Pass | restart recovery all steps PASS in 28 s; 0 chmod lines; label refusal exit 2 (V-05b) |
| 2026-11-21 16:52 | V-06 | Completed | Pass (control fails as expected) | 1.4.1 control: in-life BACKOFF, docker restart (30 chmod lines), kill/start fail |
| 2026-11-21 16:53 | V-11 | Completed | Pass | README command revives the control; validate exit 0; VERSION 1.4.2; README and release notes per REQ-007 |
| 2026-11-21 16:53 | V-07 | Completed | Pass | 0755 and 0777 refused with one message, no Xvnc; missing dir created 1777 and Xvnc starts; own 0755 fixed |
| 2026-11-21 16:54 | V-08 | Completed | Pass | xvfb-run -a as root (Xvfb :100) beside the desktop; supervisorctl restart tigervnc and docker restart: all RUNNING |
| 2026-11-21 16:54 | V-09 | Completed | Pass | duplicate :99 refused, live Xvnc kept |
| 2026-11-21 16:55 | V-10 | Completed | Pass | server overlay probe: all running fresh, in-life, after restart; 0 chmod failures (exit 1 is the probe's final grep -c of 0) |
| 2026-11-21 17:05 | TESTING.md | Completed | | created (project document, owner API/E2E) |
| 2026-11-21 17:10 | V | Completed | Pass | report, API-REV-001; containers and my image tags removed; founder's containers untouched |
