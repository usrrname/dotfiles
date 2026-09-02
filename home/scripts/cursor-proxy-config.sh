#!/usr/bin/env bash
# cursor-proxy-config — detect environment and output Cursor proxy configuration

set -euo pipefail

if [ -f /.dockerenv ] || grep -q orbstack /etc/hostname 2>/dev/null; then
  # Running in OrbStack container — use gateway IP to reach macOS host's proxy
  PROXY_URL="http://192.168.139.1:8787/v1"
  LOCATION="remote (OrbStack)"
else
  # Running locally — use localhost
  PROXY_URL="http://127.0.0.1:8787/v1"
  LOCATION="local"
fi

cat <<EOF
Cursor Proxy Configuration ($LOCATION)
======================================

1. Cursor Settings → Models → OpenAI API:
   Base URL: $PROXY_URL
   API Key: [paste real key — headroom forwards it]

2. Cursor Settings → Network:
   HTTP Compatibility Mode: HTTP/1.1

3. Add Model:
   Model ID: claude-3-5-sonnet-20241022
   (or any valid Claude model ID)

Environment for reference:
  export OPENAI_API_KEY="<your-key>"
  export OPENAI_BASE_URL="$PROXY_URL"
EOF
