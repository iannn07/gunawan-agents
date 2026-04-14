FROM node:20-slim

# node:20-slim ships a `node` user at uid:gid 1000:1000. Use it.
# The `embedded-postgres` npm dep ships a glibc-compiled binary, so we need
# a glibc distro (Debian) here — Alpine's musl causes spawn ENOENT.
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      bash curl tini jq socat ca-certificates \
 && rm -rf /var/lib/apt/lists/*

RUN npm install -g paperclipai@2026.403.0 \
 && npm install -g @anthropic-ai/claude-code

# Sanity check: claude binary must be on PATH so the claude_local adapter
# can spawn it for each agent run.
RUN claude --version || (echo "claude CLI not installed correctly" && exit 1)

COPY patch-agent-roles.js /tmp/patch-agent-roles.js
RUN node /tmp/patch-agent-roles.js \
 && rm /tmp/patch-agent-roles.js

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

RUN mkdir -p /home/node/.paperclip \
 && chown -R node:node /home/node

USER node
WORKDIR /home/node
ENV HOME=/home/node \
    NODE_ENV=production

EXPOSE 3100

ENTRYPOINT ["/usr/bin/tini","--"]
CMD ["/usr/local/bin/entrypoint.sh"]
