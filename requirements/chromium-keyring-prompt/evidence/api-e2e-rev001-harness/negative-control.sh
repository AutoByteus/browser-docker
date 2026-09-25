#!/usr/bin/env bash
set -uo pipefail
WT=/Users/normy/autobyteus_org/browser_docker-worktrees/chromium-keyring-prompt
EV=$WT/requirements/chromium-keyring-prompt/evidence
cd "$WT"
image=autobyteus/chrome-vnc:1.4.0
C=api-e2e-keyring-neg-140
V=$C-profile
T=/tmp/api-e2e-keyring/neg; rm -rf "$T"; mkdir -p "$T"
echo "purpose=C06 independent negative control: every new durable keyring assertion must FAIL on the unfixed image; discriminating controls for C09/C10"
echo "start_utc=$(date -u +%FT%TZ) image=$image $(docker image inspect -f 'id={{.Id}} arch={{.Architecture}} digests={{.RepoDigests}}' $image)"
echo "tests sha256: validate-image.sh=$(shasum -a 256 tests/validate-image.sh | cut -c1-16) validate-running-container.sh=$(shasum -a 256 tests/validate-running-container.sh | cut -c1-16)"
echo; echo "=== N1 full tests/validate-image.sh $image default (expect FAIL at first keyring assertion) ==="
tests/validate-image.sh "$image" default 2>&1 | tail -2; echo "exit=${PIPESTATUS[0]}"

echo; echo "=== N2 image 'No OS keyring' section extracted verbatim from tests/validate-image.sh with non-exiting fail() (expect every keyring assertion to FAIL; routing checks pass) ==="
{ echo 'fail() { printf "FAIL: %s\n" "$*"; }'; awk '/^# No OS keyring:/{f=1} /^if \[\[ "\$EXPECTED_VARIANT" == "zh" \]\]; then$/{f=0} f' tests/validate-image.sh; echo 'echo section-complete'; } > "$T/image-section.sh"
echo "extracted lines: $(wc -l < "$T/image-section.sh")"
docker run --rm -i --entrypoint /bin/bash "$image" -s < "$T/image-section.sh" 2>&1 | grep -E '^(FAIL|section-complete)'
echo; echo "=== start $C on $image (fresh profile) ==="
docker rm -f $C >/dev/null 2>&1; docker volume rm $V >/dev/null 2>&1
docker run -d --name $C --platform linux/arm64 --cap-add SYS_ADMIN --security-opt seccomp=unconfined -v $V:/home/vncuser/.config/chromium "$image"
echo; echo "=== N3 full tests/validate-running-container.sh $C default (expect FAIL at the flag assertion) ==="
tests/validate-running-container.sh $C default 2>&1 | grep -E '^(PASS|FAIL)'; echo "exit=${PIPESTATUS[0]}"
awk "/<<'NODE'\$/{f=1;next} /^NODE\$/{f=0} f" tests/validate-running-container.sh > "$T/node.js"
awk "/<<'KEYRING_CHECKS'\$/{f=1;next} /^KEYRING_CHECKS\$/{f=0} f" tests/validate-running-container.sh > "$T/keyring.sh"
sed 's/^\[\[ -z "\$keyring_processes" \]\] || fail .*/: # neutralised: process assertion/' "$T/keyring.sh" > "$T/keyring-no-proc.sh"
sed 's/^\[\[ -z "\$secrets_activation" \]\] || fail .*/: # neutralised: activation assertion/' "$T/keyring-no-proc.sh" > "$T/keyring-no-proc-no-log.sh"
echo "extracted: node.js $(wc -l < $T/node.js) lines; keyring.sh $(wc -l < $T/keyring.sh) lines; neutralised lines: $(grep -c neutralised $T/keyring-no-proc-no-log.sh)"
echo; echo "=== N4 NODE block verbatim (AC-002 http navigation; expect FAIL after 30 s) ==="
s=$SECONDS; docker exec -i $C node < "$T/node.js" 2>&1 | grep -E '^(PASS|FAIL)'; echo "exit=${PIPESTATUS[0]} wall_s=$((SECONDS-s))"
echo; echo "=== N5 KEYRING_CHECKS verbatim (expect FAIL: keyring processes) ==="
docker exec -i $C /bin/bash -s < "$T/keyring.sh" 2>&1 | grep -E '^(PASS|FAIL)'; echo "exit=${PIPESTATUS[0]}"
echo; echo "=== N6 KEYRING_CHECKS, process assertion neutralised -> activation-log assertion alone (expect FAIL) ==="
docker exec -i $C /bin/bash -s < "$T/keyring-no-proc.sh" 2>&1 | grep -E '^(PASS|FAIL)' | cut -c1-260; echo "exit=${PIPESTATUS[0]}"
echo; echo "=== N7 KEYRING_CHECKS, process + log assertions neutralised -> AC-007 dbus-send alone (expect FAIL: request succeeded) ==="
docker exec -i $C /bin/bash -s < "$T/keyring-no-proc-no-log.sh" 2>&1 | grep -E '^(PASS|FAIL)'; echo "exit=${PIPESTATUS[0]}"
echo; echo "=== N8 C09 operator-view control on 1.4.0 (expect FAIL: dialog window + prompter process + activation) ==="
docker cp /tmp/api-e2e-keyring/probe-operator-view.sh $C:/tmp/ >/dev/null; docker cp /tmp/api-e2e-keyring/probe-keyring-clients.sh $C:/tmp/ >/dev/null
docker exec $C bash -c 'runuser -u vncuser -- env DISPLAY=:99 XAUTHORITY=/home/vncuser/.Xauthority xwininfo -root -tree | grep -iE "gcr|keyring|prompt" | head -5'
docker exec $C /tmp/probe-operator-view.sh /tmp/c09-neg-140.png 2>&1 | grep -E '^(PASS|FAIL|screenshot|C09)|gcr|name=' | cut -c1-300; echo "exit=${PIPESTATUS[0]}"
docker cp $C:/tmp/c09-neg-140.png $EV/api-e2e-rev001-negative-control-1.4.0-operator-view.png >/dev/null && echo "screenshot copied"
echo; echo "=== N9 C10 keyring-client control on 1.4.0 (expect FAIL: vncuser libsecret store hangs on the dialog; ping succeeds) ==="
docker exec $C /tmp/probe-keyring-clients.sh 10 2>&1 | grep -E '^(PASS|FAIL|vncuser|root|C10)' | cut -c1-260; echo "exit=${PIPESTATUS[0]}"
echo; echo "=== cleanup ==="
docker rm -f $C; docker volume rm $V
echo "end_utc=$(date -u +%FT%TZ)"
