curl -O https://raw.githubusercontent.com/coder/code-server/main/install.sh
sh install.sh
vim ~/.config/code-server/config.yaml
# 改0.0.0.0:8000，改密码
sudo systemctl enable --now code-server@$USER

sudo -i
passwd moomtong
echo "moomtong ALL=(ALL) ALL" | sudo tee -a /etc/sudoers

sudo ln -s /usr/bin/python3 /usr/bin/python
