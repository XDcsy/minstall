sudo -i
passwd

curl -O https://raw.githubusercontent.com/coder/code-server/main/install.sh
sh install.sh
code-server     # 初始化
openssl req -newkey rsa:4096 -nodes -keyout key.pem -x509 -days 365 -out cert.pem
vim ~/.config/code-server/config.yaml
# 改0.0.0.0:8000，改密码
# 加入两行
# cert: /root/cert.pem
# cert-key: /root/key.pem          
sudo systemctl enable --now code-server@$USER

sudo ln -s /usr/bin/python3 /usr/bin/python

# 在 CodeServer 中，按 Ctrl + , 打开设置页面搜索 default profile，改成 bash
bash
