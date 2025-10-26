# Ubuntu 22.04 服务器部署指南

## 📦 部署包已准备好

文件名: `portfoliopulse-frontend.zip`
位置: `d:\repositories\PortfolioPulse\frontend\portfoliopulse-frontend.zip`

## 🚀 服务器部署步骤（完整版）

### 步骤 1: 上传 ZIP 文件

将 `portfoliopulse-frontend.zip` 上传到服务器的 `~/opt/` 目录

```bash
# 方式A: 使用 scp（在本地 Windows 执行）
scp d:\repositories\PortfolioPulse\frontend\portfoliopulse-frontend.zip username@your-server:~/opt/

# 方式B: 使用 SFTP 工具（如 FileZilla、WinSCP）
# 上传到: /home/username/opt/
```

### 步骤 2: SSH 连接到服务器

```bash
ssh username@your-server
```

### 步骤 3: 解压部署包

```bash
# 进入目录
cd ~/opt

# 解压文件
unzip portfoliopulse-frontend.zip

# 进入项目目录
cd portfoliopulse-frontend

# 查看文件结构
ls -la
```

预期看到的文件结构：
```
portfoliopulse-frontend/
├── server.js                            # Next.js 服务器入口
├── .next/                               # 构建产物
│   ├── static/                         # 静态资源
│   ├── server/                         # 服务端代码
│   └── ...
├── node_modules/                        # 依赖（已包含）
├── public/                              # 公共资源
├── start.sh                             # 启动脚本
├── stop.sh                              # 停止脚本
├── portfoliopulse-frontend.service      # systemd 服务文件
└── README.md                            # 部署说明
```

### 步骤 4: 设置执行权限

```bash
chmod +x start.sh stop.sh
```

### 步骤 5A: 方式一 - 直接启动（测试用）

```bash
# 直接运行
./start.sh

# 或者后台运行
nohup ./start.sh > output.log 2>&1 &

# 查看日志
tail -f output.log
```

测试访问：
```bash
curl http://localhost:3000
```

停止应用：
```bash
./stop.sh
# 或者
pkill -f "node server.js"
```

### 步骤 5B: 方式二 - 使用 PM2（推荐）

PM2 是 Node.js 进程管理器，推荐用于生产环境。

```bash
# 1. 安装 PM2（如果还没安装）
sudo npm install -g pm2

# 2. 启动应用
pm2 start server.js --name portfoliopulse-frontend

# 3. 设置开机自启
pm2 startup
# 执行上面命令输出的命令（通常是 sudo env PATH=... 开头）

pm2 save

# 4. 查看状态
pm2 status

# 5. 查看日志
pm2 logs portfoliopulse-frontend

# 6. 实时监控
pm2 monit
```

PM2 常用命令：
```bash
pm2 start portfoliopulse-frontend      # 启动
pm2 stop portfoliopulse-frontend       # 停止
pm2 restart portfoliopulse-frontend    # 重启
pm2 delete portfoliopulse-frontend     # 删除
pm2 logs portfoliopulse-frontend       # 查看日志
pm2 show portfoliopulse-frontend       # 查看详情
```

### 步骤 5C: 方式三 - 使用 systemd（系统服务）

```bash
# 1. 编辑服务文件（修改用户名）
nano portfoliopulse-frontend.service
# 将 User=YOUR_USERNAME 改为你的实际用户名
# 保存: Ctrl+O, Enter; 退出: Ctrl+X

# 2. 复制服务文件
sudo cp portfoliopulse-frontend.service /etc/systemd/system/

# 3. 重载 systemd
sudo systemctl daemon-reload

# 4. 启动服务
sudo systemctl start portfoliopulse-frontend

# 5. 查看状态
sudo systemctl status portfoliopulse-frontend

# 6. 设置开机自启
sudo systemctl enable portfoliopulse-frontend

# 7. 查看日志
sudo journalctl -u portfoliopulse-frontend -f
```

systemd 常用命令：
```bash
sudo systemctl start portfoliopulse-frontend    # 启动
sudo systemctl stop portfoliopulse-frontend     # 停止
sudo systemctl restart portfoliopulse-frontend  # 重启
sudo systemctl status portfoliopulse-frontend   # 状态
sudo journalctl -u portfoliopulse-frontend -n 100  # 查看最近100行日志
```

## 🔧 环境检查

### 检查 Node.js 版本

```bash
node -v
# 应该显示 >= v18.17.0
```

如果版本过低，安装 Node.js 18：
```bash
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
node -v
```

### 检查端口 3000

```bash
# 查看端口是否被占用
sudo lsof -i :3000

# 如果被占用，终止进程
sudo kill -9 <PID>
```

## 🌐 配置 Nginx 反向代理（可选）

如果你想通过域名访问，需要配置 Nginx。

### 1. 安装 Nginx

```bash
sudo apt update
sudo apt install nginx -y
```

### 2. 创建配置文件

```bash
sudo nano /etc/nginx/sites-available/portfoliopulse
```

粘贴以下配置：
```nginx
server {
    listen 80;
    server_name your-domain.com www.your-domain.com;

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

### 3. 启用配置

```bash
# 创建符号链接
sudo ln -s /etc/nginx/sites-available/portfoliopulse /etc/nginx/sites-enabled/

# 测试配置
sudo nginx -t

# 重启 Nginx
sudo systemctl restart nginx
```

### 4. 配置 HTTPS（使用 Let's Encrypt）

```bash
# 安装 Certbot
sudo apt install certbot python3-certbot-nginx -y

# 获取证书
sudo certbot --nginx -d your-domain.com -d www.your-domain.com

# 自动续期
sudo systemctl enable certbot.timer
```

## 🔄 更新部署

当你需要更新应用时：

```bash
# 1. 停止应用
pm2 stop portfoliopulse-frontend
# 或
sudo systemctl stop portfoliopulse-frontend

# 2. 备份旧版本（可选）
mv ~/opt/portfoliopulse-frontend ~/opt/portfoliopulse-frontend.backup.$(date +%Y%m%d_%H%M%S)

# 3. 上传新的 ZIP 文件到 ~/opt/

# 4. 解压新版本
cd ~/opt
unzip -o portfoliopulse-frontend.zip
cd portfoliopulse-frontend
chmod +x start.sh stop.sh

# 5. 重启应用
pm2 restart portfoliopulse-frontend
# 或
sudo systemctl restart portfoliopulse-frontend
```

## 🐛 故障排查

### 应用无法启动

```bash
# 查看详细日志
pm2 logs portfoliopulse-frontend --lines 100
# 或
sudo journalctl -u portfoliopulse-frontend -n 100 --no-pager
```

### 端口被占用

```bash
# 查找占用端口的进程
sudo lsof -i :3000

# 终止进程
sudo kill -9 <PID>
```

### 权限问题

```bash
# 确保文件所有权正确
sudo chown -R $USER:$USER ~/opt/portfoliopulse-frontend

# 确保脚本可执行
chmod +x ~/opt/portfoliopulse-frontend/start.sh
chmod +x ~/opt/portfoliopulse-frontend/stop.sh
```

### 检查应用状态

```bash
# 查看进程
ps aux | grep "node server.js"

# 测试应用响应
curl http://localhost:3000
curl -I http://localhost:3000

# 查看端口监听
sudo netstat -tlnp | grep 3000
```

## 📊 性能监控

### 使用 PM2 监控

```bash
pm2 monit                              # 实时监控
pm2 show portfoliopulse-frontend       # 详细信息
pm2 list                               # 进程列表
```

### 系统资源监控

```bash
htop                    # 查看系统资源
df -h                   # 磁盘使用
free -h                 # 内存使用
```

## 📝 总结 - 推荐流程

最简单的部署流程（推荐新手）：

```bash
# 1. 上传文件
# 使用 WinSCP 或 scp 上传 portfoliopulse-frontend.zip 到 ~/opt/

# 2. 解压
cd ~/opt
unzip portfoliopulse-frontend.zip
cd portfoliopulse-frontend

# 3. 设置权限
chmod +x start.sh stop.sh

# 4. 使用 PM2 启动（最推荐）
sudo npm install -g pm2
pm2 start server.js --name portfoliopulse-frontend
pm2 startup
pm2 save

# 5. 验证
pm2 status
curl http://localhost:3000

# 6. （可选）配置 Nginx 反向代理
```

完成！你的应用现在应该运行在 `http://your-server-ip:3000`

## 📞 支持

如遇问题，请查看：
- 日志文件: `pm2 logs` 或 `sudo journalctl -u portfoliopulse-frontend`
- 项目地址: https://github.com/wyw121/PortfolioPulse
