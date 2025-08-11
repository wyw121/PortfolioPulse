#!/usr/bin/env pwsh

# PortfolioPulse Windows 到 Ubuntu 交叉编译脚本（简化版）
# 用于在 Windows 上构建 Ubuntu 22.04 兼容的二进制文件

param(
    [switch]$SetupOnly,
    [switch]$BuildOnly,
    [switch]$CheckDeps
)

$ErrorActionPreference = "Stop"

Write-Host "🐧 PortfolioPulse Windows → Ubuntu 交叉编译" -ForegroundColor Cyan
Write-Host "🎯 目标: Ubuntu 22.04 LTS (x86_64)" -ForegroundColor Green
Write-Host ""

function Write-Step {
    param([string]$Message)
    Write-Host "🔹 $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
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

# 检查依赖
function Test-Dependencies {
    Write-Step "检查构建依赖"

    $deps = @()

    if (-not (Test-Command "rustc")) {
        $deps += "Rust (https://rustup.rs/)"
    }

    if (-not (Test-Command "node")) {
        $deps += "Node.js 18+ (https://nodejs.org/)"
    }

    if (-not (Test-Command "npm")) {
        $deps += "npm (随 Node.js 安装)"
    }

    if ($deps.Count -gt 0) {
        Write-Error "缺少以下依赖:"
        foreach ($dep in $deps) {
            Write-Host "  - $dep" -ForegroundColor Yellow
        }
        return $false
    }

    Write-Success "所有依赖已安装"
    return $true
}

# 安装 Linux 目标
function Install-LinuxTarget {
    Write-Step "安装 Linux 交叉编译目标"

    $targets = rustup target list --installed
    if ($targets -match "x86_64-unknown-linux-gnu") {
        Write-Success "Linux 目标已安装"
        return $true
    }

    Write-Host "📥 安装 x86_64-unknown-linux-gnu..." -ForegroundColor Yellow
    rustup target add x86_64-unknown-linux-gnu

    if ($LASTEXITCODE -eq 0) {
        Write-Success "Linux 目标安装成功"
        return $true
    } else {
        Write-Error "Linux 目标安装失败"
        return $false
    }
}

# 设置交叉编译配置
function Setup-CrossCompile {
    Write-Step "配置交叉编译环境"

    $cargoDir = ".cargo"
    $configFile = "$cargoDir\config.toml"

    if (-not (Test-Path $cargoDir)) {
        New-Item -ItemType Directory -Path $cargoDir -Force | Out-Null
    }

    $configContent = @"
[target.x86_64-unknown-linux-gnu]
linker = "x86_64-linux-gnu-gcc"

[env]
CC_x86_64_unknown_linux_gnu = "x86_64-linux-gnu-gcc"
CXX_x86_64_unknown_linux_gnu = "x86_64-linux-gnu-g++"
"@

    Set-Content -Path $configFile -Value $configContent -Encoding UTF8
    Write-Success "交叉编译配置已创建: $configFile"
}

# 构建后端
function Build-Backend {
    Write-Step "构建 Rust 后端 (Linux 目标)"

    if (-not (Test-Path "backend\Cargo.toml")) {
        Write-Error "找不到 backend\Cargo.toml"
        return $false
    }

    Push-Location "backend"
    try {
        Write-Host "🦀 编译中..." -ForegroundColor Yellow
        cargo build --release --target x86_64-unknown-linux-gnu

        if ($LASTEXITCODE -eq 0) {
            $binaryPath = "target\x86_64-unknown-linux-gnu\release\portfolio-pulse-backend"
            if (Test-Path $binaryPath) {
                Write-Success "后端编译成功: $binaryPath"
                return $true
            } else {
                Write-Error "后端二进制文件未找到"
                return $false
            }
        } else {
            Write-Error "后端编译失败"
            return $false
        }
    }
    finally {
        Pop-Location
    }
}

# 构建前端
function Build-Frontend {
    Write-Step "构建 Next.js 前端"

    if (-not (Test-Path "frontend\package.json")) {
        Write-Error "找不到 frontend\package.json"
        return $false
    }

    Push-Location "frontend"
    try {
        Write-Host "📦 安装依赖..." -ForegroundColor Yellow
        npm ci

        if ($LASTEXITCODE -ne 0) {
            Write-Error "npm install 失败"
            return $false
        }

        Write-Host "🏗️ 构建应用..." -ForegroundColor Yellow
        npm run build

        if ($LASTEXITCODE -eq 0) {
            if (Test-Path ".next\standalone") {
                Write-Success "前端构建成功 (.next\standalone)"
                return $true
            } else {
                Write-Error "Standalone 输出未找到，检查 next.config.js"
                return $false
            }
        } else {
            Write-Error "前端构建失败"
            return $false
        }
    }
    finally {
        Pop-Location
    }
}

# 创建部署包
function Create-DeployPackage {
    Write-Step "创建部署包"

    $deployDir = "deploy"

    if (Test-Path $deployDir) {
        Remove-Item $deployDir -Recurse -Force
    }

    New-Item -ItemType Directory -Path $deployDir -Force | Out-Null

    # 复制后端二进制文件
    $backendBinary = "backend\target\x86_64-unknown-linux-gnu\release\portfolio-pulse-backend"
    if (Test-Path $backendBinary) {
        Copy-Item $backendBinary "$deployDir\portfolio_pulse_backend"
        Write-Success "后端二进制已复制"
    } else {
        Write-Error "后端二进制文件未找到"
        return $false
    }

    # 复制前端文件
    if (Test-Path "frontend\.next\standalone") {
        Copy-Item "frontend\.next\standalone\*" $deployDir -Recurse -Force
        Write-Success "前端 Standalone 已复制"
    } else {
        Write-Error "前端 Standalone 输出未找到"
        return $false
    }

    # 复制静态资源
    if (Test-Path "frontend\.next\static") {
        New-Item -ItemType Directory -Path "$deployDir\.next\static" -Force | Out-Null
        Copy-Item "frontend\.next\static\*" "$deployDir\.next\static" -Recurse -Force
        Write-Success "静态资源已复制"
    }

    # 复制 public 目录
    if (Test-Path "frontend\public") {
        Copy-Item "frontend\public" $deployDir -Recurse -Force
        Write-Success "Public 资源已复制"
    }

    # 创建管理脚本
    Create-ManagementScripts $deployDir

    Write-Success "部署包创建完成: $deployDir"
    return $true
}

# 创建管理脚本
function Create-ManagementScripts {
    param([string]$DeployDir)

    # start.sh
    $startScript = @"
#!/bin/bash
echo "🚀 启动 PortfolioPulse..."

# 检查文件
if [ ! -f "portfolio_pulse_backend" ]; then
    echo "❌ 后端文件不存在"
    exit 1
fi

if [ ! -f "server.js" ]; then
    echo "❌ 前端服务文件不存在"
    exit 1
fi

# 验证文件格式
FILE_TYPE=`$(file portfolio_pulse_backend)`
if [[ "`$FILE_TYPE" != *"ELF 64-bit"* ]]; then
    echo "❌ 后端文件不是有效的 Linux 二进制文件"
    echo "文件类型: `$FILE_TYPE"
    exit 1
fi

# 设置权限
chmod +x portfolio_pulse_backend

# 启动后端
echo "🦀 启动后端服务..."
nohup ./portfolio_pulse_backend > backend.log 2>&1 &
echo `$! > backend.pid
echo "后端 PID: `$(cat backend.pid)"

# 等待后端启动
sleep 3

# 启动前端
echo "🟢 启动前端服务..."
export NODE_ENV=production
export PORT=3000
nohup node server.js > frontend.log 2>&1 &
echo `$! > frontend.pid
echo "前端 PID: `$(cat frontend.pid)"

echo "✅ 服务启动完成"
echo "🌐 前端: http://localhost:3000"
echo "🔌 后端: http://localhost:8000"
"@

    Set-Content -Path "$DeployDir\start.sh" -Value $startScript -Encoding UTF8

    # stop.sh
    $stopScript = @"
#!/bin/bash
echo "🛑 停止 PortfolioPulse 服务..."

if [ -f "backend.pid" ]; then
    PID=`$(cat backend.pid)
    if kill -0 "`$PID" 2>/dev/null; then
        kill "`$PID"
        echo "✅ 后端已停止"
    fi
    rm -f backend.pid
fi

if [ -f "frontend.pid" ]; then
    PID=`$(cat frontend.pid)
    if kill -0 "`$PID" 2>/dev/null; then
        kill "`$PID"
        echo "✅ 前端已停止"
    fi
    rm -f frontend.pid
fi

echo "✅ 所有服务已停止"
"@

    Set-Content -Path "$DeployDir\stop.sh" -Value $stopScript -Encoding UTF8

    # .env.example
    $envExample = @"
# PortfolioPulse 环境变量配置

# 数据库配置
DATABASE_URL=mysql://username:password@localhost:3306/portfolio_pulse

# 应用配置
NODE_ENV=production
PORT=3000

# GitHub 集成
GITHUB_TOKEN=your_token_here
GITHUB_USERNAME=your_username

# 其他配置
RUST_LOG=info
"@

    Set-Content -Path "$DeployDir\.env.example" -Value $envExample -Encoding UTF8

    # README.md
    $readme = @"
# PortfolioPulse Ubuntu 部署包

## 🚀 快速部署

1. 上传到服务器：
   ``bash
   rsync -av deploy/ user@server:/opt/portfoliopulse/
   ``

2. 配置并启动：
   ``bash
   cd /opt/portfoliopulse
   cp .env.example .env
   nano .env
   chmod +x *.sh portfolio_pulse_backend
   ./start.sh
   ``

## 🔍 验证部署

``bash
# 检查文件格式
file portfolio_pulse_backend
# 期望输出: ELF 64-bit LSB pie executable

# 访问服务
curl http://localhost:3000  # 前端
curl http://localhost:8000  # 后端
``

## 📊 管理命令

- `./start.sh` - 启动服务
- `./stop.sh` - 停止服务
- `tail -f backend.log` - 查看后端日志
- `tail -f frontend.log` - 查看前端日志
"@

    Set-Content -Path "$DeployDir\README.md" -Value $readme -Encoding UTF8

    Write-Success "管理脚本已创建"
}

# 主流程
function Main {
    if ($CheckDeps) {
        Test-Dependencies
        return
    }

    if (-not (Test-Dependencies)) {
        Write-Error "请先安装缺少的依赖"
        return
    }

    if ($SetupOnly) {
        Install-LinuxTarget
        Setup-CrossCompile
        Write-Success "交叉编译环境设置完成"
        Write-Host "⚠️ 注意：本地交叉编译可能遇到链接器问题" -ForegroundColor Yellow
        Write-Host "📝 推荐使用 GitHub Actions 云编译获得最佳兼容性" -ForegroundColor Yellow
        return
    }

    # 完整构建流程
    if (-not (Install-LinuxTarget)) { return }
    Setup-CrossCompile

    Write-Host "`n⚠️ 开始交叉编译..." -ForegroundColor Yellow
    Write-Host "注意：如果遇到链接器错误，建议使用 GitHub Actions 云编译" -ForegroundColor Yellow
    Write-Host ""

    if (-not (Build-Backend)) {
        Write-Error "后端构建失败，考虑使用 GitHub Actions"
        return
    }

    if (-not (Build-Frontend)) {
        Write-Error "前端构建失败"
        return
    }

    if (-not (Create-DeployPackage)) {
        Write-Error "部署包创建失败"
        return
    }

    Write-Host "`n🎉 交叉编译完成！" -ForegroundColor Green
    Write-Host "📦 部署包位置: deploy/" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "📋 下一步："
    Write-Host "1. 上传 deploy/ 目录到 Ubuntu 服务器"
    Write-Host "2. 在服务器上执行 chmod +x *.sh portfolio_pulse_backend"
    Write-Host "3. 运行 ./start.sh 启动服务"
    Write-Host ""
    Write-Host "🔍 验证命令："
    Write-Host "file deploy/portfolio_pulse_backend  # 应显示 'ELF 64-bit'"
}

# 运行主流程
Main
