# Installs/realigns the pinned headroom CLI version (no-op if it already
# matches). DRY_RUN_CMD is set only during home-manager activation, so
# ${DRY_RUN_CMD:-} stays safe under `set -u` in the proxy wrappers that also
# source this.
#
# Env vars: HEADROOM_VERSION, UV_BIN_DIR
export PATH="$HOME/.local/bin:$UV_BIN_DIR:$PATH"
if ! command -v headroom >/dev/null 2>&1 \
  || [ "$(headroom --version 2>/dev/null | grep -o 'version [0-9.]*' | cut -d' ' -f2)" != "$HEADROOM_VERSION" ]; then
  ${DRY_RUN_CMD:-} uv tool install --force --python 3.13 "headroom-ai[proxy]==$HEADROOM_VERSION"
fi
