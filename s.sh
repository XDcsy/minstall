cd ~/RWKV-Runner
python3 ./backend-python/main.py --webui --host 0.0.0.0 &
until nc -z 127.0.0.1 8000 2>/dev/null; do
    echo 'waiting for server...'
    sleep 2
done
echo "Server is ready, deploying model"
curl http://127.0.0.1:8000/switch-model -X POST -H "Content-Type: application/json" -d '{"model":"../models/RWKV-x060-World-14B-v2.1-20240719-ctx4096.pth","strategy":"cuda:0 fp16 *31 -> cuda:1 fp16","deploy":"true"}'
echo "Model deployed"
