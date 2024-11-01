cd ~
sudo apt-get update
sudo apt-get install python3-pip -y

curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - &&\
sudo apt-get install -y nodejs

git clone https://github.com/josStorer/RWKV-Runner
python3 -m pip install -r RWKV-Runner/backend-python/requirements.txt
cd RWKV-Runner/frontend
npm ci
npm run build
cd ..

if [ ! -d models ]; then
    mkdir models
fi

wget -N https://huggingface.co/BlinkDL/rwkv-6-world/resolve/main/RWKV-x060-World-14B-v2.1-20240719-ctx4096.pth -P models/

sudo apt-get install -y ubuntu-drivers-common
# ubuntu-drivers devices
sudo apt-get install -y nvidia-driver-535

echo "install success"
