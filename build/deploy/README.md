# PortfolioPulse Ubuntu 22.04 部署指南

## 📋 部署包内容

```
deploy/
├── portfolio_pulse_backend    # 后端二进制文件 (Rust)
├── server.js                  # 前端服务器入口
├── .next/                     # Next.js 构建输出
│   ├── static/               # 静态资源
│   └── server/               # 服务器端文件
├── public/                    # 公共文件
├── node_modules/             # Node.js 依赖
├── package.json              # 包配置
├── start.sh                  # 启动脚本
├── stop.sh                   # 停止脚本
├── status.sh                 # 状态检查脚本
├── .env.example             # 环境变量模板
└── README.md               # 本文件
```

## 🚀 快速部署步骤

### 1. 准备服务器环境

```bash
# 更新系统
sudo apt update && sudo apt upgrade -y

# 安装 Node.js 18+ (推荐使用 NodeSource 仓库)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# 安装 MySQL (可选，如果使用数据库)
sudo apt install mysql-server -y

# 安装 Nginx (推荐用于反向代理)
sudo apt install nginx -y

# 验证安装
node --version  # 应该显示 v18.x.x 或更高版本
npm --version
```

### 2. 上传部署包

```bash
# 在服务器上创建目录
sudo mkdir -p /opt/portfoliopulse
sudo chown $USER:$USER /opt/portfoliopulse

# 本地上传文件 (在您的本地机器上运行)
scp -r build/deploy/* user@your-server-ip:/opt/portfoliopulse/

# 或者使用 rsync (推荐)
rsync -av --progress build/deploy/ user@your-server-ip:/opt/portfoliopulse/
```

### 3. 配置环境

```bash
# 登录到服务器
ssh user@your-server-ip

# 进入部署目录
cd /opt/portfoliopulse

# 复制环境配置并编辑
cp .env.example .env
nano .env

# 配置数据库 (如果使用 MySQL)
sudo mysql
CREATE DATABASE portfolio_pulse;
CREATE USER 'portfoliopulse'@'localhost' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON portfolio_pulse.* TO 'portfoliopulse'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### 4. 启动服务

```bash
# 给脚本添加执行权限
chmod +x start.sh stop.sh status.sh

# 启动服务
./start.sh

# 检查状态
./status.sh
```

## 🔧 环境变量配置

编辑 `.env` 文件：

```bash
# 基本配置
NODE_ENV=production
PORT=3000

# 数据库配置 (如果使用)
DATABASE_URL=mysql://portfoliopulse:your_password@localhost:3306/portfolio_pulse

# GitHub 集成 (可选)
GITHUB_TOKEN=ghp_your_token_here
GITHUB_USERNAME=your_github_username

# 日志级别
RUST_LOG=info
```

## 🌐 Nginx 反向代理配置 (推荐)

创建 Nginx 配置文件：

```bash
sudo nano /etc/nginx/sites-available/portfoliopulse
```

配置内容：

```nginx
server {
    listen 80;
    server_name your-domain.com;  # 替换为您的域名

    # 静态文件直接服务
    location /_next/static/ {
        alias /opt/portfoliopulse/.next/static/;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    location /public/ {
        alias /opt/portfoliopulse/public/;
        expires 1y;
    }

    # API 请求转发到后端
    location /api/ {
        proxy_pass http://localhost:8000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # 其他请求转发到前端
    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

启用配置：

```bash
sudo ln -s /etc/nginx/sites-available/portfoliopulse /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

## 📊 服务管理

### 启动服务
```bash
./start.sh
```

### 停止服务
```bash
./stop.sh
```

### 检查状态
```bash
./status.sh
```

### 查看日志
```bash
# 后端日志
tail -f backend.log

# 前端日志
tail -f frontend.log

# 实时查看所有日志
tail -f *.log
```

### 重启服务
```bash
./stop.sh && sleep 2 && ./start.sh
```

## 🔍 故障排除

### 常见问题

1. **端口被占用**
   ```bash
   # 检查端口占用
   sudo netstat -tulpn | grep :3000
   sudo netstat -tulpn | grep :8000

   # 杀死占用进程
   sudo kill -9 <PID>
   ```

2. **权限问题**
   ```bash
   # 确保文件有执行权限
   chmod +x portfolio_pulse_backend start.sh stop.sh status.sh
   ```

3. **Node.js 版本过低**
   ```bash
   # 升级 Node.js
   curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
   sudo apt-get install -y nodejs
   ```

4. **数据库连接失败**
   - 检查 MySQL 服务是否运行：`sudo systemctl status mysql`
   - 验证数据库用户权限
   - 检查 .env 中的 DATABASE_URL 配置

### 日志分析

```bash
# 检查启动错误
grep -i error backend.log
grep -i error frontend.log

# 查看最近的日志
tail -n 50 backend.log
tail -n 50 frontend.log
```

## 🛡️ 安全建议

1. **防火墙配置**
   ```bash
   sudo ufw allow ssh
   sudo ufw allow 80
   sudo ufw allow 443
   sudo ufw enable
   ```

2. **SSL 证书 (使用 Let's Encrypt)**
   ```bash
   sudo apt install certbot python3-certbot-nginx
   sudo certbot --nginx -d your-domain.com
   ```

3. **定期备份**
   - 数据库备份
   - 应用程序日志轮转
   - 配置文件备份

## 📈 性能优化

1. **使用 PM2 管理进程**
   ```bash
   npm install -g pm2
   pm2 start ecosystem.config.js
   pm2 save
   pm2 startup
   ```

2. **启用 Gzip 压缩** (在 Nginx 中)
3. **设置适当的缓存头**
4. **监控资源使用情况**

---

## 🎯 总结

此部署包包含了在 Ubuntu 22.04 上运行 PortfolioPulse 所需的所有文件。按照上述步骤，您应该能够成功部署和运行应用程序。

如果遇到问题，请检查日志文件并参考故障排除部分。
