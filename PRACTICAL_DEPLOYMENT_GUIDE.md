# PortfolioPulse 实践部署指南

## 🎯 为你的项目推荐的部署路径

基于你的项目特点（Rust后端 + Next.js前端 + MySQL），我推荐以下学习和实践路径：

### 第一阶段：快速体验（30分钟）
使用现代PaaS平台快速部署，体验完整流程

### 第二阶段：本地构建（2小时）
使用二进制构建，理解编译和部署原理

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

## ⚙️ 阶段二：二进制构建部署

### Windows构建环境准备：
```powershell
# 1. 确保 Rust 工具链已安装
rustc --version
cargo --version

# 2. 确保 Node.js 已安装
node --version
npm --version

# 3. 验证构建工具
cd backend && cargo check
cd ../frontend && npm install
```

### 本地二进制构建：

#### 1. 使用生产构建脚本
```powershell
# 运行构建脚本
.\scripts\build-production.ps1

# 检查构建产物
ls build/
```

#### 2. 构建验证
```powershell
# 检查二进制文件
cd build
ls portfolio_pulse.exe
ls start.sh
ls start.bat

# 测试启动脚本（Windows）
start.bat

# 检查服务状态
# 后端应该在端口 8000 启动
```

#### 3. 访问应用
- 后端API：http://localhost:8000
- 前端：通过 Nginx 或其他 Web 服务器托管

#### 4. 开发调试
```powershell
# 单独构建后端
cd backend && cargo build --release

# 单独构建前端
cd frontend && npm run build

# 查看构建产物
ls backend/target/release/portfolio_pulse.exe
ls frontend/.next/
```

---

## 💻 阶段三：Linux 服务器二进制部署

### 服务器准备（Ubuntu 20.04+）：

#### 1. 基础环境安装
```bash
# 更新系统
sudo apt-get update && sudo apt-get upgrade -y

# 安装运行时依赖（最小化安装）
sudo apt-get install -y ca-certificates libssl3 nginx mysql-server

# 如果需要在服务器本地构建，安装开发工具
# curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
# curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
# sudo apt-get install -y nodejs build-essential pkg-config libssl-dev
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
scp target/x86_64-unknown-linux-gnu/release/portfolio_pulse user@server:/opt/portfoliopulse/
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

| 资源类型 | Railway部署 | 二进制本地 | Ubuntu二进制 |
|----------|-------------|------------|---------------|
| **Windows磁盘** | 650MB | 650MB | 650MB |
| **服务器磁盘** | 0 | 50MB | 2-5GB |
| **服务器内存** | 0 | 256MB | 512MB |
| **网络流量** | 按用量计费 | 本地无限 | 按服务器流量 |
| **维护成本** | ⭐ | ⭐⭐ | ⭐⭐⭐⭐ |

---

## 🎓 学习价值分析

### Railway部署学习收获：
- ✅ 现代CI/CD流程
- ✅ 云原生应用管理
- ✅ 环境变量管理
- ✅ 生产级监控

### 二进制构建学习收获：
- ✅ 编译原理理解
- ✅ 跨平台编译技能
- ✅ 性能优化意识
- ✅ 轻量化部署实践

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

### 本地二进制：
```
开发成本：仅电费
学习价值：很高
适用场景：开发测试
```

---

## 🏆 最终推荐

**为你的学习目标，推荐这样的顺序：**

1. **先用Railway快速部署**（30分钟体验成功）
2. **然后二进制本地构建**（理解编译和部署）
3. **最后尝试服务器部署**（掌握生产环境）

这样既能快速看到成果，又能深入学习技术原理，还能为未来的项目选择最合适的部署方案！

每种方案都有其价值，关键是根据项目阶段和目标来选择。专注于二进制部署能让你更好地理解应用的本质运行方式！
