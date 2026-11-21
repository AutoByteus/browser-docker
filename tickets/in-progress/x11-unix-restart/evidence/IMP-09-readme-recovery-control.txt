# IMP-09
# Command: README recovery command (extracted from README.md) on ab596-control after IMP-08 left it FATAL; then tests/validate-running-container.sh ab596-control default
# Commit: 37edc71 (branch codex/x11-unix-restart)
# Environment: macOS arm64, Docker Desktop (linux/arm64), 2026-11-21

== before
chrome                           FATAL     Exited too quickly (process log may have details)
copyq                            FATAL     Exited too quickly (process log may have details)
tigervnc                         BACKOFF   Exited too quickly (process log may have details)
xfce                             FATAL     Exited too quickly (process log may have details)
root root 1777
== README command: docker exec <container> sh -c 'chown vncuser:vncuser /tmp/.X11-unix && chmod 1777 /tmp/.X11-unix && supervisorctl restart tigervnc xfce chrome copyq'
tigervnc: stopped
xfce: ERROR (not running)
chrome: ERROR (not running)
copyq: ERROR (not running)
tigervnc: started
xfce: started
chrome: started
copyq: started
== after
chrome                           RUNNING   pid 906, uptime 0:00:07
copyq                            RUNNING   pid 1092, uptime 0:00:05
dbus                             RUNNING   pid 37, uptime 0:02:18
disable_screensaver              EXITED    Nov 21 03:38 PM
fcitx                            RUNNING   pid 40, uptime 0:02:18
socat                            RUNNING   pid 51, uptime 0:02:18
tigervnc                         RUNNING   pid 667, uptime 0:00:10
websockify                       RUNNING   pid 57, uptime 0:02:18
xfce                             RUNNING   pid 672, uptime 0:00:08
PASS: isolated Supervisor 4.3.0, Python 3.13 process ownership, UID/XDG/DBus, VNC, websockify, DevTools, Chromium password-store and profile-write contracts validated.
PASS: Chromium rendered semantic DOM through DevTools: {"title":"BRD-UBUNTU24-001","evidence":"Noble browser render passed"}
PASS: Chromium loaded http://127.0.0.1:6080/ unattended in 44 ms: {"url":"http://127.0.0.1:6080/","readyState":"complete","title":"Directory listing for /"}
PASS: no keyring prompt/provider process or Secret Service activation; vncuser Secret Service request failed in 6 ms: Error org.freedesktop.DBus.Error.ServiceUnknown: The name org.freedesktop.secrets was not provided by any .service files
exit=0
