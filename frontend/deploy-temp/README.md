# PortfolioPulse Frontend - 部署说明

## 📦 部署包内容

```
portfoliopulse-frontend/
├── server.js              # Next.js 服务器入口
├── .next/                 # 构建产物
│   ├── static/           # 静态资源
│   └── ...
├── public/               # 公共资源
├── start.sh              # 启动脚本
├── stop.sh               # 停止脚本
├── portfoliopulse-frontend.service  # systemd 服务文件
└── README.md             # 本文件
```

## 🚀 快速部署（5 步完成）

### 1. 上传文件到服务器

```bash
# 在本地执行（上传 zip 文件）
scp portfoliopulse-frontend.zip user@your-server:~/opt/
```

### 2. 在服务器上解压

```bash
cd ~/opt
unzip portfoliopulse-frontend.zip
cd portfoliopulse-frontend
```

### 3. 设置执行权限

```bash
chmod +x start.sh stop.sh
```

### 4. 启动应用

```bash
# 方式 A: 直接运行（测试）
./start.sh

# 方式 B: 后台运行
nohup ./start.sh > output.log 2>&1 &

# 方式 C: 使用 PM2（推荐）
npm install -g pm2
pm2 start server.js --name portfoliopulse-frontend
pm2 save
pm2 startup
```

### 5. 验证部署

```bash
# 检查应用是否运行
curl http://localhost:3000

# 查看进程
ps aux | grep node
```

## 🔧 环境要求

- **Node.js**: >= 18.17.0（检查：`node -v`）
- **系统**: Ubuntu 22.04 LTS
- **端口**: 3000（确保未被占用）

## 📝 systemd 服务配置（生产环境推荐）

### 1. 编辑服务文件

```bash
# 修改用户名
sudo nano portfoliopulse-frontend.service
# 将 User=YOUR_USERNAME 改为你的实际用户名
```

### 2. 安装服务

```bash
# 复制服务文件
sudo cp portfoliopulse-frontend.service /etc/systemd/system/

# 重载配置
sudo systemctl daemon-reload

# 启动服务
sudo systemctl start portfoliopulse-frontend

# 开机自启
sudo systemctl enable portfoliopulse-frontend

# 查看状态
sudo systemctl status portfoliopulse-frontend
```

### 3. 管理服务

```bash
# 启动
sudo systemctl start portfoliopulse-frontend

# 停止
sudo systemctl stop portfoliopulse-frontend

# 重启
sudo systemctl restart portfoliopulse-frontend

# 查看日志
sudo journalctl -u portfoliopulse-frontend -f
```

## 🌐 Nginx 反向代理（可选）

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## 🔄 更新部署

```bash
# 1. 停止服务
sudo systemctl stop portfoliopulse-frontend  # 或 pm2 stop portfoliopulse-frontend

# 2. 备份旧版本（可选）
mv ~/opt/portfoliopulse-frontend ~/opt/portfoliopulse-frontend.backup.$(date +%Y%m%d)

# 3. 上传并解压新版本
cd ~/opt
unzip -o portfoliopulse-frontend.zip

# 4. 设置权限
cd portfoliopulse-frontend
chmod +x start.sh stop.sh

# 5. 重启服务
sudo systemctl start portfoliopulse-frontend  # 或 pm2 restart portfoliopulse-frontend
```

## 🐛 故障排查

### 端口被占用

```bash
# 查看占用端口的进程
sudo lsof -i :3000

# 终止进程
sudo kill -9 <PID>
```

### Node.js 版本过低

```bash
# 安装 Node.js 18
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# 验证版本
node -v
```

### 查看应用日志

```bash
# systemd 服务日志
sudo journalctl -u portfoliopulse-frontend -n 100 --no-pager

# PM2 日志
pm2 logs portfoliopulse-frontend

# 直接运行的日志
tail -f output.log
```

## 📊 性能监控

```bash
# 使用 PM2 监控
pm2 monit

# 查看资源使用
pm2 show portfoliopulse-frontend
```

## 📞 支持

- 项目地址: https://github.com/wyw121/PortfolioPulse
- 文档: 查看项目 README
