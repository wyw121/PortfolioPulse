# PortfolioPulse 部署配置指导

## 📋 服务器配置总览

### 当前服务器规格
```yaml
服务器信息:
  提供商: [云服务商名称]
  规格: 锐驰型-2核1G-40G-200Mbps
  CPU: 2核心
  内存: 1GB RAM
  存储: 40GB SSD 云硬盘
  带宽: 200Mbps 峰值带宽
  地域: 广州
  操作系统: Ubuntu 22.04 LTS
  费用: ¥211.2/半年 (¥35.2/月)
```

## 🚀 部署架构设计

### 整体架构图
```
前端 (Vercel)                后端 (VPS)
┌─────────────────┐          ┌──────────────────────┐
│ Next.js 15      │          │ Ubuntu 22.04 LTS     │
│ - App Router    │   HTTP   │ ┌──────────────────┐ │
│ - Tailwind CSS  │ ◄──────► │ │ Rust Backend     │ │
│ - shadcn/ui     │   API    │ │ - Axum Framework │ │
│ - GitHub图表    │          │ │ - JWT Auth       │ │
└─────────────────┘          │ └──────────────────┘ │
         │                   │ ┌──────────────────┐ │
         │                   │ │ MySQL 8.0        │ │
    静态资源                 │ │ - 200MB配置      │ │
         │                   │ │ - InnoDB引擎     │ │
         ▼                   │ └──────────────────┘ │
┌─────────────────┐          │ ┌──────────────────┐ │
│ Cloudflare CDN  │          │ │ Nginx Proxy      │ │
│ - 免费版        │          │ │ - 反向代理       │ │
│ - SSL终端       │          │ │ - 静态文件       │ │
│ - 缓存策略      │          │ │ - Gzip压缩       │ │
└─────────────────┘          │ └──────────────────┘ │
                             └──────────────────────┘
```

## 🛠️ 系统环境配置

### 1. 基础系统优化

```bash
# 更新系统包
sudo apt update && sudo apt upgrade -y

# 安装必要工具
sudo apt install -y curl wget git nginx mysql-server htop unzip

# 配置时区
sudo timedatectl set-timezone Asia/Shanghai

# 优化系统参数 (适配1GB内存)
echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
echo 'vm.dirty_ratio=10' | sudo tee -a /etc/sysctl.conf
echo 'vm.dirty_background_ratio=5' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

### 2. MySQL 配置优化

```bash
# MySQL配置文件 /etc/mysql/mysql.conf.d/mysqld.cnf
[mysqld]
# 基本配置
bind-address = 127.0.0.1
port = 3306

# 内存优化 (适配1GB总内存)
innodb_buffer_pool_size = 128M
max_connections = 50
query_cache_size = 32M
query_cache_type = 1
table_open_cache = 64
thread_cache_size = 8
tmp_table_size = 16M
max_heap_table_size = 16M

# 日志配置
slow_query_log = 1
slow_query_log_file = /var/log/mysql/slow.log
long_query_time = 2

# 字符集配置
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci
```

### 3. Nginx 配置

```nginx
# /etc/nginx/sites-available/portfoliopulse
server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;

    # 重定向到HTTPS (由Cloudflare处理)
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name yourdomain.com www.yourdomain.com;

    # SSL配置 (Cloudflare处理)
    ssl_certificate /path/to/cloudflare/cert.pem;
    ssl_certificate_key /path/to/cloudflare/key.pem;

    # Gzip压缩
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain application/json application/javascript text/css;

    # API代理
    location /api/ {
        proxy_pass http://127.0.0.1:3001;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # 静态文件服务
    location /images/ {
        alias /var/www/portfoliopulse/public/images/;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    # 默认返回404 (前端由Vercel处理)
    location / {
        return 404;
    }
}
```

## 📦 应用部署配置

### 1. Rust 后端部署

```bash
# 创建应用目录
sudo mkdir -p /opt/portfoliopulse
sudo chown $USER:$USER /opt/portfoliopulse

# 安装Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source ~/.cargo/env

# 克隆项目
cd /opt/portfoliopulse
git clone https://github.com/yourusername/portfoliopulse-backend.git
cd portfoliopulse-backend

# 生产构建
cargo build --release

# 创建systemd服务
sudo tee /etc/systemd/system/portfoliopulse.service > /dev/null <<EOF
[Unit]
Description=PortfolioPulse Backend
After=network.target

[Service]
Type=simple
User=www-data
Group=www-data
WorkingDirectory=/opt/portfoliopulse/portfoliopulse-backend
ExecStart=/opt/portfoliopulse/portfoliopulse-backend/target/release/portfoliopulse-backend
Restart=always
RestartSec=10
Environment=RUST_LOG=info

[Install]
WantedBy=multi-user.target
EOF

# 启动服务
sudo systemctl daemon-reload
sudo systemctl enable portfoliopulse
sudo systemctl start portfoliopulse
```

### 2. 数据库初始化

```sql
-- 创建数据库和用户
CREATE DATABASE portfoliopulse CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'portfolio'@'localhost' IDENTIFIED BY 'your_secure_password';
GRANT ALL PRIVILEGES ON portfoliopulse.* TO 'portfolio'@'localhost';
FLUSH PRIVILEGES;

-- 导入初始化脚本
USE portfoliopulse;
SOURCE /opt/portfoliopulse/schema.sql;
```

### 3. 环境变量配置

```bash
# /opt/portfoliopulse/.env
DATABASE_URL=mysql://portfolio:your_secure_password@localhost:3306/portfoliopulse
JWT_SECRET=your_jwt_secret_key_here
GITHUB_TOKEN=your_github_token_here
RUST_LOG=info
SERVER_PORT=3001
CORS_ORIGIN=https://yourdomain.com
```

## 📊 监控和维护

### 1. 系统监控脚本

```bash
#!/bin/bash
# /opt/portfoliopulse/monitor.sh

# 检查服务状态
check_service() {
    if ! systemctl is-active --quiet $1; then
        echo "$(date): Service $1 is down, attempting restart..."
        systemctl restart $1
        # 发送告警邮件
        echo "Service $1 was down and has been restarted" | mail -s "Server Alert" admin@example.com
    fi
}

# 检查磁盘空间
check_disk() {
    USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
    if [ $USAGE -gt 80 ]; then
        echo "$(date): Disk usage is ${USAGE}%, cleaning logs..."
        # 清理日志文件
        find /var/log -name "*.log" -type f -mtime +7 -exec rm {} \;
        # 清理MySQL二进制日志
        mysql -e "PURGE BINARY LOGS BEFORE DATE(NOW() - INTERVAL 7 DAY);"
    fi
}

# 检查内存使用
check_memory() {
    MEM_USAGE=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100.0}')
    if [ $MEM_USAGE -gt 90 ]; then
        echo "$(date): Memory usage is ${MEM_USAGE}%, restarting application..."
        systemctl restart portfoliopulse
    fi
}

# 执行检查
check_service nginx
check_service mysql
check_service portfoliopulse
check_disk
check_memory

echo "$(date): Monitor check completed"
```

### 2. 备份脚本

```bash
#!/bin/bash
# /opt/portfoliopulse/backup.sh

BACKUP_DIR="/opt/portfoliopulse/backups"
DATE=$(date +%Y%m%d_%H%M%S)

# 创建备份目录
mkdir -p $BACKUP_DIR

# 数据库备份
mysqldump -u portfolio -p'your_secure_password' portfoliopulse > $BACKUP_DIR/db_$DATE.sql

# 压缩备份
gzip $BACKUP_DIR/db_$DATE.sql

# 清理7天前的备份
find $BACKUP_DIR -name "*.sql.gz" -mtime +7 -delete

# 备份到远程 (可选)
# rsync -av $BACKUP_DIR/ user@backup-server:/backups/portfoliopulse/

echo "$(date): Backup completed - $BACKUP_DIR/db_$DATE.sql.gz"
```

### 3. Crontab 定时任务

```bash
# 编辑crontab
crontab -e

# 添加定时任务
# 每5分钟检查系统状态
*/5 * * * * /opt/portfoliopulse/monitor.sh >> /var/log/portfoliopulse-monitor.log 2>&1

# 每天2点备份数据库
0 2 * * * /opt/portfoliopulse/backup.sh >> /var/log/portfoliopulse-backup.log 2>&1

# 每天重启应用 (可选，用于释放内存)
0 3 * * * systemctl restart portfoliopulse
```

## 🔒 安全配置

### 1. 防火墙设置

```bash
# 安装ufw
sudo apt install ufw

# 默认策略
sudo ufw default deny incoming
sudo ufw default allow outgoing

# 允许SSH
sudo ufw allow 22

# 允许HTTP/HTTPS
sudo ufw allow 80
sudo ufw allow 443

# 启用防火墙
sudo ufw enable
```

### 2. 安全加固

```bash
# 禁用root登录
sudo sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

# 更改SSH端口 (可选)
sudo sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config
sudo ufw allow 2222
sudo ufw deny 22

# 重启SSH服务
sudo systemctl restart ssh

# 安装fail2ban
sudo apt install fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

## 📈 性能优化建议

### 1. 内存优化
- 使用Rust Release构建减少内存占用
- MySQL参数调优适配1GB内存
- 定期重启应用释放内存碎片
- 监控内存使用率避免OOM

### 2. 存储优化
- 图片使用WebP格式节省空间
- 启用日志轮转避免磁盘满
- 定期清理临时文件
- 数据库定期优化和重建索引

### 3. 网络优化
- 静态资源通过CDN分发
- 启用Gzip压缩减少带宽
- 合理设置缓存策略
- API响应压缩和分页

---

此配置文档基于2核1G服务器的实际限制进行了优化，可以支持中小型个人网站的稳定运行。定期维护和监控确保系统长期稳定运行。
