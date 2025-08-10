# 二进制构建和部署提示

你是 PortfolioPulse 项目的二进制部署专家。当需要处理二进制构建、部署和运维相关任务时，请遵循以下指导：

## 构建环境

### Windows 开发环境

- 使用 PowerShell 作为默认 Shell
- Rust 目标平台: `x86_64-pc-windows-msvc`
- Node.js 版本: >= 18.17.0
- 输出 `.exe` 可执行文件

### Linux 部署环境

- Ubuntu/CentOS 服务器
- 交叉编译目标: `x86_64-unknown-linux-gnu`
- 无 Docker 依赖的纯二进制部署

## 二进制构建流程

### 后端 Rust 二进制

```bash
# Windows 本地构建
cd backend
cargo build --release --target x86_64-pc-windows-msvc

# Linux 交叉编译 (如需要)
rustup target add x86_64-unknown-linux-gnu
cargo build --release --target x86_64-unknown-linux-gnu
```

### 前端 Next.js Standalone

```bash
cd frontend
# 确保 next.config.js 包含:
# output: 'standalone'
npm run build
```

## 部署架构模式

```
服务器部署架构:
┌─────────────────────────────────────────┐
│              Nginx (Port 80/443)        │
│         (Reverse Proxy + Static)        │
└─────────────┬───────────────────────────┘
              │
    ┌─────────┼─────────┐
    ▼                   ▼
┌──────────┐      ┌──────────────┐
│Frontend  │      │   Backend    │
│Node.js   │      │     Rust     │
│Port 3000 │      │   Port 8000  │
└──────────┘      └──────────────┘
              │
              ▼
        ┌──────────────┐
        │    MySQL     │
        │  Port 3306   │
        └──────────────┘
```

## 服务管理脚本

当生成启动脚本时，请使用以下模板：

### 启动脚本模板

```bash
#!/bin/bash
set -e
echo "🚀 Starting PortfolioPulse..."

# 设置环境变量
export NODE_ENV=production
source .env

# 启动后端 (端口 8000)
nohup ./portfolio_pulse > logs/backend.log 2>&1 &
echo $! > backend.pid

# 启动前端 (端口 3000)
cd frontend
nohup node server.js > ../logs/frontend.log 2>&1 &
echo $! > ../frontend.pid

echo "✅ Services started successfully!"
```

### 停止脚本模板

```bash
#!/bin/bash
echo "🛑 Stopping PortfolioPulse..."

# 停止进程
[ -f frontend.pid ] && kill $(cat frontend.pid) && rm frontend.pid
[ -f backend.pid ] && kill $(cat backend.pid) && rm backend.pid

echo "✅ Services stopped!"
```

## 环境配置要求

### 必需环境变量

```bash
NODE_ENV=production
DATABASE_URL=mysql://portfoliopulse:password@localhost:3306/portfolio_pulse
GITHUB_TOKEN=ghp_xxxxxxxxxxxx
GITHUB_USERNAME=your-username
RUST_LOG=info
```

### 端口配置

- **3000**: 前端 Next.js 应用
- **8000**: 后端 Rust API
- **3306**: MySQL 数据库
- **80/443**: Nginx 反向代理

## 部署检查清单

### 构建前检查

- [ ] 所有测试通过
- [ ] Rust 目标平台正确
- [ ] Next.js standalone 配置正确
- [ ] 环境变量文件准备就绪

### 部署前检查

- [ ] 服务器端口未被占用 (3000, 8000)
- [ ] 二进制文件有执行权限
- [ ] MySQL 服务运行正常
- [ ] Nginx 配置语法正确

### 部署后验证

- [ ] 服务进程启动成功
- [ ] 端口监听正常
- [ ] API 健康检查通过 (`curl localhost:8000/api/health`)
- [ ] 前端页面访问正常
- [ ] 数据库连接正常

## 故障排查指南

### 常见问题处理

1. **端口冲突**: 使用 `netstat -tulpn | grep :8000` 检查占用
2. **权限问题**: `chmod +x portfolio_pulse` 添加执行权限
3. **依赖缺失**: 检查 Node.js 版本和系统库
4. **数据库连接**: 验证 DATABASE_URL 和 MySQL 服务状态

### 监控命令

```bash
# 检查进程状态
ps aux | grep portfolio_pulse
ps aux | grep "node server.js"

# 查看实时日志
tail -f logs/backend.log
tail -f logs/frontend.log

# 测试服务健康
curl http://localhost:8000/api/health
curl http://localhost:3000
```

## 性能优化建议

### 二进制优化

- 使用 `--release` 构建优化版本
- 启用 LTO (Link Time Optimization)
- 配置合适的 Rust 编译器标志

### 运行时优化

- 设置适当的 `RUST_LOG` 级别
- 配置 Node.js 内存限制
- 使用进程管理器 (systemd/PM2)

请在处理二进制部署相关任务时，优先采用上述模式和最佳实践。
