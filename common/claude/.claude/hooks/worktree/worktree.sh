#!/usr/bin/env bash
# Create and manage git worktrees under .claude/worktrees/
#
# Usage:
#   worktree.sh [name]    Create a worktree (default: timestamp name)
#   worktree.sh list      List existing worktrees
#   worktree.sh clean     Remove all worktrees in .claude/worktrees/
#   worktree.sh clean <name>  Remove a specific worktree

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
WORKTREE_DIR="${REPO_ROOT}/.claude/worktrees"

mkdir -p "$WORKTREE_DIR"

cmd_create() {
  local name="${1:-$(date +%Y%m%d-%H%M%S)}"
  local branch="wt/${name}"
  local path="${WORKTREE_DIR}/${name}"

  if [[ -d "$path" ]]; then
    echo "error: worktree already exists: ${path}" >&2
    exit 1
  fi

  # Create branch from HEAD if it doesn't exist
  if ! git rev-parse --verify "$branch" >/dev/null 2>&1; then
    git branch "$branch" HEAD
  fi

  git worktree add "$path" "$branch"
  echo "created: ${path}"
  echo "branch:  ${branch}"
}

cmd_list() {
  git worktree list | grep "^${WORKTREE_DIR}" || echo "(none)"
}

cmd_clean() {
  local target="${1:-}"

  if [[ -n "$target" ]]; then
    local path="${WORKTREE_DIR}/${target}"
    if [[ -d "$path" ]]; then
      git worktree remove "$path" --force
      echo "removed: ${path}"
    else
      echo "error: worktree not found: ${target}" >&2
      exit 1
    fi
  else
    local count=0
    for wt in "${WORKTREE_DIR}"/*/; do
      [[ -d "$wt" ]] || continue
      git worktree remove "$wt" --force 2>/dev/null && count=$((count + 1))
    done
    echo "removed ${count} worktree(s)"
  fi
}

case "${1:-create}" in
  create)  cmd_create "${2:-}" ;;
  list)    cmd_list ;;
  clean)   cmd_clean "${2:-}" ;;
  *)
    echo "usage: worktree.sh [create [name] | list | clean [name]]" >&2
    exit 1
    ;;
esac
