# headroom owns its agent config: `headroom mcp install` writes the MCP
# server entry for every detected agent (claude, opencode, codex, ...) and
# tracks fingerprints in ~/.headroom/mcp_installs.json; `headroom init
# claude` installs durable hooks + provider routing. Never hand-edit those
# blocks — headroom regenerates them. Both commands are idempotent
# (--force only overwrites on fingerprint mismatch), so safe every activation.
${DRY_RUN_CMD:-} headroom mcp install --force
# Skip gracefully where claude isn't installed, mirroring `mcp install`'s
# own "not detected on this system, skipped" behavior.
# `init claude` also does `claude marketplace add` over SSH git clone —
# non-fatal so activation still completes on hosts/sandboxes without an
# SSH key (e.g. the credential-less agent sandbox).
if command -v claude >/dev/null 2>&1; then
  ${DRY_RUN_CMD:-} headroom init claude || echo "⚠️  headroom init claude failed (no SSH access?) — continuing"
fi
