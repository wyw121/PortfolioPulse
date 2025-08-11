#!/usr/bin/env pwsh

# PortfolioPulse Linux 交叉编译脚本
# 用于在 Windows 上构建 Linux 部署的二进制文件

param(
    [switch]$Linux,
    [switch]$Windows,
    [switch]$Both
)

Write-Host "🚀 开始构建 PortfolioPulse 二进制文件..." -ForegroundColor Green

# 创建构建目录
$BuildDir = ".\build\binaries"
$DeployDir = ".\build\deploy"

if (Test-Path $BuildDir) {
    Remove-Item -Recurse -Force $BuildDir
}
if (Test-Path $DeployDir) {
    Remove-Item -Recurse -Force $DeployDir
}

New-Item -ItemType Directory -Path $BuildDir -Force | Out-Null
New-Item -ItemType Directory -Path $DeployDir -Force | Out-Null

Write-Host "📁 构建目录已创建: $BuildDir" -ForegroundColor Yellow

# 检查 Rust 交叉编译工具链
Write-Host "🔧 检查 Rust 工具链..." -ForegroundColor Blue

Set-Location backend

# 添加 Linux 目标平台（如果还没有）
$LinuxTarget = "x86_64-unknown-linux-gnu"
$installedTargets = rustup target list --installed

if (-not ($installedTargets -match $LinuxTarget)) {
    Write-Host "📥 安装 Linux 交叉编译目标..." -ForegroundColor Yellow
    rustup target add $LinuxTarget
    if ($LASTEXITCODE -ne 0) {
        Write-Error "无法安装 Linux 交叉编译目标"
        exit 1
    }
}

# 检查是否需要安装交叉编译工具
if (-not (Get-Command "x86_64-linux-gnu-gcc" -ErrorAction SilentlyContinue)) {
    Write-Host "⚠️  警告: 未检测到 Linux GCC 交叉编译器" -ForegroundColor Yellow
    Write-Host "   可能需要安装 mingw-w64 或使用 WSL 进行编译" -ForegroundColor Yellow
    Write-Host "   或者可以考虑在 GitHub Actions 中编译" -ForegroundColor Yellow
}

# 1. 构建后端 Rust 二进制文件
if ($Linux -or $Both -or (-not $Windows -and -not $Both)) {
    Write-Host "🐧 构建 Linux 后端二进制文件..." -ForegroundColor Blue
    
    # 设置交叉编译环境变量
    $env:CC_x86_64_unknown_linux_gnu = "x86_64-linux-gnu-gcc"
    $env:CXX_x86_64_unknown_linux_gnu = "x86_64-linux-gnu-g++"
    $env:AR_x86_64_unknown_linux_gnu = "x86_64-linux-gnu-ar"
    
    # 构建 Linux 版本
    cargo build --release --target $LinuxTarget
    
    if ($LASTEXITCODE -eq 0) {
        $LinuxBinary = ".\target\$LinuxTarget\release\portfolio-pulse-backend"
        if (Test-Path $LinuxBinary) {
            Copy-Item $LinuxBinary "..\build\binaries\portfolio_pulse_backend"
            Write-Host "✅ Linux 后端二进制文件已构建" -ForegroundColor Green
        } else {
            Write-Host "⚠️  Linux 二进制文件未找到，尝试其他名称..." -ForegroundColor Yellow
            # 检查其他可能的名称
            $possibleNames = @("portfolio_pulse", "portfolio-pulse", "backend", "main")
            foreach ($name in $possibleNames) {
                $binaryPath = ".\target\$LinuxTarget\release\$name"
                if (Test-Path $binaryPath) {
                    Copy-Item $binaryPath "..\build\binaries\portfolio_pulse_backend"
                    Write-Host "✅ Linux 后端二进制文件已构建 ($name)" -ForegroundColor Green
                    break
                }
            }
        }
    } else {
        Write-Host "❌ Linux 后端构建失败" -ForegroundColor Red
        Write-Host "💡 建议: 考虑使用 Docker 或 GitHub Actions 进行交叉编译" -ForegroundColor Yellow
        
        # 提供备选方案
        Write-Host "`n🔄 备选方案:" -ForegroundColor Cyan
        Write-Host "1. 使用 WSL2 进行编译" -ForegroundColor White
        Write-Host "2. 在 Linux 服务器上直接编译" -ForegroundColor White
        Write-Host "3. 使用 GitHub Actions 自动构建" -ForegroundColor White
        Write-Host "4. 使用 Docker 容器编译" -ForegroundColor White
    }
}

if ($Windows -or $Both) {
    Write-Host "🪟 构建 Windows 后端二进制文件..." -ForegroundColor Blue
    
    cargo build --release
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Windows 后端构建失败"
        exit 1
    }

    # 复制 Windows 后端二进制文件
    $WindowsBinary = ".\target\release\portfolio-pulse-backend.exe"
    if (Test-Path $WindowsBinary) {
        Copy-Item $WindowsBinary "..\build\binaries\portfolio_pulse_backend.exe"
        Write-Host "✅ Windows 后端二进制文件已构建" -ForegroundColor Green
    } else {
        Write-Error "未找到 Windows 后端二进制文件"
        exit 1
    }
}

# 返回根目录
Set-Location ..

# 2. 构建前端 Next.js 应用
Write-Host "🟢 构建前端 Next.js 应用..." -ForegroundColor Blue
Set-Location frontend

# 清理缓存
if (Test-Path .next) {
    Remove-Item -Recurse -Force .next
}

# 构建前端
npm run build
if ($LASTEXITCODE -ne 0) {
    Write-Error "前端构建失败"
    exit 1
}

# 检查 standalone 输出
if (Test-Path ".next\standalone") {
    Write-Host "✅ Standalone 构建成功" -ForegroundColor Green

    # 复制 standalone 应用
    Copy-Item -Recurse ".next\standalone\*" "..\build\binaries\" -Force

    # 复制静态文件
    if (Test-Path ".next\static") {
        New-Item -ItemType Directory -Path "..\build\binaries\.next\static" -Force | Out-Null
        Copy-Item -Recurse ".next\static\*" "..\build\binaries\.next\static\" -Force
    }

    # 复制 public 文件
    if (Test-Path "public") {
        Copy-Item -Recurse "public\*" "..\build\binaries\public\" -Force
    }

} else {
    Write-Error "Standalone 构建输出不存在，请检查 next.config.js 是否配置了 output: 'standalone'"
    exit 1
}

# 返回根目录
Set-Location ..

# 3. 创建 Linux 部署脚本
Write-Host "📜 创建部署脚本..." -ForegroundColor Blue

# Linux 启动脚本
$LinuxStartScript = @"
#!/bin/bash
# PortfolioPulse Linux 启动脚本

set -e

echo "🚀 启动 PortfolioPulse..."

# 检查依赖
if ! command -v node &> /dev/null; then
    echo "❌ Node.js 未安装"
    echo "请安装 Node.js: curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - && sudo apt-get install -y nodejs"
    exit 1
fi

# 设置环境变量
export NODE_ENV=production
export PORT=3000

# 加载环境变量文件
if [ -f ".env" ]; then
    export `$(cat .env | xargs)`
    echo "✅ 已加载环境变量"
fi

# 添加执行权限
chmod +x ./portfolio_pulse_backend 2>/dev/null || true

# 启动后端服务
echo "🦀 启动后端服务 (端口 8000)..."
nohup ./portfolio_pulse_backend > backend.log 2>&1 &
BACKEND_PID=`$!
echo `$BACKEND_PID > backend.pid

# 等待后端启动
echo "⏳ 等待后端服务启动..."
sleep 5

# 检查后端是否启动成功
if ! kill -0 `$BACKEND_PID 2>/dev/null; then
    echo "❌ 后端服务启动失败"
    echo "📋 后端日志:"
    cat backend.log
    exit 1
fi

# 启动前端服务
echo "🟢 启动前端服务 (端口 3000)..."
nohup node server.js > frontend.log 2>&1 &
FRONTEND_PID=`$!
echo `$FRONTEND_PID > frontend.pid

# 等待前端启动
echo "⏳ 等待前端服务启动..."
sleep 3

# 检查前端是否启动成功
if ! kill -0 `$FRONTEND_PID 2>/dev/null; then
    echo "❌ 前端服务启动失败"
    echo "📋 前端日志:"
    cat frontend.log
    kill `$BACKEND_PID 2>/dev/null || true
    exit 1
fi

echo "✅ PortfolioPulse 启动成功!"
echo "后端 PID: `$BACKEND_PID"
echo "前端 PID: `$FRONTEND_PID"
echo "🌐 访问地址: http://localhost:3000"
"@

# Windows 启动脚本
$WindowsStartScript = @"
@echo off
REM PortfolioPulse Windows 启动脚本

echo 🚀 启动 PortfolioPulse...

REM 设置环境变量
set NODE_ENV=production
set PORT=3000

REM 启动后端服务
echo 🦀 启动后端服务...
start /b portfolio_pulse_backend.exe > backend.log 2>&1

REM 等待后端启动
timeout /t 3 > nul

REM 启动前端服务
echo 🟢 启动前端服务...
start /b node server.js > frontend.log 2>&1

echo ✅ PortfolioPulse 启动成功!
echo 🌐 访问地址: http://localhost:3000
"@

# 保存脚本
$LinuxStartScript | Out-File -FilePath "$DeployDir\start.sh" -Encoding utf8 -NoNewline
$WindowsStartScript | Out-File -FilePath "$DeployDir\start.bat" -Encoding utf8 -NoNewline

# Linux 停止脚本
$LinuxStopScript = @"
#!/bin/bash
# PortfolioPulse Linux 停止脚本

echo "🛑 停止 PortfolioPulse..."

# 停止前端
if [ -f frontend.pid ]; then
    kill `$(cat frontend.pid) 2>/dev/null || true
    rm frontend.pid
fi

# 停止后端
if [ -f backend.pid ]; then
    kill `$(cat backend.pid) 2>/dev/null || true
    rm backend.pid
fi

echo "✅ PortfolioPulse 已停止!"
"@

$LinuxStopScript | Out-File -FilePath "$DeployDir\stop.sh" -Encoding utf8 -NoNewline

# 4. 打包部署文件
Write-Host "📦 打包部署文件..." -ForegroundColor Blue

# 复制二进制文件到部署目录
Copy-Item "$BuildDir\*" $DeployDir -Recurse -Force

# 创建部署说明
$DeployGuide = @"
# PortfolioPulse 部署指南

## 系统要求

### Linux 服务器
- Ubuntu 18.04+ / CentOS 7+ / Debian 9+
- Node.js 18+
- MySQL 5.7+ 或 8.0+
- 2GB+ RAM (推荐 4GB)
- 10GB+ 磁盘空间

## 部署步骤

1. 上传部署文件到服务器:
   ```bash
   scp -r deploy/ user@server:/opt/portfoliopulse/
   ```

2. 在服务器上设置权限:
   ```bash
   chmod +x /opt/portfoliopulse/portfolio_pulse_backend
   chmod +x /opt/portfoliopulse/start.sh
   chmod +x /opt/portfoliopulse/stop.sh
   ```

3. 配置环境变量:
   ```bash
   cp .env.example .env
   nano .env
   ```

4. 启动服务:
   ```bash
   cd /opt/portfoliopulse
   ./start.sh
   ```

## 故障排查

如果后端启动失败，检查:
1. 文件权限: `ls -la portfolio_pulse_backend`
2. 系统架构: `uname -m` (应该是 x86_64)
3. 依赖库: `ldd portfolio_pulse_backend`
4. 日志文件: `cat backend.log`

如果是架构不匹配，需要在对应系统上重新编译:
```bash
git clone <your-repo>
cd backend
cargo build --release
```
"@

$DeployGuide | Out-File -FilePath "$DeployDir\DEPLOY_GUIDE.md" -Encoding utf8

Write-Host ""
Write-Host "🎉 构建完成!" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host "📁 部署文件位置: $DeployDir" -ForegroundColor Yellow
Write-Host "📜 部署脚本:" -ForegroundColor Yellow
Write-Host "  - Linux: start.sh, stop.sh" -ForegroundColor White
Write-Host "  - Windows: start.bat" -ForegroundColor White
Write-Host ""
Write-Host "🚀 下一步:" -ForegroundColor Cyan
Write-Host "1. 将 deploy/ 目录上传到服务器" -ForegroundColor White
Write-Host "2. 设置执行权限" -ForegroundColor White
Write-Host "3. 配置环境变量" -ForegroundColor White
Write-Host "4. 运行 ./start.sh" -ForegroundColor White
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray

# 显示文件信息
Write-Host "`n📊 构建结果:" -ForegroundColor Blue
Get-ChildItem $DeployDir -Recurse | Format-Table Name, Length, LastWriteTime -AutoSize
