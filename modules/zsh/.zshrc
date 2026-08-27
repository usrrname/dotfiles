export PATH="$HOME/.npm-global/bin:$PATH"

# Update opencode CLI + all plugins pinned in the opencode config dir's package.json.
update-opencode() {
  local dir="$HOME/.opencode"
  [ -d "${XDG_CONFIG_HOME:-$HOME/.config}/opencode" ] && dir="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
  opencode upgrade
  [ -f "$dir/package.json" ] || return 0
  local deps
  deps=$(node -e "const p=JSON.parse(require('fs').readFileSync(0));console.log(Object.keys(p.dependencies||{}).join('\n'))" < "$dir/package.json")
  for dep in $deps; do
    opencode plugin "$dep" --force --global
  done
}
