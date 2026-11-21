# V-11 README older-image recovery command, run exactly as written (no -u flag) on the broken control ab596-api-control; 2026-11-21T15:52:23Z
# command: docker exec ab596-api-control sh -c 'chown vncuser:vncuser /tmp/.X11-unix && chmod 1777 /tmp/.X11-unix && supervisorctl restart tigervnc xfce chrome copyq'
== before
chrome                           FATAL     Exited too quickly (process log may have details)
copyq                            FATAL     Exited too quickly (process log may have details)
tigervnc                         BACKOFF   Exited too quickly (process log may have details)
xfce                             FATAL     Exited too quickly (process log may have details)
dir: root root 1777
image user: ''
== run
tigervnc: stopped
xfce: ERROR (not running)
chrome: ERROR (not running)
copyq: ERROR (not running)
tigervnc: started
xfce: started
chrome: started
copyq: started
command exit=0
== after
chrome                           RUNNING   pid 896, uptime 0:00:14
copyq                            RUNNING   pid 1073, uptime 0:00:13
tigervnc                         RUNNING   pid 658, uptime 0:00:18
xfce                             RUNNING   pid 663, uptime 0:00:16
validate-running-container exit=0
