#!/usr/bin/env pwsh

# PortfolioPulse 二进制构建脚本
# 用于在 Windows 上构建 Linux 部署的二进制文件

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

# 1. 构建后端 Rust 二进制文件
Write-Host "🦀 构建后端 Rust 二进制文件..." -ForegroundColor Blue
Set-Location backend
cargo build --release
if ($LASTEXITCODE -ne 0) {
    Write-Error "后端构建失败"
    exit 1
}

# 复制后端二进制文件
$BackendBinary = ".\target\release\portfolio-pulse-backend.exe"
if (Test-Path $BackendBinary) {
    Copy-Item $BackendBinary "..\build\binaries\portfolio_pulse_backend.exe"
    Write-Host "✅ 后端二进制文件已构建" -ForegroundColor Green
} else {
    Write-Error "未找到后端二进制文件"
    exit 1
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
    Write-Error "Standalone 构建输出不存在"
    exit 1
}

# 返回根目录
Set-Location ..

# 3. 创建部署包
Write-Host "📦 创建部署包..." -ForegroundColor Blue

# 创建启动脚本
$StartScript = @"
#!/bin/bash
# PortfolioPulse 启动脚本

set -e

echo "🚀 启动 PortfolioPulse..."

# 设置环境变量
export NODE_ENV=production
export PORT=3000

# 启动后端服务
echo "🦀 启动后端服务..."
nohup ./portfolio_pulse_backend.exe > backend.log 2>&1 &
BACKEND_PID=`$!
echo `$BACKEND_PID > backend.pid

# 等待后端启动
sleep 3

# 启动前端服务
echo "🟢 启动前端服务..."
nohup node server.js > frontend.log 2>&1 &
FRONTEND_PID=`$!
echo `$FRONTEND_PID > frontend.pid

echo "✅ PortfolioPulse 启动成功!"
echo "后端 PID: `$BACKEND_PID"
echo "前端 PID: `$FRONTEND_PID"
echo "🌐 访问地址: http://localhost:3000"
"@

$StopScript = @"
#!/bin/bash
# PortfolioPulse 停止脚本

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

# 写入脚本文件
$StartScript | Out-File -Encoding UTF8 "$DeployDir\start.sh"
$StopScript | Out-File -Encoding UTF8 "$DeployDir\stop.sh"

# 复制二进制文件到部署目录
Copy-Item -Recurse "$BuildDir\*" $DeployDir -Force

# 创建环境配置模板
$EnvTemplate = @"
# PortfolioPulse 环境配置
NODE_ENV=production
PORT=3000
DATABASE_URL=mysql://portfoliopulse:password@localhost:3306/portfolio_pulse
GITHUB_TOKEN=your_github_token_here
GITHUB_USERNAME=your_username_here
RUST_LOG=info
"@

$EnvTemplate | Out-File -Encoding UTF8 "$DeployDir\.env.example"

# 创建部署说明
$DeployGuide = @"
# PortfolioPulse 部署指南

## 文件说明
- portfolio_pulse_backend.exe: 后端服务二进制文件
- server.js: 前端服务入口文件
- start.sh: 启动脚本
- stop.sh: 停止脚本
- .env.example: 环境变量模板

## 部署步骤
1. 将整个 deploy 目录上传到 Ubuntu 服务器
2. 重命名 .env.example 为 .env 并配置环境变量
3. 给脚本添加执行权限: chmod +x start.sh stop.sh
4. 运行 ./start.sh 启动服务

## 端口说明
- 前端: 3000
- 后端: 8000
- MySQL: 3306

## 日志文件
- backend.log: 后端日志
- frontend.log: 前端日志
"@

$DeployGuide | Out-File -Encoding UTF8 "$DeployDir\README.md"

Write-Host "🎉 构建完成!" -ForegroundColor Green
Write-Host "📁 构建文件位置: $BuildDir" -ForegroundColor Yellow
Write-Host "📦 部署包位置: $DeployDir" -ForegroundColor Yellow
Write-Host ""
Write-Host "📋 下一步:" -ForegroundColor Cyan
Write-Host "1. 将 build/deploy 目录上传到 Ubuntu 服务器" -ForegroundColor White
Write-Host "2. 配置 .env 环境变量" -ForegroundColor White
Write-Host "3. 运行 ./start.sh 启动服务" -ForegroundColor White
