sudo -i
passwd

curl -O https://raw.githubusercontent.com/coder/code-server/main/install.sh
sh install.sh
code-server     # 初始化
vim ~/.config/code-server/config.yaml
# 改0.0.0.0:443，改密码，改cert: true       
sudo setcap cap_net_bind_service=+ep /usr/lib/code-server/lib/node
sudo systemctl enable --now code-server@$USER

#用firefox访问 https://ip

# =============================================================================
# vscode内
sudo ln -s /usr/bin/python3 /usr/bin/python

# 在 CodeServer 中，打开设置页面搜索 default profile，改成 bash
bash
