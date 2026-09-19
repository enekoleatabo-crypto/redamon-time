#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

CREDENTIALS_FILE="/workspaces/.redamon-admin-credentials"

require_command() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Required command not found: $1" >&2
    exit 1
  }
}

load_credentials() {
  if [[ -f "$CREDENTIALS_FILE" ]]; then
    # shellcheck disable=SC1090
    source "$CREDENTIALS_FILE"
  fi

  ADMIN_NAME="${REDAMON_ADMIN_NAME:-${ADMIN_NAME:-Codespace Admin}}"
  ADMIN_EMAIL="${REDAMON_ADMIN_EMAIL:-${ADMIN_EMAIL:-admin@codespace.local}}"
  ADMIN_PASSWORD="${REDAMON_ADMIN_PASSWORD:-${ADMIN_PASSWORD:-}}"

  if [[ -z "$ADMIN_PASSWORD" ]]; then
    ADMIN_PASSWORD="$(openssl rand -hex 16)"
  fi

  if (( ${#ADMIN_PASSWORD} < 12 )); then
    echo "REDAMON_ADMIN_PASSWORD must contain at least 12 characters." >&2
    exit 1
  fi
}

save_credentials() {
  mkdir -p /workspaces
  umask 077
  printf 'ADMIN_NAME=%q\nADMIN_EMAIL=%q\nADMIN_PASSWORD=%q\n' \
    "$ADMIN_NAME" "$ADMIN_EMAIL" "$ADMIN_PASSWORD" > "$CREDENTIALS_FILE"
  chmod 600 "$CREDENTIALS_FILE"
}

admin_input() {
  # redamon.sh create-admin asks for name, email, password, and confirmation.
  printf '%s\n%s\n%s\n%s\n' \
    "$ADMIN_NAME" "$ADMIN_EMAIL" "$ADMIN_PASSWORD" "$ADMIN_PASSWORD"
}

ensure_admin() {
  load_credentials
  save_credentials
  echo "Ensuring RedAmon admin account: $ADMIN_EMAIL"
  admin_input | ./redamon.sh create-admin
}

install_redamon() {
  require_command docker
  require_command openssl
  load_credentials
  save_credentials

  echo "Installing the lightweight RedAmon stack (without GVM or Knowledge Base)..."
  # The installer may ask for the initial admin at the end; provide the same
  # saved values non-interactively. The command is intentionally the lightweight
  # install and does not pass --gvm or --kbase.
  admin_input | ./redamon.sh install

  ensure_admin
}

start_redamon() {
  require_command docker
  require_command openssl
  load_credentials
  save_credentials

  echo "Starting RedAmon..."
  ./redamon.sh up
  ensure_admin
}

case "${1:-start}" in
  install)
    install_redamon
    ;;
  start|up)
    start_redamon
    ;;
  ensure-admin)
    ensure_admin
    ;;
  status)
    ./redamon.sh status
    ;;
  *)
    echo "Usage: $0 [install|start|up|ensure-admin|status]" >&2
    exit 2
    ;;
esac
