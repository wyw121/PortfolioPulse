# PortfolioPulse 实践部署指南

## 🎯 为你的项目推荐的部署路径

基于你的项目特点（Rust后端 + Next.js前端 + MySQL），我推荐以下学习和实践路径：

### 第一阶段：快速体验（30分钟）
使用现代PaaS平台快速部署，体验完整流程

### 第二阶段：深入理解（2小时）
使用Docker本地部署，理解容器化原理

### 第三阶段：底层掌握（半天）
手动二进制部署，掌握系统底层知识

---

## 🚀 阶段一：Railway快速部署（推荐首选）

### 为什么选择Railway：
- ✅ 对Rust项目友好
- ✅ 内置MySQL数据库
- ✅ 自动HTTPS证书
- ✅ Git集成部署
- ✅ 免费额度足够测试

### 准备工作（Windows上）：
```powershell
# 1. 安装Railway CLI
npm install -g @railway/cli

# 2. 登录
railway login

# 3. 确保你的代码已经推送到GitHub
git add .
git commit -m "prepare for railway deployment"
git push origin main
```

### 部署步骤：

#### 1. 配置项目结构
为Railway创建配置文件：

```toml
# railway.toml (项目根目录)
[build]
builder = "NIXPACKS"

[deploy]
startCommand = "cd backend && cargo run --release"
restartPolicyType = "ON_FAILURE"
restartPolicyMaxRetries = 10

[env]
PORT = "8000"
```

```json
# backend/nixpacks.toml
[phases.setup]
nixPkgs = ["rustc", "cargo", "gcc"]

[phases.build]
cmds = ["cargo build --release"]

[start]
cmd = "./target/release/portfolio-pulse-backend"
```

#### 2. 一键部署
```powershell
# 在项目根目录
railway link    # 连接到Railway项目
railway up      # 部署！
```

#### 3. 添加数据库
```powershell
railway add mysql
railway vars     # 查看自动生成的DATABASE_URL
```

### 结果：
- 🌐 自动获得https://your-app.railway.app域名
- 📊 内置监控面板
- 📋 实时日志查看
- 🔄 每次git push自动部署

---

## 🐳 阶段二：Docker本地部署

### Windows环境准备：
```powershell
# 1. 安装Docker Desktop
# 从官网下载并安装，需要约3GB空间

# 2. 启动Docker Desktop
# 确保Docker引擎正在运行

# 3. 验证安装
docker --version
docker-compose --version
```

### 本地Docker部署：

#### 1. 使用现有的Docker配置
```powershell
# 检查现有配置
ls Dockerfile.backend
ls Dockerfile.frontend
ls docker-compose.yml
```

#### 2. 构建和运行
```powershell
# 一键启动整个服务栈
docker-compose up -d

# 查看运行状态
docker-compose ps

# 查看日志
docker-compose logs -f
```

#### 3. 访问应用
- 前端：http://localhost:3000
- 后端API：http://localhost:8000
- MySQL：localhost:3306

#### 4. 开发调试
```powershell
# 重新构建某个服务
docker-compose build backend
docker-compose up -d backend

# 进入容器调试
docker-compose exec backend bash
docker-compose exec mysql mysql -u root -p
```

---

## 💻 阶段三：Ubuntu服务器二进制部署

### 服务器准备（Ubuntu 20.04+）：

#### 1. 基础环境安装
```bash
# 更新系统
sudo apt-get update && sudo apt-get upgrade -y

# 安装编译环境（如果要在服务器编译）
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source ~/.cargo/env
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs build-essential pkg-config libssl-dev

# 安装运行时环境（如果只运行二进制）
sudo apt-get install -y ca-certificates libssl3 nginx mysql-server
```

#### 2. 数据库配置
```bash
# 配置MySQL
sudo mysql_secure_installation

# 创建应用数据库
mysql -u root -p << EOF
CREATE DATABASE portfolio_pulse;
CREATE USER 'portfoliopulse'@'localhost' IDENTIFIED BY 'secure_password_123';
GRANT ALL PRIVILEGES ON portfolio_pulse.* TO 'portfoliopulse'@'localhost';
FLUSH PRIVILEGES;
EXIT;
EOF
```

#### 3. 部署方式选择

**方式A：跨平台编译（Windows编译 → Linux运行）**
```powershell
# Windows上交叉编译
rustup target add x86_64-unknown-linux-gnu
cd backend
cargo build --target x86_64-unknown-linux-gnu --release

# 上传到服务器
scp target/x86_64-unknown-linux-gnu/release/portfolio-pulse-backend user@server:/opt/app/
```

**方式B：服务器端编译（推荐学习用）**
```bash
# 服务器上克隆代码
git clone https://github.com/wyw121/PortfolioPulse.git
cd PortfolioPulse

# 编译后端
cd backend
cargo build --release

# 编译前端
cd ../frontend
npm install
npm run build
```

#### 4. 服务配置
```bash
# 创建systemd服务
sudo tee /etc/systemd/system/portfolio-pulse.service << EOF
[Unit]
Description=PortfolioPulse Backend
After=network.target mysql.service

[Service]
Type=simple
User=portfoliopulse
WorkingDirectory=/opt/PortfolioPulse/backend
Environment=DATABASE_URL=mysql://portfoliopulse:secure_password_123@localhost:3306/portfolio_pulse
Environment=RUST_LOG=info
ExecStart=/opt/PortfolioPulse/backend/target/release/portfolio-pulse-backend
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# 启动服务
sudo systemctl daemon-reload
sudo systemctl enable portfolio-pulse
sudo systemctl start portfolio-pulse
```

#### 5. Nginx反向代理
```bash
sudo tee /etc/nginx/sites-available/portfoliopulse << EOF
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
    }

    location /api/ {
        proxy_pass http://localhost:8000/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF

sudo ln -s /etc/nginx/sites-available/portfoliopulse /etc/nginx/sites-enabled/
sudo systemctl restart nginx
```

---

## 📊 三种方案的资源需求对比

| 资源类型 | Railway部署 | Docker本地 | Ubuntu二进制 |
|----------|-------------|------------|---------------|
| **Windows磁盘** | 650MB | 3.6GB | 650MB |
| **服务器磁盘** | 0 | 1.6GB | 2-5GB |
| **服务器内存** | 0 | 1GB | 512MB |
| **网络流量** | 按用量计费 | 本地无限 | 按服务器流量 |
| **维护成本** | ⭐ | ⭐⭐ | ⭐⭐⭐⭐ |

---

## 🎓 学习价值分析

### Railway部署学习收获：
- ✅ 现代CI/CD流程
- ✅ 云原生应用管理
- ✅ 环境变量管理
- ✅ 生产级监控

### Docker部署学习收获：
- ✅ 容器化技术原理
- ✅ 微服务架构理解
- ✅ 开发环境一致性
- ✅ 现代运维基础

### 二进制部署学习收获：
- ✅ Linux系统管理
- ✅ 网络配置原理
- ✅ 进程管理技能
- ✅ 故障排查能力

---

## 💰 成本分析

### Railway（生产环境推荐）：
```
免费额度：$5/月资源
付费起点：$5/月
预估成本：$10-20/月（包含数据库）
```

### 自己的Ubuntu服务器：
```
VPS成本：$5-20/月
域名：$10-15/年
SSL证书：免费（Let's Encrypt）
维护时间：每月2-4小时
```

### 本地Docker：
```
开发成本：仅电费
学习价值：很高
适用场景：开发测试
```

---

## 🏆 最终推荐

**为你的学习目标，推荐这样的顺序：**

1. **先用Railway快速部署**（30分钟体验成功）
2. **然后Docker本地调试**（理解现代部署）
3. **最后尝试二进制部署**（掌握底层原理）

这样既能快速看到成果，又能深入学习技术原理，还能为未来的项目选择最合适的部署方案！

每种方案都有其价值，关键是根据项目阶段和目标来选择。你觉得从哪个开始比较好？
