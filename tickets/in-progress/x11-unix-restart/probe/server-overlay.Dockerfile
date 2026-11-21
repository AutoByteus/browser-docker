# Throwaway test image: the published AutoByteus server image with this branch's
# start-vnc.sh and entrypoint.sh laid over it, to check the fix in the server
# image's composition (its own supervisor program and entrypoint hand-over).
# Build from the repository root (never push this image):
#   docker build -f tickets/in-progress/x11-unix-restart/probe/server-overlay.Dockerfile \
#     -t autobyteus-596-server-overlay:local .
FROM autobyteus/autobyteus-server:beta
COPY start-vnc.sh /usr/local/bin/start-vnc.sh
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /usr/local/bin/start-vnc.sh /entrypoint.sh
