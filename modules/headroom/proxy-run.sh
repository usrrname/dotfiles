# Execs the headroom proxy after ensuring the CLI is installed. Systemd's
# ExecStart for each configured proxy instance (Linux only; macOS uses its
# own varlock-aware wrapper in hosts/mac-jenc).
#
# Env vars: PROXY_ARGS (plus ensure-installed.sh's HEADROOM_VERSION, UV_BIN_DIR)
# shellcheck disable=SC2086
exec headroom proxy $PROXY_ARGS
