# PortfolioPulse 二进制部署指南

## 🎯 部署架构图

```
服务器 (Ubuntu/CentOS)
├── 端口 80/443 → Nginx (反向代理 + 静态文件服务)
├── 端口 3000 → portfolio_pulse_frontend (Node.js 二进制)
├── 端口 8000 → portfolio_pulse_backend (Rust 二进制)
└── 端口 3306 → MySQL 数据库
```

## 📦 构建二进制文件

### 1. 后端 Rust 二进制文件（简单）
```bash
# 在 backend/ 目录下
cargo build --release

# 生成的文件：
# target/release/portfolio_pulse (Linux)
# target/release/portfolio_pulse.exe (Windows)
```

### 2. 前端 Next.js 二进制文件（需要额外步骤）

#### 方案A: 使用 Next.js Standalone 输出
```bash
# 在 frontend/ 目录下
npm run build

# 生成的文件结构：
frontend/
├── .next/standalone/        # 可直接运行的 Node.js 应用
├── .next/static/           # 静态资源文件
└── public/                 # 公共文件
```

#### 方案B: 打包成单个可执行文件（使用 pkg）
```bash
# 安装 pkg
npm install -g pkg

# 在 frontend/ 目录下，修改 package.json
{
  "name": "portfoliopulse-frontend",
  "bin": "server.js",
  "pkg": {
    "targets": [ "node18-linux-x64" ],
    "outputPath": "dist"
  }
}

# 构建单个可执行文件
npm run build
pkg .

# 生成：portfoliopulse-frontend (单个可执行文件)
```

## 🚀 服务器部署步骤

### 步骤1: 准备服务器环境
```bash
# 更新系统
sudo apt update && sudo apt upgrade -y

# 安装 MySQL（如果需要）
sudo apt install mysql-server -y

# 安装 Nginx（反向代理和静态文件服务）
sudo apt install nginx -y
```

### 步骤2: 上传二进制文件
```bash
# 创建应用目录
sudo mkdir -p /opt/portfoliopulse
sudo chown $USER:$USER /opt/portfoliopulse

# 上传文件到服务器
scp -r backend/target/release/portfolio_pulse user@server:/opt/portfoliopulse/
scp -r frontend/.next/standalone/* user@server:/opt/portfoliopulse/frontend/
scp -r frontend/.next/static user@server:/opt/portfoliopulse/frontend/
scp -r frontend/public user@server:/opt/portfoliopulse/frontend/
```

### 步骤3: 配置环境变量
```bash
# 创建 .env 文件
cat > /opt/portfoliopulse/.env << 'EOF'
NODE_ENV=production
DATABASE_URL=mysql://portfoliopulse:password@localhost:3306/portfolio_pulse
GITHUB_TOKEN=your_github_token
GITHUB_USERNAME=your_username
EOF
```

### 步骤4: 配置 Nginx
```nginx
# /etc/nginx/sites-available/portfoliopulse
server {
    listen 80;
    server_name your-domain.com;

    # 静态文件直接服务
    location /_next/static/ {
        alias /opt/portfoliopulse/frontend/.next/static/;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    location /public/ {
        alias /opt/portfoliopulse/frontend/public/;
        expires 1y;
    }

    # API 请求转发到后端
    location /api/ {
        proxy_pass http://localhost:8000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    # 其他请求转发到前端
    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### 步骤5: 创建启动脚本
```bash
# /opt/portfoliopulse/start.sh
#!/bin/bash
set -e

echo "🚀 Starting PortfolioPulse..."

# 设置环境变量
export NODE_ENV=production
source /opt/portfoliopulse/.env

# 启动后端服务
echo "🦀 Starting backend service..."
cd /opt/portfoliopulse
nohup ./portfolio_pulse > backend.log 2>&1 &
BACKEND_PID=$!
echo $BACKEND_PID > backend.pid

# 等待后端启动
sleep 3

# 启动前端服务
echo "🟢 Starting frontend service..."
cd /opt/portfoliopulse/frontend
nohup node server.js > ../frontend.log 2>&1 &
FRONTEND_PID=$!
echo $FRONTEND_PID > ../frontend.pid

echo "✅ PortfolioPulse started successfully!"
echo "Backend PID: $BACKEND_PID"
echo "Frontend PID: $FRONTEND_PID"
echo "🌐 Access: http://your-domain.com"
```

### 步骤6: 创建服务管理脚本
```bash
# /opt/portfoliopulse/stop.sh
#!/bin/bash
echo "🛑 Stopping PortfolioPulse..."

# 停止前端
if [ -f frontend.pid ]; then
    kill $(cat frontend.pid) 2>/dev/null || true
    rm frontend.pid
fi

# 停止后端
if [ -f backend.pid ]; then
    kill $(cat backend.pid) 2>/dev/null || true
    rm backend.pid
fi

echo "✅ PortfolioPulse stopped!"
```

## 🔄 启动和管理

```bash
# 启动服务
cd /opt/portfoliopulse
chmod +x start.sh stop.sh
./start.sh

# 停止服务
./stop.sh

# 重启服务
./stop.sh && sleep 2 && ./start.sh

# 查看日志
tail -f backend.log
tail -f frontend.log

# 检查服务状态
curl http://localhost:8000/api/health  # 后端健康检查
curl http://localhost:3000              # 前端检查
```

## 📊 监控和维护

### 进程监控
```bash
# 检查进程是否运行
ps aux | grep portfolio_pulse
ps aux | grep "node server.js"

# 查看端口占用
netstat -tulpn | grep :8000
netstat -tulpn | grep :3000
```

### 日志管理
```bash
# 设置日志轮转
sudo cat > /etc/logrotate.d/portfoliopulse << 'EOF'
/opt/portfoliopulse/*.log {
    daily
    rotate 7
    compress
    delaycompress
    copytruncate
    notifempty
}
EOF
```

## 🚀 优化建议

### 1. 使用进程管理器
```bash
# 安装 PM2（推荐）
npm install -g pm2

# PM2 配置文件 ecosystem.config.js
module.exports = {
  apps: [
    {
      name: 'portfoliopulse-frontend',
      script: 'server.js',
      cwd: '/opt/portfoliopulse/frontend',
      env: {
        NODE_ENV: 'production'
      }
    },
    {
      name: 'portfoliopulse-backend',
      script: '/opt/portfoliopulse/portfolio_pulse',
      cwd: '/opt/portfoliopulse'
    }
  ]
};

# 使用 PM2 启动
pm2 start ecosystem.config.js
pm2 save           # 保存配置
pm2 startup         # 开机自启
```

### 2. 系统服务配置
```bash
# 创建 systemd 服务
sudo cat > /etc/systemd/system/portfoliopulse.service << 'EOF'
[Unit]
Description=PortfolioPulse Application
After=network.target mysql.service

[Service]
Type=forking
User=portfoliopulse
WorkingDirectory=/opt/portfoliopulse
ExecStart=/opt/portfoliopulse/start.sh
ExecStop=/opt/portfoliopulse/stop.sh
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# 启用服务
sudo systemctl daemon-reload
sudo systemctl enable portfoliopulse
sudo systemctl start portfoliopulse
```

## 🎯 总结

### 优势
✅ **轻量级**: 没有 Docker 开销
✅ **启动快**: 直接运行二进制文件
✅ **资源占用低**: 适合小型 VPS
✅ **部署简单**: 上传文件即可

### 劣势
❌ **环境依赖**: 需要手动配置服务器环境
❌ **维护复杂**: 需要手动管理进程
❌ **扩展困难**: 难以水平扩展

### 适用场景
- 个人项目或小型应用
- 预算有限的单服务器部署
- 对性能要求较高的场景
- 希望深度控制部署过程
