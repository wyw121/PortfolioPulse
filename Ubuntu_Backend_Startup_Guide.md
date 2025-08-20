# 🚀 PortfolioPulse 后端 Ubuntu 启动指南

## 📋 前提条件

确保你的Ubuntu系统已安装：
- MySQL 数据库 (端口 3306)
- 必要的运行库

## 🎯 方法一：直接启动 (最简单)

### 1. 上传文件到服务器
```bash
# 创建应用目录
mkdir -p ~/portfoliopulse
cd ~/portfoliopulse

# 上传你编译好的二进制文件：portfolio_pulse_backend
# 上传环境配置文件：.env
```

### 2. 准备环境配置
创建 `.env` 文件：
```bash
cat > .env << 'EOF'
DATABASE_URL=mysql://root:@localhost/portfolio_pulse
RUST_LOG=info
SERVER_HOST=0.0.0.0
SERVER_PORT=8000
GITHUB_TOKEN=
BLOG_ADMIN_USER=admin
BLOG_ADMIN_TOKEN=admin_token_123
EOF
```

### 3. 启动后端
```bash
# 设置执行权限
chmod +x portfolio_pulse_backend

# 直接启动
./portfolio_pulse_backend

# 或者后台启动
nohup ./portfolio_pulse_backend > backend.log 2>&1 &
echo $! > backend.pid
```

### 4. 检查运行状态
```bash
# 检查进程
ps aux | grep portfolio_pulse

# 检查端口
netstat -tulpn | grep :8000

# 测试访问
curl http://localhost:8000
```

## 🔧 方法二：使用 systemd 服务 (推荐生产环境)

### 1. 创建系统用户和目录
```bash
# 创建应用用户
sudo useradd -r -s /bin/false portfolio-pulse

# 创建应用目录
sudo mkdir -p /opt/portfolio-pulse
sudo mkdir -p /var/log/portfolio-pulse

# 上传二进制文件到 /opt/portfolio-pulse/
sudo cp portfolio_pulse_backend /opt/portfolio-pulse/
sudo chmod +x /opt/portfolio-pulse/portfolio_pulse_backend
sudo chown -R portfolio-pulse:portfolio-pulse /opt/portfolio-pulse
sudo chown -R portfolio-pulse:portfolio-pulse /var/log/portfolio-pulse
```

### 2. 创建 systemd 服务
```bash
sudo tee /etc/systemd/system/portfolio-pulse.service > /dev/null << 'EOF'
[Unit]
Description=Portfolio Pulse Backend Service
After=network.target mysql.service

[Service]
Type=simple
User=portfolio-pulse
Group=portfolio-pulse
WorkingDirectory=/opt/portfolio-pulse
ExecStart=/opt/portfolio-pulse/portfolio_pulse_backend
Restart=always
RestartSec=5

# 环境变量
Environment=RUST_LOG=info
Environment=DATABASE_URL=mysql://root:@localhost:3306/portfolio_pulse
Environment=SERVER_HOST=0.0.0.0
Environment=SERVER_PORT=8000

# 日志配置
StandardOutput=append:/var/log/portfolio-pulse/stdout.log
StandardError=append:/var/log/portfolio-pulse/stderr.log

[Install]
WantedBy=multi-user.target
EOF
```

### 3. 启动和管理服务
```bash
# 重新加载 systemd
sudo systemctl daemon-reload

# 启用自动启动
sudo systemctl enable portfolio-pulse

# 启动服务
sudo systemctl start portfolio-pulse

# 查看状态
sudo systemctl status portfolio-pulse

# 查看日志
sudo journalctl -u portfolio-pulse -f
```

## 🌐 方法三：配置 Nginx 反向代理 (可选)

### 1. 安装 Nginx
```bash
sudo apt update
sudo apt install nginx
```

### 2. 配置站点
```bash
sudo tee /etc/nginx/sites-available/portfolio-pulse > /dev/null << 'EOF'
server {
    listen 80;
    server_name your-domain.com;  # 替换为你的域名或服务器IP

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /api/ {
        proxy_pass http://127.0.0.1:8000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

# 启用站点
sudo ln -s /etc/nginx/sites-available/portfolio-pulse /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# 测试配置
sudo nginx -t

# 重启 Nginx
sudo systemctl restart nginx
```

## 🗄️ 数据库设置

### 1. 创建数据库
```bash
mysql -u root -p << 'EOF'
CREATE DATABASE IF NOT EXISTS portfolio_pulse;
USE portfolio_pulse;
-- 这里会自动创建表，因为后端会处理数据库迁移
EOF
```

## 🔍 故障排查

### 常见问题和解决方案

1. **端口 8000 被占用**
```bash
# 查看占用进程
sudo lsof -i :8000
# 终止进程
sudo kill -9 PID
```

2. **数据库连接失败**
```bash
# 检查 MySQL 服务
sudo systemctl status mysql
# 启动 MySQL
sudo systemctl start mysql
```

3. **权限问题**
```bash
# 检查文件权限
ls -la /opt/portfolio-pulse/
# 重新设置权限
sudo chown -R portfolio-pulse:portfolio-pulse /opt/portfolio-pulse
```

4. **查看详细日志**
```bash
# systemd 服务日志
sudo journalctl -u portfolio-pulse -f

# 或直接查看日志文件
sudo tail -f /var/log/portfolio-pulse/stdout.log
sudo tail -f /var/log/portfolio-pulse/stderr.log
```

## 📋 管理命令总结

### systemd 服务管理
```bash
sudo systemctl start portfolio-pulse     # 启动
sudo systemctl stop portfolio-pulse      # 停止
sudo systemctl restart portfolio-pulse   # 重启
sudo systemctl status portfolio-pulse    # 状态
sudo systemctl enable portfolio-pulse    # 开机自启
sudo systemctl disable portfolio-pulse   # 取消自启
```

### 手动进程管理
```bash
# 启动后台进程
nohup ./portfolio_pulse_backend > backend.log 2>&1 &
echo $! > backend.pid

# 停止进程
kill $(cat backend.pid)

# 查看日志
tail -f backend.log
```

## ✅ 验证部署成功

访问以下地址确认服务正常：
- 直接访问：`http://your-server-ip:8000`
- 通过 Nginx：`http://your-server-ip` 或 `http://your-domain.com`

如果看到 API 响应或应用页面，说明部署成功！
