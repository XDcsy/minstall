sudo -i
passwd

curl -O https://raw.githubusercontent.com/coder/code-server/main/install.sh
sh install.sh
code-server     # 初始化
vim ~/.config/code-server/config.yaml
# 改0.0.0.0:8000，改密码
sudo systemctl enable --now code-server@$USER

sudo ln -s /usr/bin/python3 /usr/bin/python
