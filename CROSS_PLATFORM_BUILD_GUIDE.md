# 🎯 PortfolioPulse 跨平台构建部署完整指南

## 📋 问题分析

你遇到的问题是 **平台不匹配**：
- 🖥️ **开发环境**: Windows 11 (x86_64-pc-windows-msvc)
- 🐧 **目标服务器**: Ubuntu 22.04 LTS (x86_64-unknown-linux-gnu)
- ❌ **错误原因**: 使用了 Windows 构建的二进制文件到 Linux 服务器

## 🎯 解决方案概览

### 方案选择
1. **🌟 推荐方案**: GitHub Actions 云编译 (稳定、无环境依赖)
2. **🔧 备用方案**: Windows 本地交叉编译 (需要配置工具链)

---

## 🌟 方案1: GitHub Actions 云编译 (推荐)

### 步骤1: 确认工作流配置

你的 `.github/workflows/ubuntu-cross-compile.yml` 已经配置正确，它会：
- 在 Ubuntu 22.04 环境中构建
- 生成正确的 Linux 二进制文件
- 打包成部署包上传

### 步骤2: 触发云编译

```bash
# 在本地推送代码触发编译
git add .
git commit -m "触发 Ubuntu 交叉编译"
git push origin main
```

### 步骤3: 下载构建产物

1. 访问 GitHub Actions 页面
2. 找到最新的 "🦀 Ubuntu 交叉编译构建" 运行记录
3. 下载 `portfoliopulse-ubuntu-22.04-xxxxx` 构建产物 (zip 文件)

### 步骤4: 解压并检查文件

```bash
# 解压下载的 zip 文件
unzip portfoliopulse-ubuntu-22.04-xxxxx.zip -d deploy/

# 检查文件类型（关键步骤）
file deploy/portfolio_pulse_backend
# 期望输出: ELF 64-bit LSB pie executable, x86-64, version 1 (GNU/Linux)

# 如果输出包含 "Windows" 或 ".exe"，则构建有问题
```

### 步骤5: 上传到 Ubuntu 服务器

```bash
# 将整个 deploy 目录上传到服务器
rsync -av --progress deploy/ user@your-server:/opt/portfoliopulse/

# 或使用 scp
scp -r deploy/* user@your-server:/opt/portfoliopulse/
```

### 步骤6: 服务器端部署

```bash
# SSH 登录服务器
ssh user@your-server

# 进入部署目录
cd /opt/portfoliopulse

# 验证文件是否为 Linux 格式
file portfolio_pulse_backend
# 必须输出: ELF 64-bit LSB pie executable

# 设置权限
chmod +x portfolio_pulse_backend *.sh

# 配置环境变量
cp .env.example .env
nano .env

# 启动服务
./start.sh
```

---

## 🔧 方案2: Windows 本地交叉编译

如果你想在 Windows 本地进行交叉编译，需要完整的工具链设置：

### 步骤1: 安装交叉编译工具

```powershell
# 安装 Linux 目标
rustup target add x86_64-unknown-linux-gnu

# 安装 Windows 上的 GNU 工具链 (二选一)
# 方案A: 使用 MSYS2
winget install MSYS2.MSYS2

# 方案B: 使用 WSL2 (推荐)
wsl --install Ubuntu-22.04
```

### 步骤2: 配置 Cargo 交叉编译

创建 `.cargo/config.toml`:

```toml
[target.x86_64-unknown-linux-gnu]
linker = "x86_64-linux-gnu-gcc"

[env]
CC_x86_64_unknown_linux_gnu = "x86_64-linux-gnu-gcc"
CXX_x86_64_unknown_linux_gnu = "x86_64-linux-gnu-g++"
```

### 步骤3: 执行交叉编译

```powershell
# 后端交叉编译
cd backend
cargo build --release --target x86_64-unknown-linux-gnu

# 前端构建 (平台无关)
cd ../frontend
npm ci
npm run build
```

**⚠️ 注意**: 本地交叉编译复杂度高，容易出现依赖问题，建议使用 GitHub Actions。

---

## 📦 详细文件清单和作用

### GitHub Actions 构建产物应包含:

```
deploy/
├── 🦀 portfolio_pulse_backend     # Rust 后端二进制 (Linux x86_64)
│   └── 验证命令: file portfolio_pulse_backend
│   └── 期望输出: ELF 64-bit LSB pie executable
│
├── 🟢 前端文件 (Node.js Standalone)
│   ├── server.js                  # Next.js 服务器入口点
│   ├── package.json              # Node.js 包配置
│   ├── .next/standalone/          # 自包含的 Next.js 应用
│   ├── .next/static/             # 静态资源
│   └── public/                   # 公共资源
│
├── 🚀 管理脚本
│   ├── start.sh                  # 启动脚本
│   ├── stop.sh                   # 停止脚本
│   └── status.sh                 # 状态检查脚本
│
├── ⚙️ 配置文件
│   ├── .env.example              # 环境变量模板
│   └── README.md                 # 部署说明
│
└── 📊 运行时文件 (启动后生成)
    ├── backend.log               # 后端日志
    ├── frontend.log              # 前端日志
    ├── backend.pid               # 后端进程ID
    └── frontend.pid              # 前端进程ID
```

### 各文件作用详解:

1. **🦀 portfolio_pulse_backend**
   - Rust 编译的 Linux 可执行文件
   - 提供 API 服务 (端口 8000)
   - 必须是 ELF 64-bit 格式

2. **🟢 前端 Next.js 应用**
   - `server.js`: Node.js 服务器，提供 SSR 和路由
   - `.next/standalone/`: 包含所有运行时依赖的独立应用
   - 静态资源由 Node.js 服务器托管

3. **🚀 管理脚本**
   - `start.sh`: 依次启动后端和前端，检查健康状态
   - `stop.sh`: 优雅停止所有服务
   - `status.sh`: 检查服务运行状态

---

## 🔍 故障排查检查清单

### 构建阶段检查:
- [ ] GitHub Actions 运行成功 ✅
- [ ] 下载的 zip 文件大小正常 (>20MB)
- [ ] 解压后包含 `portfolio_pulse_backend` 文件
- [ ] **关键**: `file portfolio_pulse_backend` 输出为 ELF 格式

### 服务器部署检查:
- [ ] 服务器是 Ubuntu 22.04 LTS x86_64
- [ ] 文件权限设置正确 (`chmod +x`)
- [ ] Node.js 18+ 已安装
- [ ] 端口 3000, 8000 未被占用
- [ ] `.env` 文件配置正确

### 运行时检查:
- [ ] `./start.sh` 无错误输出
- [ ] `curl http://localhost:8000/health` 返回 200
- [ ] `curl http://localhost:3000` 返回页面内容
- [ ] 日志文件无错误信息

---

## 📝 完整部署脚本示例

为确保万无一失，这里是完整的服务器端部署脚本：

```bash
#!/bin/bash
# 完整部署脚本 - deploy.sh

set -e

echo "🚀 PortfolioPulse 部署开始..."

# 检查系统
if [[ "$(uname -s)" != "Linux" ]]; then
    echo "❌ 此脚本只能在 Linux 系统上运行"
    exit 1
fi

# 检查文件
if [[ ! -f "portfolio_pulse_backend" ]]; then
    echo "❌ 找不到后端二进制文件"
    exit 1
fi

# 验证文件格式
FILE_TYPE=$(file portfolio_pulse_backend)
if [[ "$FILE_TYPE" != *"ELF 64-bit"* ]]; then
    echo "❌ 后端文件不是有效的 Linux 二进制文件"
    echo "文件类型: $FILE_TYPE"
    exit 1
fi

echo "✅ 文件验证通过"

# 检查 Node.js
if ! command -v node &> /dev/null; then
    echo "📥 安装 Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

NODE_VERSION=$(node --version)
echo "✅ Node.js 版本: $NODE_VERSION"

# 设置权限
chmod +x portfolio_pulse_backend *.sh

# 配置环境变量
if [[ ! -f ".env" ]]; then
    cp .env.example .env
    echo "⚙️ 请编辑 .env 文件配置数据库等参数"
fi

# 启动服务
echo "🚀 启动服务..."
./start.sh

echo "🎉 部署完成！"
echo "🌐 前端: http://localhost:3000"
echo "🔌 后端: http://localhost:8000"
```

## 💡 最佳实践建议

1. **优先使用 GitHub Actions**: 环境一致性最好，避免本地交叉编译的复杂性
2. **验证文件格式**: 每次部署前用 `file` 命令检查二进制文件
3. **分步骤测试**: 先测试后端启动，再测试前端，最后测试整体
4. **保留日志**: 出现问题时查看 `backend.log` 和 `frontend.log`
5. **版本管理**: 每次构建都用 Git SHA 标记，便于回滚

通过这个完整的指南，你应该能够成功地从 Windows 开发环境构建出在 Ubuntu 服务器上运行的应用程序。关键是确保使用正确的构建环境和验证文件格式。
