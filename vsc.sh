curl -O https://raw.githubusercontent.com/coder/code-server/main/install.sh
sh install.sh
vim ~/.config/code-server/config.yaml
# 改0.0.0.0:8000，改密码
sudo systemctl enable --now code-server@$USER
