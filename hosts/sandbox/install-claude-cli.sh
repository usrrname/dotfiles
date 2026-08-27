export PATH="$HOME/.npm-global/bin:$PATH"
export NPM_CONFIG_PREFIX="$HOME/.npm-global"
$DRY_RUN_CMD mkdir -p "$HOME/.npm-global"
if ! "$HOME/.npm-global/bin/claude" --version >/dev/null 2>&1; then
  $DRY_RUN_CMD npm install -g @anthropic-ai/claude-code
fi
