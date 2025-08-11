#!/usr/bin/env pwsh

# PortfolioPulse Windows 交叉编译脚本 - 修复版
# 专门用于在 Windows 上生成 Ubuntu 22.04 LTS 兼容的二进制文件

param(
    [switch]$UseMusl,
    [switch]$UseDocker,
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"

Write-Host "🚀 PortfolioPulse Windows 交叉编译脚本" -ForegroundColor Cyan
Write-Host "🎯 目标: Ubuntu 22.04 LTS" -ForegroundColor Green
Write-Host ""

function Write-Step {
    param([string]$Message)
    Write-Host "🔹 $Message" -ForegroundColor Blue
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

# 方案1: Musl 静态编译 (修复版)
function Use-MuslCompile {
    Write-Step "使用 Musl 静态编译"
    
    if (-not (Test-Command "rustc")) {
        Write-Error "Rust 未安装，请先运行: .\install_dev_environment.ps1"
        return $false
    }
    
    if (-not (Test-Command "node")) {
        Write-Error "Node.js 未安装，请先运行: .\install_dev_environment.ps1"
        return $false
    }
    
    # 确保目标已安装
    Write-Host "📦 确认编译目标..." -ForegroundColor Blue
    rustup target add x86_64-unknown-linux-musl
    rustup target add x86_64-unknown-linux-gnu
    
    # 创建构建目录
    New-Item -ItemType Directory -Path ".\build\musl-output" -Force | Out-Null
    
    # 编译后端
    Write-Host "🦀 编译后端..." -ForegroundColor Blue
    Push-Location backend
    
    try {
        # 清理之前的构建
        cargo clean
        
        # 优先尝试 GNU 目标
        $targetTriple = "x86_64-unknown-linux-gnu"
        Write-Host "🎯 使用目标: $targetTriple" -ForegroundColor Yellow
        
        # 配置链接器
        if (-not (Test-Command "x86_64-linux-gnu-gcc")) {
            Write-Host "⚠️  使用 Rust 内置链接器..." -ForegroundColor Yellow
            $env:RUSTFLAGS = "-C linker=rust-lld -C target-cpu=generic"
        }
        else {
            $env:CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER = "x86_64-linux-gnu-gcc"
        }
        
        # 开始编译
        cargo build --release --target $targetTriple
        
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "GNU 目标编译失败，尝试 musl 目标..."
            
            # 切换到 musl 目标
            $targetTriple = "x86_64-unknown-linux-musl"
            $env:RUSTFLAGS = "-C target-feature=+crt-static -C link-self-contained=yes -C linker=rust-lld"
            
            cargo build --release --target $targetTriple
            
            if ($LASTEXITCODE -ne 0) {
                Write-Error "所有目标编译失败"
                return $false
            }
        }
        
        # 查找编译产物
        $targetDir = "target\$targetTriple\release"
        if (-not (Test-Path $targetDir)) {
            Write-Error "编译产物目录不存在: $targetDir"
            return $false
        }
        
        # 查找可执行文件
        $possibleNames = @(
            "portfolio-pulse-backend",
            "portfolio_pulse_backend", 
            "portfolio-pulse", 
            "portfolio_pulse",
            "backend", 
            "main"
        )
        
        $foundBinary = $null
        foreach ($name in $possibleNames) {
            $binaryPath = "$targetDir\$name"
            if (Test-Path $binaryPath) {
                $foundBinary = $binaryPath
                Write-Host "✅ 找到二进制文件: $name" -ForegroundColor Green
                break
            }
        }
        
        if (-not $foundBinary) {
            # 列出所有文件找到可执行文件
            Write-Host "🔍 搜索可执行文件..." -ForegroundColor Yellow
            $executables = Get-ChildItem $targetDir -File | Where-Object { 
                $_.Name -notmatch '\.(d|pdb|rlib|rmeta)$' -and $_.Length -gt 100KB 
            }
            
            if ($executables) {
                $foundBinary = $executables[0].FullName
                Write-Host "✅ 找到可执行文件: $($executables[0].Name)" -ForegroundColor Green
            }
            else {
                Write-Error "未找到编译后的二进制文件"
                Write-Host "target 目录内容:" -ForegroundColor Yellow
                Get-ChildItem $targetDir | Format-Table Name, Length, LastWriteTime
                return $false
            }
        }
        
        # 复制后端二进制文件
        $outputBinary = "..\build\musl-output\portfolio_pulse_backend"
        Copy-Item $foundBinary $outputBinary -Force
        
        Write-Success "后端编译成功"
        Write-Host "  📦 源文件: $foundBinary" -ForegroundColor Gray
        Write-Host "  📦 输出: $outputBinary" -ForegroundColor Gray
        
        # 显示文件信息
        $fileInfo = Get-Item $outputBinary
        Write-Host "  📊 文件大小: $([math]::Round($fileInfo.Length / 1MB, 2)) MB" -ForegroundColor Gray
    }
    catch {
        Write-Error "后端编译失败: $($_.Exception.Message)"
        return $false
    }
    finally {
        Pop-Location
    }
    
    # 编译前端
    Write-Host "🟢 编译前端..." -ForegroundColor Blue
    Push-Location frontend
    
    try {
        # 安装依赖
        Write-Host "📦 安装依赖..." -ForegroundColor Gray
        npm ci
        
        if ($LASTEXITCODE -ne 0) {
            Write-Error "npm install 失败"
            return $false
        }
        
        # 构建前端
        Write-Host "🏗️  构建应用..." -ForegroundColor Gray
        npm run build
        
        if ($LASTEXITCODE -ne 0) {
            Write-Error "前端构建失败"
            return $false
        }
        
        # 复制前端文件
        if (Test-Path ".next\standalone") {
            Write-Host "📁 复制前端文件..." -ForegroundColor Gray
            
            # 复制 standalone 应用
            Copy-Item -Path ".next\standalone\*" -Destination "..\build\musl-output\" -Recurse -Force
            
            # 复制静态资源
            if (Test-Path ".next\static") {
                New-Item -ItemType Directory -Path "..\build\musl-output\.next\static" -Force | Out-Null
                Copy-Item -Path ".next\static\*" -Destination "..\build\musl-output\.next\static\" -Recurse -Force
            }
            
            # 复制 public 文件
            if (Test-Path "public") {
                Copy-Item -Path "public\*" -Destination "..\build\musl-output\public\" -Recurse -Force
            }
            
            Write-Success "前端编译成功"
        }
        else {
            Write-Error "未找到 Next.js standalone 输出"
            Write-Host "请检查 next.config.js 是否配置了 output: 'standalone'" -ForegroundColor Yellow
            return $false
        }
    }
    catch {
        Write-Error "前端编译失败: $($_.Exception.Message)"
        return $false
    }
    finally {
        Pop-Location
    }
    
    # 创建部署脚本
    Create-LinuxDeploymentScripts ".\build\musl-output"
    
    Write-Success "Musl 静态编译完成！"
    Write-Host "📁 输出目录: .\build\musl-output" -ForegroundColor Gray
    Show-DeploymentGuide ".\build\musl-output"
    
    return $true
}

# 方案2: Docker 编译
function Use-DockerCompile {
    Write-Step "使用 Docker 进行交叉编译"
    
    if (-not (Test-Command "docker")) {
        Write-Error "Docker 未安装"
        Write-Host "请安装 Docker Desktop: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
        return $false
    }
    
    Write-Host "🐳 使用 Docker 容器进行编译..." -ForegroundColor Blue
    
    # 创建 Dockerfile
    $dockerfile = @'
FROM ubuntu:22.04

# 设置非交互模式
ENV DEBIAN_FRONTEND=noninteractive

# 安装构建依赖
RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    pkg-config \
    libssl-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 安装 Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# 安装 Node.js 18 LTS
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

# 设置工作目录
WORKDIR /app

# 复制项目文件
COPY . .

# 构建后端
WORKDIR /app/backend
RUN cargo build --release

# 构建前端
WORKDIR /app/frontend
RUN npm ci && npm run build

# 创建输出目录并复制文件
WORKDIR /app
RUN mkdir -p /output && \
    find backend/target/release -maxdepth 1 -type f -executable -size +1M | head -1 | xargs -I {} cp {} /output/portfolio_pulse_backend && \
    cp -r frontend/.next/standalone/* /output/ && \
    [ -d frontend/.next/static ] && cp -r frontend/.next/static /output/.next/ || true && \
    [ -d frontend/public ] && cp -r frontend/public /output/ || true

CMD ["ls", "-la", "/output"]
'@

    $dockerfile | Out-File -FilePath ".\Dockerfile.cross-compile" -Encoding utf8 -NoNewline
    
    try {
        # 构建 Docker 镜像
        Write-Host "🔨 构建 Docker 镜像..." -ForegroundColor Yellow
        docker build -f Dockerfile.cross-compile -t portfoliopulse-builder .
        
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Docker 镜像构建失败"
            return $false
        }
        
        # 创建容器并提取文件
        Write-Host "📦 提取编译产物..." -ForegroundColor Yellow
        $containerId = docker create portfoliopulse-builder
        
        # 创建输出目录
        New-Item -ItemType Directory -Path ".\build\docker-output" -Force | Out-Null
        
        # 复制文件
        docker cp "${containerId}:/output/." ".\build\docker-output\"
        docker rm $containerId
        
        # 创建部署脚本
        Create-LinuxDeploymentScripts ".\build\docker-output"
        
        Write-Success "Docker 编译完成！"
        Write-Host "📁 输出目录: .\build\docker-output" -ForegroundColor Gray
        Show-DeploymentGuide ".\build\docker-output"
        
        return $true
    }
    catch {
        Write-Error "Docker 编译失败: $($_.Exception.Message)"
        return $false
    }
}

# 创建 Linux 部署脚本
function Create-LinuxDeploymentScripts {
    param([string]$OutputDir)
    
    Write-Host "📝 创建部署脚本..." -ForegroundColor Blue
    
    # 创建启动脚本
    $startScript = @'
#!/bin/bash
# PortfolioPulse 启动脚本

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🚀 PortfolioPulse 启动中...${NC}"

# 设置权限
chmod +x portfolio_pulse_backend

# 环境变量
export NODE_ENV=production
export PORT=3000
[ -f ".env" ] && source .env

# 启动后端
echo -e "${BLUE}🦀 启动后端服务...${NC}"
nohup ./portfolio_pulse_backend > backend.log 2>&1 &
echo $! > backend.pid

# 等待后端启动
for i in {1..30}; do
    if curl -s http://localhost:8000 >/dev/null 2>&1; then
        echo -e "${GREEN}✅ 后端启动成功${NC}"
        break
    fi
    sleep 1
done

# 启动前端
echo -e "${BLUE}🟢 启动前端服务...${NC}"
nohup node server.js > frontend.log 2>&1 &
echo $! > frontend.pid

# 等待前端启动
for i in {1..20}; do
    if curl -s http://localhost:3000 >/dev/null 2>&1; then
        echo -e "${GREEN}✅ 前端启动成功${NC}"
        break
    fi
    sleep 1
done

echo -e "${GREEN}🎉 PortfolioPulse 启动完成！${NC}"
echo -e "访问地址: ${CYAN}http://localhost:3000${NC}"
'@

    # 停止脚本
    $stopScript = @'
#!/bin/bash
# PortfolioPulse 停止脚本

echo "🛑 停止 PortfolioPulse..."

for pid_file in backend.pid frontend.pid; do
    if [ -f "$pid_file" ]; then
        pid=$(cat "$pid_file")
        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid"
            echo "已停止进程: $pid"
        fi
        rm -f "$pid_file"
    fi
done

echo "✅ 所有服务已停止"
'@

    # 状态脚本
    $statusScript = @'
#!/bin/bash
# PortfolioPulse 状态检查

echo "📊 PortfolioPulse 状态："

for service in backend frontend; do
    pid_file="${service}.pid"
    if [ -f "$pid_file" ]; then
        pid=$(cat "$pid_file")
        if kill -0 "$pid" 2>/dev/null; then
            echo "✅ $service 运行中 (PID: $pid)"
        else
            echo "❌ $service 已停止"
        fi
    else
        echo "❌ $service 未运行"
    fi
done
'@

    # 保存脚本
    $startScript | Out-File -FilePath "$OutputDir\start.sh" -Encoding utf8 -NoNewline
    $stopScript | Out-File -FilePath "$OutputDir\stop.sh" -Encoding utf8 -NoNewline  
    $statusScript | Out-File -FilePath "$OutputDir\status.sh" -Encoding utf8 -NoNewline
    
    # 创建环境变量模板
    $envTemplate = @'
# PortfolioPulse 环境变量配置

# 数据库配置
DATABASE_URL=mysql://username:password@localhost:3306/portfolio_pulse

# 应用配置
NODE_ENV=production
PORT=3000

# 日志级别
RUST_LOG=info
'@

    $envTemplate | Out-File -FilePath "$OutputDir\.env.example" -Encoding utf8 -NoNewline
}

# 显示部署指南
function Show-DeploymentGuide {
    param([string]$OutputDir)
    
    Write-Host "`n🎉 编译完成！" -ForegroundColor Green
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
    
    Write-Host "📁 部署包位置: " -NoNewline -ForegroundColor Yellow
    Write-Host (Resolve-Path $OutputDir) -ForegroundColor White
    
    Write-Host "`n📦 包含文件:" -ForegroundColor Yellow
    Get-ChildItem $OutputDir | ForEach-Object {
        if ($_.PSIsContainer) {
            Write-Host "  📁 $($_.Name)/" -ForegroundColor Blue
        }
        else {
            $size = if ($_.Length -gt 1MB) { "{0:N1} MB" -f ($_.Length / 1MB) } else { "{0:N0} KB" -f ($_.Length / 1KB) }
            Write-Host "  📄 $($_.Name) ($size)" -ForegroundColor White
        }
    }
    
    Write-Host "`n🚀 Ubuntu 22.04 部署步骤:" -ForegroundColor Cyan
    Write-Host "1. 上传到服务器:" -ForegroundColor White
    Write-Host "   scp -r $(Split-Path $OutputDir -Leaf) user@server:/opt/portfoliopulse/" -ForegroundColor Gray
    Write-Host "2. 设置权限:" -ForegroundColor White  
    Write-Host "   chmod +x /opt/portfoliopulse/*.sh /opt/portfoliopulse/portfolio_pulse_backend" -ForegroundColor Gray
    Write-Host "3. 配置环境:" -ForegroundColor White
    Write-Host "   cp .env.example .env && nano .env" -ForegroundColor Gray
    Write-Host "4. 启动服务:" -ForegroundColor White
    Write-Host "   ./start.sh" -ForegroundColor Gray
    
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
}

# 主函数
function Main {
    # 检查项目结构
    if (-not (Test-Path "backend\Cargo.toml") -or -not (Test-Path "frontend\package.json")) {
        Write-Error "请在 PortfolioPulse 项目根目录运行此脚本"
        Write-Host "当前目录: $(Get-Location)" -ForegroundColor Yellow
        Write-Host "需要存在: backend/Cargo.toml 和 frontend/package.json" -ForegroundColor Yellow
        return
    }
    
    if ($UseMusl) {
        Use-MuslCompile
    }
    elseif ($UseDocker) {
        Use-DockerCompile
    }
    else {
        # 交互式选择
        Write-Host @"
🎯 选择 Windows 交叉编译方案:

1. Musl 静态编译 (推荐)
   - 使用现有 Rust 和 Node.js 环境
   - 静态链接，无依赖问题
   - 编译速度快

2. Docker 编译
   - 完全隔离的编译环境
   - 保证 Ubuntu 22.04 兼容性
   - 需要 Docker Desktop

选择方案 (1-2):
"@ -ForegroundColor Cyan
        
        $choice = Read-Host
        
        switch ($choice) {
            "1" { Use-MuslCompile }
            "2" { Use-DockerCompile }
            default {
                Write-Warning "无效选择，默认使用 Musl 编译"
                Use-MuslCompile
            }
        }
    }
}

# 帮助信息
if ($args -contains "-h" -or $args -contains "--help") {
    Write-Host @"
🚀 PortfolioPulse Windows 交叉编译脚本

用法:
  .\windows_cross_compile.ps1 [选项]

选项:
  -UseMusl         使用 Musl 静态编译
  -UseDocker       使用 Docker 进行编译
  -Verbose         显示详细的构建信息
  -h, --help       显示此帮助信息

示例:
  .\windows_cross_compile.ps1              # 交互式选择
  .\windows_cross_compile.ps1 -UseMusl     # 直接使用 Musl
  .\windows_cross_compile.ps1 -UseDocker   # 直接使用 Docker

目标系统: Ubuntu 22.04 LTS (x86_64)
"@
    exit 0
}

# 执行主函数
Main
