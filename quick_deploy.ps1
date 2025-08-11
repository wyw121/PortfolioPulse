#!/usr/bin/env pwsh

# PortfolioPulse 快速部署脚本 - 针对 Windows 开发环境优化

param(
    [switch]$ServerCompile,
    [switch]$DockerCompile,
    [switch]$Help
)

$ErrorActionPreference = "Stop"

function Write-Title {
    param([string]$Message)
    Write-Host "`n$Message" -ForegroundColor Cyan
    Write-Host ("=" * $Message.Length) -ForegroundColor Gray
}

function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

function Test-Command {
    param([string]$Command)
    try {
        $null = Get-Command $Command -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

if ($Help) {
    Write-Host @"
🎯 PortfolioPulse 快速部署脚本

针对 Windows 开发环境的最佳部署方案：

方案1: 服务器端编译 (推荐)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
特点: 在目标 Ubuntu 服务器上直接编译
优势: 100% 兼容性，无交叉编译问题
要求: SSH 访问服务器权限

使用方法:
  .\quick_deploy.ps1 -ServerCompile

方案2: Docker 容器编译
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
特点: 使用 Docker 容器模拟 Ubuntu 环境
优势: 本地编译，环境隔离
要求: 安装 Docker Desktop

使用方法:  
  .\quick_deploy.ps1 -DockerCompile

交互式选择:
  .\quick_deploy.ps1

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
解决了 Windows 交叉编译的各种兼容性问题
"@
    exit 0
}

function Create-ServerCompilePackage {
    Write-Title "🚀 创建服务器编译包"
    
    # 检查项目文件
    if (-not (Test-Path "backend\Cargo.toml") -or -not (Test-Path "frontend\package.json")) {
        Write-Error "请在 PortfolioPulse 项目根目录运行此脚本"
        return $false
    }
    
    # 创建部署目录
    $deployDir = ".\deploy-server"
    if (Test-Path $deployDir) {
        Remove-Item -Recurse -Force $deployDir
    }
    New-Item -ItemType Directory -Path $deployDir -Force | Out-Null
    
    Write-Success "正在准备服务器编译包..."
    
    # 复制源代码
    Write-Host "📦 复制项目源代码..." -ForegroundColor Blue
    Copy-Item -Path "backend" -Destination "$deployDir\backend" -Recurse -Force
    Copy-Item -Path "frontend" -Destination "$deployDir\frontend" -Recurse -Force
    
    # 排除不必要的文件
    $excludePaths = @(
        "$deployDir\backend\target",
        "$deployDir\frontend\node_modules",
        "$deployDir\frontend\.next"
    )
    
    foreach ($path in $excludePaths) {
        if (Test-Path $path) {
            Remove-Item -Recurse -Force $path
            Write-Host "  🧹 清理: $path" -ForegroundColor Gray
        }
    }
    
    # 创建服务器编译脚本
    $serverScript = @'
#!/bin/bash

# PortfolioPulse 服务器端编译脚本
# 适用于 Ubuntu 22.04 LTS

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🚀 PortfolioPulse 服务器端编译脚本${NC}"
echo -e "${CYAN}🐧 目标系统: $(lsb_release -d | cut -f2)${NC}"
echo "📅 编译时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# 环境检查函数
check_command() {
    if command -v $1 &> /dev/null; then
        echo -e "${GREEN}✅ $1 已安装${NC}"
        return 0
    else
        echo -e "${RED}❌ $1 未安装${NC}"
        return 1
    fi
}

install_rust() {
    echo -e "${BLUE}📥 安装 Rust 工具链...${NC}"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source $HOME/.cargo/env
    echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc
}

install_nodejs() {
    echo -e "${BLUE}📥 安装 Node.js LTS...${NC}"
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt-get install -y nodejs
}

# 系统更新
echo -e "${BLUE}🔄 更新系统包...${NC}"
sudo apt-get update

# 安装基础依赖
echo -e "${BLUE}📦 安装系统依赖...${NC}"
sudo apt-get install -y \
    curl \
    wget \
    build-essential \
    pkg-config \
    libssl-dev \
    ca-certificates \
    gnupg

# 检查并安装 Rust
if ! check_command rustc; then
    install_rust
    source $HOME/.cargo/env
fi

# 检查并安装 Node.js
if ! check_command node; then
    install_nodejs
fi

# 验证安装
echo -e "${BLUE}🔍 验证开发环境${NC}"
rustc --version
cargo --version
node --version
npm --version

# 编译后端
echo -e "${BLUE}🦀 编译 Rust 后端...${NC}"
cd backend
cargo build --release

# 查找后端二进制文件
BACKEND_BINARY=""
if [ -f "target/release/portfolio-pulse-backend" ]; then
    BACKEND_BINARY="target/release/portfolio-pulse-backend"
elif [ -f "target/release/portfolio_pulse_backend" ]; then
    BACKEND_BINARY="target/release/portfolio_pulse_backend"  
elif [ -f "target/release/main" ]; then
    BACKEND_BINARY="target/release/main"
else
    # 查找最大的可执行文件
    BACKEND_BINARY=$(find target/release -maxdepth 1 -type f -executable -size +1000c | head -1)
fi

if [ -z "$BACKEND_BINARY" ]; then
    echo -e "${RED}❌ 未找到后端可执行文件${NC}"
    exit 1
fi

echo -e "${GREEN}✅ 后端编译成功: $BACKEND_BINARY${NC}"
cd ..

# 编译前端
echo -e "${BLUE}🟢 编译 Next.js 前端...${NC}"
cd frontend
npm ci
npm run build

if [ ! -d ".next/standalone" ]; then
    echo -e "${RED}❌ 前端构建失败，未找到 standalone 输出${NC}"
    echo -e "${YELLOW}请检查 next.config.js 是否配置了 output: 'standalone'${NC}"
    exit 1
fi

echo -e "${GREEN}✅ 前端编译成功${NC}"
cd ..

# 创建部署目录
echo -e "${BLUE}📁 创建部署目录...${NC}"
mkdir -p deploy

# 复制文件
cp $BACKEND_BINARY deploy/portfolio_pulse_backend
chmod +x deploy/portfolio_pulse_backend

cp -r frontend/.next/standalone/* deploy/
[ -d frontend/.next/static ] && cp -r frontend/.next/static deploy/.next/
[ -d frontend/public ] && cp -r frontend/public deploy/

# 创建启动脚本
cat > deploy/start.sh << 'EOF'
#!/bin/bash

echo "🚀 启动 PortfolioPulse..."

# 启动后端
nohup ./portfolio_pulse_backend > backend.log 2>&1 &
echo $! > backend.pid
echo "🦀 后端已启动 (PID: $(cat backend.pid))"

# 等待后端启动
sleep 3

# 启动前端
nohup node server.js > frontend.log 2>&1 &
echo $! > frontend.pid
echo "🟢 前端已启动 (PID: $(cat frontend.pid))"

echo ""
echo "✅ PortfolioPulse 启动完成!"
echo "🌐 访问地址: http://localhost:3000"
echo ""
echo "管理命令:"
echo "  查看状态: ./status.sh"
echo "  停止服务: ./stop.sh"
echo "  查看日志: tail -f *.log"
EOF

# 创建停止脚本
cat > deploy/stop.sh << 'EOF'
#!/bin/bash

echo "🛑 停止 PortfolioPulse..."

for service in backend frontend; do
    if [ -f "${service}.pid" ]; then
        pid=$(cat "${service}.pid")
        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid"
            echo "已停止 $service (PID: $pid)"
        fi
        rm -f "${service}.pid"
    fi
done

echo "✅ 所有服务已停止"
EOF

# 创建状态检查脚本
cat > deploy/status.sh << 'EOF'
#!/bin/bash

echo "📊 PortfolioPulse 状态检查"
echo "检查时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

for service in backend frontend; do
    echo "🔍 $service 服务:"
    if [ -f "${service}.pid" ]; then
        pid=$(cat "${service}.pid")
        if kill -0 "$pid" 2>/dev/null; then
            echo "  ✅ 运行中 (PID: $pid)"
            cpu_mem=$(ps -p "$pid" -o %cpu,%mem --no-headers 2>/dev/null)
            [ -n "$cpu_mem" ] && echo "  📊 CPU: $(echo $cpu_mem | cut -d' ' -f1)%, 内存: $(echo $cpu_mem | cut -d' ' -f2)%"
        else
            echo "  ❌ 进程不存在 (PID: $pid)"
        fi
    else
        echo "  ❌ 未运行"
    fi
    echo ""
done
EOF

# 设置权限
chmod +x deploy/*.sh

# 创建环境配置模板
cat > deploy/.env.example << 'EOF'
# PortfolioPulse 环境变量配置

# 数据库配置
DATABASE_URL=mysql://username:password@localhost:3306/portfolio_pulse

# GitHub 集成
GITHUB_TOKEN=your_github_token_here
GITHUB_USERNAME=your_github_username

# 应用配置
NODE_ENV=production
PORT=3000

# 认证配置
NEXTAUTH_SECRET=your_secret_key_here
NEXTAUTH_URL=http://your-domain.com

# 日志级别
RUST_LOG=info
EOF

echo ""
echo -e "${GREEN}🎉 编译完成！${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${CYAN}📦 部署文件位置: ./deploy/${NC}"
echo ""
echo -e "${CYAN}🚀 启动命令:${NC}"
echo "cd deploy"
echo "cp .env.example .env  # 编辑配置文件"
echo "./start.sh"
echo ""
echo -e "${CYAN}📋 管理命令:${NC}"
echo "./status.sh    # 查看服务状态"
echo "./stop.sh      # 停止所有服务"
echo "tail -f *.log  # 查看实时日志"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
'@

    $serverScript | Out-File -FilePath "$deployDir\compile-and-deploy.sh" -Encoding utf8 -NoNewline
    
    # 创建使用说明
    $readme = @"
# PortfolioPulse 服务器端编译部署指南

## 📦 包内容

- `backend/` - Rust 后端源码
- `frontend/` - Next.js 前端源码  
- `compile-and-deploy.sh` - 服务器编译脚本

## 🚀 部署步骤

### 1. 上传到服务器

```bash
# 使用 scp 上传
scp -r deploy-server/ user@your-server:/opt/portfoliopulse/

# 或使用 rsync (推荐)
rsync -avz --progress deploy-server/ user@your-server:/opt/portfoliopulse/
```

### 2. 在服务器上编译和部署

```bash
ssh user@your-server
cd /opt/portfoliopulse
chmod +x compile-and-deploy.sh
./compile-and-deploy.sh
```

### 3. 配置和启动

```bash
cd deploy
cp .env.example .env
nano .env  # 编辑配置文件
./start.sh
```

## 🔧 服务管理

- **启动**: `./start.sh`
- **停止**: `./stop.sh`  
- **状态**: `./status.sh`
- **日志**: `tail -f backend.log frontend.log`

## 🎯 优势

- ✅ **100% 兼容性** - 在目标系统上原生编译
- ✅ **自动依赖安装** - 脚本自动处理所有依赖
- ✅ **一键部署** - 编译和部署一个命令完成
- ✅ **完整管理脚本** - 包含启动/停止/状态检查

## 📋 系统要求

- Ubuntu 22.04 LTS (推荐)
- 2GB+ RAM
- 5GB+ 磁盘空间
- sudo 权限 (用于安装系统依赖)

## 🆘 故障排除

如果编译失败，请检查:
1. 网络连接是否正常
2. 磁盘空间是否充足  
3. 是否有 sudo 权限
4. 系统是否为 Ubuntu 22.04

编译日志会显示详细的错误信息，请根据错误信息进行相应调整。
"@

    $readme | Out-File -FilePath "$deployDir\README.md" -Encoding utf8 -NoNewline
    
    Write-Success "服务器编译包已创建完成!"
    Write-Host ""
    Write-Host "📁 部署包位置: " -NoNewline -ForegroundColor Cyan
    Write-Host (Resolve-Path $deployDir) -ForegroundColor White
    Write-Host ""
    Write-Host "🚀 使用步骤:" -ForegroundColor Cyan
    Write-Host "1. 上传到服务器: scp -r $deployDir user@server:/opt/portfoliopulse/" -ForegroundColor White
    Write-Host "2. SSH 到服务器执行: chmod +x compile-and-deploy.sh && ./compile-and-deploy.sh" -ForegroundColor White
    Write-Host "3. 配置环境变量: cd deploy && cp .env.example .env && nano .env" -ForegroundColor White
    Write-Host "4. 启动服务: ./start.sh" -ForegroundColor White
    Write-Host ""
    Write-Host "✨ 这种方法可以 100% 避免 Windows 交叉编译的兼容性问题!" -ForegroundColor Green
}

function Create-DockerCompilePackage {
    Write-Title "🐳 创建 Docker 编译包"
    
    if (-not (Test-Command "docker")) {
        Write-Error "Docker 未安装"
        Write-Host "请安装 Docker Desktop: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
        return $false
    }
    
    $deployDir = ".\deploy-docker"
    if (Test-Path $deployDir) {
        Remove-Item -Recurse -Force $deployDir
    }
    New-Item -ItemType Directory -Path $deployDir -Force | Out-Null
    
    # 创建 Dockerfile
    $dockerfile = @'
# PortfolioPulse Docker 编译镜像
FROM ubuntu:22.04

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive
ENV RUST_LOG=info
ENV NODE_ENV=production

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    build-essential \
    pkg-config \
    libssl-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 安装 Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# 安装 Node.js LTS
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get install -y nodejs

# 设置工作目录
WORKDIR /app

# 复制源代码
COPY . .

# 编译后端
WORKDIR /app/backend
RUN cargo build --release

# 编译前端  
WORKDIR /app/frontend
RUN npm ci && npm run build

# 准备部署文件
WORKDIR /app
RUN mkdir -p /deploy && \
    find backend/target/release -maxdepth 1 -type f -executable -size +1000c -exec cp {} /deploy/portfolio_pulse_backend \; && \
    chmod +x /deploy/portfolio_pulse_backend && \
    cp -r frontend/.next/standalone/* /deploy/ && \
    [ -d frontend/.next/static ] && cp -r frontend/.next/static /deploy/.next/ || true && \
    [ -d frontend/public ] && cp -r frontend/public /deploy/ || true

# 创建启动脚本
RUN cat > /deploy/start.sh << 'EOF' && \
#!/bin/bash\n\
echo "🚀 启动 PortfolioPulse..."\n\
nohup ./portfolio_pulse_backend > backend.log 2>&1 &\n\
echo $! > backend.pid\n\
sleep 3\n\
nohup node server.js > frontend.log 2>&1 &\n\
echo $! > frontend.pid\n\
echo "✅ PortfolioPulse 启动完成!"\n\
echo "🌐 访问地址: http://localhost:3000"\n\
EOF\
    chmod +x /deploy/start.sh

# 设置默认命令
CMD ["ls", "-la", "/deploy"]
'@

    $dockerfile | Out-File -FilePath "$deployDir\Dockerfile" -Encoding utf8 -NoNewline
    
    # 复制源代码
    Copy-Item -Path "backend" -Destination "$deployDir\backend" -Recurse -Force
    Copy-Item -Path "frontend" -Destination "$deployDir\frontend" -Recurse -Force
    
    # 清理不必要的文件
    $excludePaths = @(
        "$deployDir\backend\target",
        "$deployDir\frontend\node_modules",
        "$deployDir\frontend\.next"
    )
    
    foreach ($path in $excludePaths) {
        if (Test-Path $path) {
            Remove-Item -Recurse -Force $path
        }
    }
    
    # 创建构建脚本
    $buildScript = @'
#!/usr/bin/env pwsh

# Docker 编译脚本

Write-Host "🐳 开始 Docker 编译..." -ForegroundColor Cyan

try {
    # 构建镜像
    Write-Host "🔨 构建 Docker 镜像..." -ForegroundColor Blue
    docker build -t portfoliopulse-builder .
    
    if ($LASTEXITCODE -ne 0) {
        throw "Docker 镜像构建失败"
    }
    
    # 创建容器并提取文件
    Write-Host "📦 提取编译产物..." -ForegroundColor Blue
    $containerId = docker create portfoliopulse-builder
    
    # 创建输出目录
    New-Item -ItemType Directory -Path "output" -Force | Out-Null
    
    # 复制部署文件
    docker cp "${containerId}:/deploy/." "output\"
    
    # 清理容器
    docker rm $containerId | Out-Null
    
    Write-Host "✅ Docker 编译完成!" -ForegroundColor Green
    Write-Host "📁 输出目录: .\output\" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "🚀 部署步骤:" -ForegroundColor Yellow
    Write-Host "1. 上传 output 目录到服务器" -ForegroundColor White
    Write-Host "2. 在服务器执行: chmod +x start.sh && ./start.sh" -ForegroundColor White
}
catch {
    Write-Error "Docker 编译失败: $($_.Exception.Message)"
}
'@

    $buildScript | Out-File -FilePath "$deployDir\build.ps1" -Encoding utf8 -NoNewline
    
    Write-Success "Docker 编译包已创建!"
    Write-Host ""
    Write-Host "📁 Docker 编译目录: " -NoNewline -ForegroundColor Cyan  
    Write-Host (Resolve-Path $deployDir) -ForegroundColor White
    Write-Host ""
    Write-Host "🚀 使用步骤:" -ForegroundColor Cyan
    Write-Host "1. cd $deployDir" -ForegroundColor White
    Write-Host "2. .\build.ps1" -ForegroundColor White
    Write-Host "3. 上传 output 目录到服务器" -ForegroundColor White
    Write-Host "4. 在服务器执行: chmod +x start.sh && ./start.sh" -ForegroundColor White
}

function Show-InteractiveMenu {
    Write-Title "🎯 PortfolioPulse Ubuntu 22.04 部署方案"
    
    Write-Host @"
基于当前 Windows 环境的交叉编译挑战，推荐以下两种可靠方案：

🥇 方案1: 服务器端编译 (强烈推荐)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ 100% 兼容性保证 - 在目标服务器上原生编译
✅ 零环境依赖 - 自动安装所有需要的工具
✅ 一键完成 - 上传源码，一个脚本搞定编译部署
✅ 完整管理工具 - 包含启动/停止/监控脚本

适用场景: 有服务器 SSH 访问权限
所需时间: 5-10 分钟（取决于网络速度）

🥈 方案2: Docker 容器编译  
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ 本地编译 - 在 Windows 上使用 Docker 模拟 Ubuntu
✅ 环境隔离 - 完全隔离的编译环境
✅ 可重复性 - 每次编译结果一致

适用场景: 已安装 Docker Desktop
所需时间: 10-15 分钟

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

请选择方案 (1-2):
"@ -ForegroundColor White

    $choice = Read-Host
    
    switch ($choice) {
        "1" {
            Create-ServerCompilePackage
        }
        "2" {
            Create-DockerCompilePackage  
        }
        default {
            Write-Warning "无效选择，默认使用服务器端编译方案"
            Create-ServerCompilePackage
        }
    }
}

# 主逻辑
if ($ServerCompile) {
    Create-ServerCompilePackage
}
elseif ($DockerCompile) {
    Create-DockerCompilePackage
}
else {
    Show-InteractiveMenu
}

Write-Host ""
Write-Host "💡 提示: 这两种方案都可以完美解决 Windows 交叉编译的兼容性问题!" -ForegroundColor Green
