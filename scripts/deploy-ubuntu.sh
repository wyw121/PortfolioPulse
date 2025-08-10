#!/bin/bash

# PortfolioPulse Ubuntu 22.04 LTS 部署脚本

set -e

echo "🚀 开始部署 PortfolioPulse 到 Ubuntu 22.04 LTS..."

# 检查是否为 root 用户
if [ "$EUID" -ne 0 ]; then
  echo "❌ 请使用 root 权限运行此脚本"
  exit 1
fi

# 更新系统包
echo "📦 更新系统包..."
apt update && apt upgrade -y

# 安装必要的系统依赖
echo "🔧 安装系统依赖..."
apt install -y \
  curl \
  wget \
  git \
  build-essential \
  pkg-config \
  libssl-dev \
  ca-certificates \
  gnupg \
  lsb-release \
  ufw

# 安装 Docker
echo "🐳 安装 Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt update
    apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    systemctl enable docker
    systemctl start docker
else
    echo "✅ Docker 已安装"
fi

# 安装 Docker Compose
echo "🐙 安装 Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
else
    echo "✅ Docker Compose 已安装"
fi

# 安装 Node.js (用于本地开发)
echo "📦 安装 Node.js..."
if ! command -v node &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
    apt install -y nodejs
else
    echo "✅ Node.js 已安装"
fi

# 安装 Rust (用于本地开发)
echo "🦀 安装 Rust..."
if ! command -v rustc &> /dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source $HOME/.cargo/env
    rustup update
else
    echo "✅ Rust 已安装"
fi

# 创建应用目录
echo "📁 创建应用目录..."
APP_DIR="/opt/portfoliopulse"
mkdir -p $APP_DIR
cd $APP_DIR

# 克隆项目（如果不存在）
if [ ! -d ".git" ]; then
    echo "📥 克隆项目代码..."
    git clone https://github.com/user/PortfolioPulse.git .
else
    echo "🔄 更新项目代码..."
    git pull origin main
fi

# 复制环境变量模板
echo "⚙️  配置环境变量..."
if [ ! -f ".env" ]; then
    cp .env.example .env
    echo "📝 请编辑 .env 文件配置您的环境变量"
    echo "   vim .env"
    echo ""
    echo "重要配置项："
    echo "- DATABASE_URL: MySQL 数据库连接"
    echo "- GITHUB_TOKEN: GitHub API 令牌"
    echo "- GITHUB_USERNAME: GitHub 用户名"
    echo ""
fi

# 设置防火墙
echo "🔒 配置防火墙..."
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 3000/tcp  # 前端
ufw allow 8000/tcp  # 后端
ufw --force enable

# 创建 systemd 服务文件
echo "🔧 创建系统服务..."
cat > /etc/systemd/system/portfoliopulse.service << EOF
[Unit]
Description=PortfolioPulse Application
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=$APP_DIR
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOF

# 启用服务
systemctl daemon-reload
systemctl enable portfoliopulse.service

# 创建日志目录
mkdir -p $APP_DIR/logs
chown -R 1001:1001 $APP_DIR/logs

# 创建 nginx 配置目录
mkdir -p $APP_DIR/nginx/conf.d

# 创建基础 nginx 配置
cat > $APP_DIR/nginx/nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    upstream frontend {
        server frontend:3000;
    }

    upstream backend {
        server backend:8000;
    }

    include /etc/nginx/conf.d/*.conf;
}
EOF

# 创建站点配置
cat > $APP_DIR/nginx/conf.d/default.conf << 'EOF'
server {
    listen 80;
    server_name _;

    # 前端代理
    location / {
        proxy_pass http://frontend;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # API 代理
    location /api/ {
        proxy_pass http://backend/api/;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

echo "✅ PortfolioPulse 部署脚本执行完成！"
echo ""
echo "接下来的步骤："
echo "1. 编辑环境配置: vim $APP_DIR/.env"
echo "2. 启动应用: systemctl start portfoliopulse"
echo "3. 检查状态: systemctl status portfoliopulse"
echo "4. 查看日志: docker-compose logs -f"
echo ""
echo "应用将在以下端口运行："
echo "- 前端: http://localhost:3000"
echo "- 后端: http://localhost:8000"
echo "- Nginx: http://localhost:80"
echo ""
echo "🎉 部署完成！"
