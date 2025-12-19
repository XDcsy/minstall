#!/bin/bash

# 使用说明
if [ $# -ne 1 ]; then
    echo "用法: $0 <port>"
    echo "示例: $0 8800"
    exit 1
fi

PORT="$1"
CONFIG_DIR="$HOME/.config/code-server"
CONFIG_FILE="$CONFIG_DIR/config.yaml"
CURRENT_USER=$(whoami)

echo "开始安装 code-server..."

# 检查并安装 wget（如果缺失）
if ! command -v wget &> /dev/null; then
    echo "wget 未找到，正在安装 wget..."
    apt update && apt install -y wget
fi

# 下载并执行官方安装脚本
wget -O install.sh https://code-server.dev/install.sh
sh install.sh
rm -f install.sh  # 清理

echo "首次运行 code-server 以初始化配置文件..."
code-server &>/dev/null &
CODE_PID=$!
sleep 10  # 等待初始化
kill $CODE_PID 2>/dev/null || true
wait $CODE_PID 2>/dev/null || true

echo "修改配置文件: $CONFIG_FILE"

mkdir -p "$CONFIG_DIR"

# 覆盖写入配置
cat > "$CONFIG_FILE" <<EOF
bind-addr: 0.0.0.0:$PORT
auth: password
password: let'srapewangyue
cert: true
EOF

echo "配置文件已更新为："
cat "$CONFIG_FILE"

echo "启用并启动 code-server systemd 服务..."
sudo systemctl enable --now code-server@"$CURRENT_USER"

echo "安装完成！"
echo "访问地址: https://你的IP:$PORT（自签名证书，可能有浏览器警告）"
echo "登录密码: let'srapewangyue"
