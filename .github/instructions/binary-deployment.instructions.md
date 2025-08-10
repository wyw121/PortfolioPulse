---
applyTo: "backend/target/**/*,frontend/.next/**/*,scripts/**/*,**/start.sh,**/stop.sh"
---

# 二进制部署指令

## 部署架构

采用纯二进制部署方式，无 Docker 依赖：

```
服务器架构:
├── 端口 80/443 → Nginx (反向代理 + 静态文件服务)
├── 端口 3000 → portfolio_pulse_frontend (Node.js 二进制)
├── 端口 8000 → portfolio_pulse_backend (Rust 二进制)
└── 端口 3306 → MySQL 数据库
```

## 构建要求

### Windows 构建环境

- PowerShell 作为默认 Shell
- Rust 目标: `x86_64-pc-windows-msvc`
- Node.js >= 18.17.0
- 生成 `.exe` 文件

### Linux 部署目标

- 服务器环境: Ubuntu/CentOS
- 交叉编译目标: `x86_64-unknown-linux-gnu`
- 生成无扩展名二进制文件

## 构建命令

### 后端 Rust 二进制

```bash
# Windows 构建
cargo build --release --target x86_64-pc-windows-msvc

# Linux 交叉编译
cargo build --release --target x86_64-unknown-linux-gnu

# 输出位置
# Windows: target/release/portfolio_pulse.exe
# Linux: target/release/portfolio_pulse
```

### 前端 Next.js Standalone

```bash
# 确保 next.config.js 包含 standalone 输出
npm run build

# 输出结构:
# .next/standalone/     <- 可运行的 Node.js 应用
# .next/static/         <- 静态资源文件
# public/               <- 公共文件
```

## 部署文件结构

```bash
/opt/portfoliopulse/
├── portfolio_pulse              # Rust 二进制文件
├── frontend/
│   ├── server.js               # Next.js 服务器入口
│   ├── .next/standalone/       # Next.js 应用代码
│   ├── .next/static/          # 静态资源
│   └── public/                # 公共文件
├── start.sh                   # 启动脚本
├── stop.sh                    # 停止脚本
├── .env                       # 环境变量
└── logs/                      # 日志目录
```

## 启动管理脚本

### start.sh 模板

```bash
#!/bin/bash
set -e

PROJECT_DIR="/opt/portfoliopulse"
cd "$PROJECT_DIR"

# 启动后端 (端口 8000)
nohup ./portfolio_pulse > logs/backend.log 2>&1 &
echo $! > backend.pid

# 启动前端 (端口 3000)
cd frontend
nohup node server.js > ../logs/frontend.log 2>&1 &
echo $! > ../frontend.pid

echo "✅ PortfolioPulse started successfully!"
```

### stop.sh 模板

```bash
#!/bin/bash
PROJECT_DIR="/opt/portfoliopulse"
cd "$PROJECT_DIR"

# 停止进程
[ -f frontend.pid ] && kill $(cat frontend.pid) && rm frontend.pid
[ -f backend.pid ] && kill $(cat backend.pid) && rm backend.pid

echo "🛑 PortfolioPulse stopped!"
```

## 环境变量配置

```bash
# .env 文件示例
NODE_ENV=production
DATABASE_URL=mysql://portfoliopulse:password@localhost:3306/portfolio_pulse
GITHUB_TOKEN=ghp_xxxxxxxxxxxx
GITHUB_USERNAME=your-username
RUST_LOG=info
```

## Nginx 配置

```nginx
server {
    listen 80;
    server_name your-domain.com;

    # 静态文件直接服务
    location /_next/static/ {
        alias /opt/portfoliopulse/frontend/.next/static/;
        expires 1y;
    }

    location /public/ {
        alias /opt/portfoliopulse/frontend/public/;
    }

    # API 请求转发到后端
    location /api/ {
        proxy_pass http://localhost:8000/;
        proxy_set_header Host $host;
    }

    # 其他请求转发到前端
    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
    }
}
```

## 监控和维护

### 健康检查

```bash
# 检查服务状态
curl http://localhost:8000/api/health
curl http://localhost:3000

# 检查进程
ps aux | grep portfolio_pulse
ps aux | grep "node server.js"
```

### 日志管理

```bash
# 查看日志
tail -f logs/backend.log
tail -f logs/frontend.log

# 日志轮转 (logrotate)
/opt/portfoliopulse/logs/*.log {
    daily
    rotate 7
    compress
    copytruncate
}
```

## 部署最佳实践

1. **构建验证**: 确保二进制文件在目标系统可执行
2. **端口管理**: 确认 3000、8000 端口未被占用
3. **权限设置**: 二进制文件需要可执行权限 `chmod +x`
4. **进程管理**: 使用 systemd 或 PM2 管理进程
5. **备份策略**: 部署前备份旧版本文件
6. **健康监控**: 实施自动重启和监控机制

## 故障排查

### 常见问题

- **端口冲突**: 使用 `netstat -tulpn | grep :8000` 检查
- **权限问题**: 确保二进制文件有执行权限
- **依赖缺失**: 检查 Node.js 版本和系统库
- **环境变量**: 验证 `.env` 文件配置正确

### 调试步骤

1. 检查二进制文件是否存在且可执行
2. 验证环境变量配置
3. 查看启动日志
4. 测试端口连通性
5. 检查 Nginx 配置语法
