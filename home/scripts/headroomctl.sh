#!/usr/bin/env bash
# headroomctl — on-demand control for headroom proxy launchd services.
# Lazily-started proxies (the Gemini ones) don't run at login; start them
# when needed. Imported by home/default.nix via builtins.readFile.
set -euo pipefail

uid="$(id -u)"
plist_dir="$HOME/Library/LaunchAgents"
svc() { echo "org.nixos.headroom-proxy-$1"; }
names="anthropic deepseek go gemini-1 gemini-2 gemini-3"

loaded() { launchctl list 2>/dev/null | grep -q "$(svc "$1")"; }

list() {
  printf '%-12s %-6s %s\n' NAME PORT STATE
  for p in anthropic:8787 deepseek:8788 go:8789 gemini-1:8790 gemini-2:8791 gemini-3:8792; do
    name="${p%%:*}"; port="${p##*:}"
    if loaded "$name"; then printf '%-12s %-6s %s\n' "$name" "$port" "running"
    else printf '%-12s %-6s %s\n' "$name" "$port" "stopped"; fi
  done
}

start_one() {
  local n="$1"
  if ! loaded "$n"; then
    launchctl bootstrap "gui/$uid" "$plist_dir/$(svc "$n").plist" 2>/dev/null || true
  fi
  launchctl kickstart "gui/$uid/$(svc "$n")"
  echo "started $n"
}
stop_one() {
  local n="$1"
  launchctl bootout "gui/$uid/$(svc "$n")" 2>/dev/null || true
  echo "stopped $n"
}
restart_one() {
  local n="$1"
  if ! loaded "$n"; then
    launchctl bootstrap "gui/$uid" "$plist_dir/$(svc "$n").plist" 2>/dev/null || true
  fi
  launchctl kickstart -k "gui/$uid/$(svc "$n")"
  echo "restarted $n"
}

cmd="${1:-list}"
shift || true

case "$cmd" in
  start)   for n in ${*:-$names}; do start_one "$n"; done ;;
  stop)
    # Require an explicit target so a bare `stop` can't tear down the
    # always-on anthropic/deepseek/go backends.
    [ $# -gt 0 ] || { echo "error: 'stop' requires an explicit target (e.g. headroomctl stop gemini-1)" >&2; exit 1; }
    for n in "$@"; do stop_one "$n"; done ;;
  restart) for n in ${*:-$names}; do restart_one "$n"; done ;;
  status|list|"") list ;;
  *) echo "usage: headroomctl {start|stop|restart|status} [name ...]" >&2; exit 1 ;;
esac
