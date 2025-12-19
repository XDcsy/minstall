#!/usr/bin/env bash
set -euo pipefail

PORT="${1:-}"
if [[ -z "$PORT" ]]; then
  echo "Usage: $0 <port>"
  exit 1
fi

# 目标用户：sudo 场景用原用户，否则用当前用户
TARGET_USER="${SUDO_USER:-$(id -un)}"
TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"
if [[ -z "$TARGET_HOME" ]]; then
  echo "Failed to detect home for user: $TARGET_USER"
  exit 1
fi

have_cmd() { command -v "$1" >/dev/null 2>&1; }

install_curl_if_needed() {
  if have_cmd curl; then
    return 0
  fi

  echo "[WARN] curl not found, trying to install curl..."

  if have_cmd apt-get; then
    apt-get update -y
    apt-get install -y curl
  elif have_cmd dnf; then
    dnf install -y curl
  elif have_cmd yum; then
    yum install -y curl
  elif have_cmd zypper; then
    zypper --non-interactive install curl
  elif have_cmd pacman; then
    pacman -Sy --noconfirm curl
  else
    echo "[ERROR] curl is required, but no supported package manager found to install it."
    exit 1
  fi
}

echo "[INFO] port=$PORT"
echo "[INFO] target_user=$TARGET_USER"
echo "[INFO] target_home=$TARGET_HOME"

install_curl_if_needed

echo "[INFO] Downloading install.sh via curl..."
curl -fsSL -o install.sh https://raw.githubusercontent.com/coder/code-server/main/install.sh
chmod +x install.sh

echo "[INFO] Running installer..."
sh install.sh

echo "[INFO] Initialize code-server once to generate config dir..."
set +e
sudo -u "$TARGET_USER" -H code-server >/dev/null 2>&1
set -e

CONFIG_DIR="$TARGET_HOME/.config/code-server"
CONFIG_FILE="$CONFIG_DIR/config.yaml"

echo "[INFO] Writing config: $CONFIG_FILE"
mkdir -p "$CONFIG_DIR"
cat > "$CONFIG_FILE" <<EOF
bind-addr: 0.0.0.0:$PORT
auth: password
password: wangyue
cert: true
EOF
chown -R "$TARGET_USER":"$TARGET_USER" "$TARGET_HOME/.config"

echo "[INFO] setcap cap_net_bind_service=+ep /usr/lib/code-server/lib/node"
setcap cap_net_bind_service=+ep /usr/lib/code-server/lib/node

echo "[INFO] systemctl enable --now code-server@$TARGET_USER"
systemctl enable --now "code-server@${TARGET_USER}"

echo "[OK] Done. code-server should be listening on 0.0.0.0:$PORT"
