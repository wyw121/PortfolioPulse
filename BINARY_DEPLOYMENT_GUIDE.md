# 🚀 PortfolioPulse 二进制部署指南

## 📋 部署架构

```
Ubuntu 服务器
├── 端口 3000 → 前端服务 (Node.js)
├── 端口 8000 → 后端服务 (Rust 二进制)
├── 端口 3306 → MySQL 数据库
└── 公网IP: 43.138.183.31
```

## 🎯 部署文件结构

部署包应包含以下文件：
```
/opt/portfoliopulse/
├── portfolio_pulse_backend    # 后端二进制文件
├── server.js                  # 前端服务器
├── .next/                     # Next.js 构建产物
├── public/                    # 静态资源
├── package.json               # Node.js 依赖信息
├── start.sh                   # 启动脚本
├── start_simple.sh           # 简化启动脚本
├── stop.sh                   # 停止脚本
├── status.sh                 # 状态检查脚本
└── .env                      # 环境变量配置
```

## 🛠️ 服务器环境准备

### 1. 安装必要依赖
```bash
# 更新系统
sudo apt update && sudo apt upgrade -y

# 安装运行时依赖
sudo apt install -y mysql-server nodejs npm curl wget

# 启动MySQL
sudo systemctl start mysql
sudo systemctl enable mysql
```

### 2. 配置MySQL数据库
```bash
# 设置MySQL（可选）
sudo mysql_secure_installation

# 创建数据库
mysql -u root -p << 'EOF'
CREATE DATABASE IF NOT EXISTS portfolio_pulse CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
SHOW DATABASES;
EXIT;
EOF
```

### 3. 配置防火墙
```bash
# 开放必要端口
sudo ufw allow 22    # SSH
sudo ufw allow 80    # HTTP
sudo ufw allow 443   # HTTPS
sudo ufw allow 3000  # 前端
sudo ufw allow 8000  # 后端
sudo ufw enable
```

## 📦 部署步骤

### 1. 上传文件
```bash
# 创建部署目录
sudo mkdir -p /opt/portfoliopulse
sudo chown $USER:$USER /opt/portfoliopulse

# 上传部署包（在本地执行）
scp -r ./deploy-package/* user@43.138.183.31:/opt/portfoliopulse/

# 或使用rsync
rsync -avz --progress ./deploy-package/ user@43.138.183.31:/opt/portfoliopulse/
```

### 2. 设置权限
```bash
cd /opt/portfoliopulse

# 设置执行权限
chmod +x portfolio_pulse_backend
chmod +x *.sh
```

### 3. 配置环境变量
```bash
# 创建环境配置文件
cat > .env << 'EOF'
DATABASE_URL=mysql://root:@localhost:3306/portfolio_pulse
RUST_LOG=info
SERVER_HOST=0.0.0.0
SERVER_PORT=8000
NODE_ENV=production
PORT=3000
HOSTNAME=0.0.0.0
NEXT_PUBLIC_API_URL=http://43.138.183.31:8000
EOF
```

### 4. 启动服务
```bash
# 使用完整启动脚本
./start.sh

# 或使用简化启动脚本
./start_simple.sh
```

## 🔧 管理脚本说明

### start.sh - 完整启动脚本
- 包含详细的检查和状态输出
- 自动处理端口冲突
- 完整的健康检查
- 彩色输出和错误处理

### start_simple.sh - 简化启动脚本
- 快速启动，适合日常使用
- 基本的服务管理
- 代码简洁明了

### stop.sh - 停止服务脚本
```bash
#!/bin/bash
echo "🛑 停止 PortfolioPulse 服务..."

# 停止后端
if [ -f backend.pid ]; then
    kill $(cat backend.pid) 2>/dev/null || true
    rm backend.pid
    echo "✅ 后端服务已停止"
fi

# 停止前端
if [ -f frontend.pid ]; then
    kill $(cat frontend.pid) 2>/dev/null || true
    rm frontend.pid
    echo "✅ 前端服务已停止"
fi

echo "🎉 所有服务已停止"
```

### status.sh - 状态检查脚本
```bash
#!/bin/bash
echo "📊 PortfolioPulse 服务状态"

# 检查后端
if [ -f backend.pid ] && kill -0 $(cat backend.pid) 2>/dev/null; then
    echo "✅ 后端服务: 运行中 (PID: $(cat backend.pid))"
    echo "   访问地址: http://43.138.183.31:8000"
else
    echo "❌ 后端服务: 未运行"
fi

# 检查前端
if [ -f frontend.pid ] && kill -0 $(cat frontend.pid) 2>/dev/null; then
    echo "✅ 前端服务: 运行中 (PID: $(cat frontend.pid))"
    echo "   访问地址: http://43.138.183.31:3000"
else
    echo "❌ 前端服务: 未运行"
fi

# 检查端口
echo "📋 端口状态:"
netstat -tulpn | grep -E ":(3000|8000|3306) " || echo "   无相关端口监听"
```

## 🌐 访问地址

部署完成后，可通过以下地址访问：

- **前端应用**: http://43.138.183.31:3000
- **后端API**: http://43.138.183.31:8000
- **完整应用**: http://43.138.183.31:3000 (推荐)

## 📋 常用管理命令

```bash
# 启动服务
./start.sh

# 停止服务
./stop.sh

# 查看状态
./status.sh

# 查看日志
tail -f backend.log    # 后端日志
tail -f frontend.log   # 前端日志

# 重启服务
./stop.sh && ./start.sh

# 查看进程
ps aux | grep portfolio

# 查看端口
netstat -tulpn | grep -E ":(3000|8000)"
```

## 🔍 故障排查

### 常见问题

1. **后端启动失败**
   ```bash
   # 查看后端日志
   tail -f backend.log

   # 检查数据库连接
   mysql -u root -e "USE portfolio_pulse;"

   # 检查端口占用
   netstat -tulpn | grep :8000
   ```

2. **前端启动失败**
   ```bash
   # 查看前端日志
   tail -f frontend.log

   # 检查Node.js版本
   node --version

   # 检查端口占用
   netstat -tulpn | grep :3000
   ```

3. **数据库连接问题**
   ```bash
   # 启动MySQL
   sudo systemctl start mysql

   # 检查MySQL状态
   sudo systemctl status mysql

   # 重新创建数据库
   mysql -u root -e "CREATE DATABASE IF NOT EXISTS portfolio_pulse;"
   ```

4. **防火墙问题**
   ```bash
   # 检查防火墙状态
   sudo ufw status

   # 开放端口
   sudo ufw allow 3000
   sudo ufw allow 8000
   ```

## 🔄 更新部署

更新应用时，按以下步骤操作：

```bash
# 1. 停止现有服务
./stop.sh

# 2. 备份当前版本
cp portfolio_pulse_backend portfolio_pulse_backend.backup.$(date +%Y%m%d_%H%M%S)

# 3. 上传新版本
# (在本地执行) scp new_files user@server:/opt/portfoliopulse/

# 4. 设置权限
chmod +x portfolio_pulse_backend

# 5. 启动新版本
./start.sh
```

## 📈 监控和维护

### 设置系统服务（可选）
如需开机自启动，可创建systemd服务：

```bash
# 创建服务文件
sudo tee /etc/systemd/system/portfoliopulse.service > /dev/null << 'EOF'
[Unit]
Description=PortfolioPulse Application
After=network.target mysql.service

[Service]
Type=forking
User=ubuntu
WorkingDirectory=/opt/portfoliopulse
ExecStart=/opt/portfoliopulse/start.sh
ExecStop=/opt/portfoliopulse/stop.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# 启用服务
sudo systemctl daemon-reload
sudo systemctl enable portfoliopulse
sudo systemctl start portfoliopulse
```

### 日志轮转
```bash
# 设置日志轮转，防止日志文件过大
sudo tee /etc/logrotate.d/portfoliopulse > /dev/null << 'EOF'
/opt/portfoliopulse/*.log {
    daily
    missingok
    rotate 7
    compress
    copytruncate
    notifempty
}
EOF
```

这就是你的PortfolioPulse项目的完整二进制部署指南！简单、直接、高效。
