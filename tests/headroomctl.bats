#!/usr/bin/env bats
# Bats tests for home/scripts/headroomctl.sh.
#
# The script branches on `uname -s` and shells out to launchctl (macOS) or
# systemctl --user (Linux). Both are mocked (tests/mocks/) so nothing on the
# real host is touched; MOCK_OS selects which branch each test exercises.
#
# Run: bats tests/headroomctl.bats
# (or `nix build .#checks.x86_64-linux.headroomctl-tests`)

setup() {
  SCRIPT="${HEADROOMCTL_SCRIPT:-$BATS_TEST_DIRNAME/../home/scripts/headroomctl.sh}"
  MOCK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/headroomctl-test.XXXXXX")"
  export MOCK_OS="${MOCK_OS:-}"
  export MOCK_SYSTEMD_DIR="$MOCK_DIR/systemd"
  export MOCK_LAUNCHD_DIR="$MOCK_DIR/launchd"
  export HOME="$MOCK_DIR"
  export PATH="$BATS_TEST_DIRNAME/mocks:$PATH"
}

teardown() {
  rm -rf "$MOCK_DIR"
}

# --- helpers ---------------------------------------------------------------

run_ctl() {
  run bash "$SCRIPT" "$@"
}

assert_state() { # assert_state <name> <port> <state> — checks the status table
  local name="$1" port="$2" state="$3"
  echo "$output" | grep -Eq "^${name}[[:space:]]+${port}[[:space:]]+${state}$" \
    || fail "expected '$name $port $state' in status output:\n$output"
}

# --- Linux (systemd) branch ------------------------------------------------

@test "Linux: status reports all six proxies stopped initially" {
  export MOCK_OS=Linux
  run_ctl status
  [ "$status" -eq 0 ]
  assert_state anthropic 8787 stopped
  assert_state deepseek 8788 stopped
  assert_state go 8789 stopped
  assert_state gemini-1 8790 stopped
  assert_state gemini-2 8791 stopped
  assert_state gemini-3 8792 stopped
}

@test "Linux: start brings up only the named proxy" {
  export MOCK_OS=Linux
  run_ctl start gemini-1
  [ "$status" -eq 0 ]
  [[ "$output" == *"started gemini-1"* ]]
  run_ctl status
  assert_state gemini-1 8790 running
  assert_state anthropic 8787 stopped
  assert_state deepseek 8788 stopped
  assert_state go 8789 stopped
}

@test "Linux: bare start brings up all proxies" {
  export MOCK_OS=Linux
  run_ctl start
  [ "$status" -eq 0 ]
  run_ctl status
  assert_state anthropic 8787 running
  assert_state deepseek 8788 running
  assert_state go 8789 running
  assert_state gemini-1 8790 running
  assert_state gemini-2 8791 running
  assert_state gemini-3 8792 running
}

@test "Linux: bare stop errors and requires an explicit target" {
  export MOCK_OS=Linux
  run_ctl stop
  [ "$status" -eq 1 ]
  [[ "$output" == *"requires an explicit target"* ]]
}

@test "Linux: stop with targets stops only those proxies" {
  export MOCK_OS=Linux
  run_ctl start
  run_ctl stop deepseek go
  [ "$status" -eq 0 ]
  run_ctl status
  assert_state deepseek 8788 stopped
  assert_state go 8789 stopped
  assert_state anthropic 8787 running
  assert_state gemini-1 8790 running
}

@test "Linux: restart brings a stopped proxy up" {
  export MOCK_OS=Linux
  run_ctl restart anthropic
  [ "$status" -eq 0 ]
  [[ "$output" == *"restarted anthropic"* ]]
  run_ctl status
  assert_state anthropic 8787 running
}

@test "Linux: systemctl is invoked with --user and headroom-proxy-<name>" {
  export MOCK_OS=Linux
  run_ctl start anthropic
  [ "$status" -eq 0 ]
  [ "$(cat "$MOCK_SYSTEMD_DIR/headroom-proxy-anthropic")" = "active" ]
}

# --- Darwin (launchd) branch ----------------------------------------------

@test "Darwin: status reports all six proxies stopped initially" {
  export MOCK_OS=Darwin
  run_ctl status
  [ "$status" -eq 0 ]
  assert_state anthropic 8787 stopped
  assert_state deepseek 8788 stopped
  assert_state go 8789 stopped
  assert_state gemini-1 8790 stopped
  assert_state gemini-2 8791 stopped
  assert_state gemini-3 8792 stopped
}

@test "Darwin: start/stop/restart lifecycle via launchctl" {
  export MOCK_OS=Darwin
  run_ctl start gemini-1
  [ "$status" -eq 0 ]
  [[ "$output" == *"started gemini-1"* ]]
  # launchctl mock records state under the org.nixos service label
  [ "$(cat "$MOCK_LAUNCHD_DIR/org.nixos.headroom-proxy-gemini-1")" = "active" ]
  run_ctl status
  assert_state gemini-1 8790 running
  assert_state anthropic 8787 stopped

  run_ctl stop gemini-1
  [ "$status" -eq 0 ]
  run_ctl status
  assert_state gemini-1 8790 stopped

  run_ctl restart gemini-1
  [ "$status" -eq 0 ]
  [[ "$output" == *"restarted gemini-1"* ]]
  run_ctl status
  assert_state gemini-1 8790 running
}

@test "Darwin: loaded() detects running services via launchctl list" {
  export MOCK_OS=Darwin
  run_ctl start anthropic
  run_ctl status
  assert_state anthropic 8787 running
  assert_state deepseek 8788 stopped
}

# --- cross-cutting ---------------------------------------------------------

@test "unsupported OS exits with an error" {
  export MOCK_OS=FreeBSD
  run_ctl status
  [ "$status" -eq 1 ]
  [[ "$output" == *"unsupported OS"* ]]
}

@test "unknown command prints usage and exits non-zero" {
  export MOCK_OS=Linux
  run_ctl frobnicate
  [ "$status" -eq 1 ]
  [[ "$output" == *"usage: headroomctl"* ]]
}

@test "status, list and no-arg are equivalent" {
  export MOCK_OS=Linux
  run_ctl status
  local expected="$output"
  run_ctl list
  [ "$output" = "$expected" ]
  run_ctl
  [ "$output" = "$expected" ]
}