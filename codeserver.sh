#!/bin/bash

# 使用说明
if [ $# -ne 1 ]; then
    echo "用法: $0 <port>"
    echo "示例: $0 8080"
    exit 1
fi

PORT="$1"
CONFIG_DIR="$HOME/.config/code-server"
CONFIG_FILE="$CONFIG_DIR/config.yaml"

echo "开始安装 code-server..."

# 下载并执行官方安装脚本
curl -O https://raw.githubusercontent.com/coder/code-server/main/install.sh
sh install.sh

echo "首次运行 code-server 以初始化配置文件..."
code-server &>/dev/null &
CODE_PID=$!
sleep 10  # 等待初始化完成
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
systemctl enable --now code-server@"$USER"

echo "安装完成！"
echo "访问地址: https://你的IP:$PORT（自签名证书，可能有浏览器警告）"
echo "登录密码: let'srapewangyue"
