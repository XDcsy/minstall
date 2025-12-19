#!/usr/bin/env bash
set -euo pipefail

PORT="${1:-}"
if [[ -z "${PORT}" ]]; then
  echo "Usage: $0 <port>"
  exit 1
fi

# 简单校验（你说不用考虑低端口等，我就不做更多限制了）
if ! [[ "${PORT}" =~ ^[0-9]+$ ]]; then
  echo "Error: port must be a number"
  exit 1
fi

# 目标用户：如果是 sudo/root 运行，优先用 SUDO_USER；否则用当前用户
TARGET_USER="${SUDO_USER:-$USER}"
TARGET_HOME="$(eval echo "~${TARGET_USER}")"

PASSWORD="let'srapewangyue"

need_cmd() { command -v "$1" >/dev/null 2>&1; }

install_pkg() {
  local pkg="$1"
  if need_cmd apt-get; then
    apt-get update -y
    DEBIAN_FRONTEND=noninteractive apt-get install -y "$pkg"
  elif need_cmd yum; then
    yum install -y "$pkg"
  elif need_cmd dnf; then
    dnf install -y "$pkg"
  elif need_cmd pacman; then
    pacman -Sy --noconfirm "$pkg"
  elif need_cmd apk; then
    apk add --no-cache "$pkg"
  else
    echo "No supported package manager found to install ${pkg}."
    return 1
  fi
}

download_install_sh() {
  local url="https://raw.githubusercontent.com/coder/code-server/main/install.sh"
  if need_cmd curl; then
    curl -fsSLo install.sh "$url"
  elif need_cmd wget; then
    wget -qO install.sh "$url"
  else
    echo "Neither curl nor wget found. Trying to install one..."
    if install_pkg curl; then
      curl -fsSLo install.sh "$url"
    elif install_pkg wget; then
      wget -qO install.sh "$url"
    else
      echo "Failed to install curl/wget."
      exit 1
    fi
  fi
  chmod +x install.sh
}

run_as_target_user() {
  if [[ "${TARGET_USER}" == "$USER" ]]; then
    "$@"
  else
    sudo -u "${TARGET_USER}" -H "$@"
  fi
}

# 1) 下载并执行官方安装脚本
download_install_sh
sh ./install.sh

# 2) code-server 初始化：运行一次然后结束
#    用 timeout 防止它一直挂着（不同版本行为可能略不同）
if need_cmd timeout; then
  run_as_target_user timeout 5s code-server >/dev/null 2>&1 || true
else
  # 没有 timeout 的话就后台跑一下再杀掉
  run_as_target_user bash -lc 'code-server >/dev/null 2>&1 & echo $! > /tmp/.cs_pid' || true
  sleep 5 || true
  if [[ -f /tmp/.cs_pid ]]; then
    kill "$(cat /tmp/.cs_pid)" >/dev/null 2>&1 || true
    rm -f /tmp/.cs_pid || true
  fi
fi

# 3) 写入配置文件 ~/.config/code-server/config.yaml
CONFIG_DIR="${TARGET_HOME}/.config/code-server"
CONFIG_FILE="${CONFIG_DIR}/config.yaml"
mkdir -p "${CONFIG_DIR}"

cat > "${CONFIG_FILE}" <<EOF
bind-addr: 0.0.0.0:${PORT}
auth: password
password: ${PASSWORD}
cert: true
EOF

chown -R "${TARGET_USER}:${TARGET_USER}" "${TARGET_HOME}/.config"

# 4) setcap
#    你给的路径按原样执行；若系统没有该文件会报错退出（符合你“按逻辑来”）
setcap cap_net_bind_service=+ep /usr/lib/code-server/lib/node

# 5) systemctl enable --now code-server@$USER
#    这里要启用目标用户实例
systemctl enable --now "code-server@${TARGET_USER}"

echo "Done."
echo "Config written to: ${CONFIG_FILE}"
echo "Listening on: 0.0.0.0:${PORT}"
echo "NOTE: Remember to set PASSWORD in this script (currently: CHANGE_ME)."
