#!/usr/bin/env pwsh
# PortfolioPulse 生产构建脚本

param(
    [Parameter(Mandatory = $false)]
    [ValidateSet('development', 'production')]
    [string]$Environment = 'production'
)

Write-Host "🏗️ 构建 PortfolioPulse ($Environment 环境)..." -ForegroundColor Green

$ErrorActionPreference = 'Stop'

# 创建构建目录
$buildDir = 'build'
if (Test-Path $buildDir) {
    Remove-Item -Recurse -Force $buildDir
}
New-Item -ItemType Directory -Path $buildDir | Out-Null

Write-Host "📁 创建构建目录: $buildDir" -ForegroundColor Blue

# 二进制文件构建方式
Write-Host '⚙️ 构建可执行二进制文件...' -ForegroundColor Yellow

# 构建前端静态文件
Write-Host '🔨 构建前端静态文件...' -ForegroundColor Cyan
Set-Location frontend

# 设置生产环境变量
$env:NODE_ENV = $Environment
$env:NEXT_PUBLIC_API_URL = 'http://localhost:8000'

npm run build
if ($LASTEXITCODE -ne 0) {
    throw '前端构建失败'
}

# 复制构建产物
Copy-Item -Recurse '.next/static' "../$buildDir/frontend-static"
Copy-Item -Recurse 'public' "../$buildDir/frontend-public"
if (Test-Path '.next/standalone') {
    Copy-Item -Recurse '.next/standalone' "../$buildDir/frontend-standalone"
}

Set-Location ..
Write-Host '✅ 前端构建完成' -ForegroundColor Green

# 构建后端二进制文件
Write-Host '🔨 构建后端二进制文件...' -ForegroundColor Cyan
Set-Location backend

# 设置 Rust 环境
$env:CARGO_BUILD_TARGET = 'x86_64-pc-windows-msvc'
if ($Environment -eq 'production') {
    cargo build --release
    $binaryPath = 'target/release/portfolio_pulse.exe'
} else {
    cargo build
    $binaryPath = 'target/debug/portfolio_pulse.exe'
}

if ($LASTEXITCODE -ne 0) {
    throw '后端构建失败'
}

# 复制二进制文件
Copy-Item $binaryPath "../$buildDir/portfolio_pulse.exe"
Copy-Item 'Cargo.toml' "../$buildDir/"
if (Test-Path 'migrations') {
    Copy-Item -Recurse 'migrations' "../$buildDir/"
}

Set-Location ..
Write-Host '✅ 后端构建完成' -ForegroundColor Green

# 创建启动脚本
$startScript = @"
#!/bin/bash
# PortfolioPulse 启动脚本

echo "🚀 启动 PortfolioPulse..."

# 设置环境变量
export NODE_ENV=$Environment
export DATABASE_URL="mysql://portfoliopulse:password@localhost:3306/portfolio_pulse"

# 启动后端服务
echo "🦀 启动后端服务..."
./portfolio_pulse.exe &
BACKEND_PID=$!

# 等待后端启动
sleep 5

echo "✅ PortfolioPulse 启动完成！"
echo "🌐 后端 API: http://localhost:8000"
echo "📊 前端访问: 请使用 Nginx 或其他 Web 服务器托管前端静态文件"
echo ""
echo "停止服务: kill $BACKEND_PID"

# 保持运行
wait $BACKEND_PID
"@

$startScript | Out-File -FilePath "$buildDir/start.sh" -Encoding UTF8

# Windows 启动脚本
$winStartScript = @"
@echo off
echo 🚀 启动 PortfolioPulse...

REM 设置环境变量
set NODE_ENV=$Environment
set DATABASE_URL=mysql://portfoliopulse:password@localhost:3306/portfolio_pulse

REM 启动后端服务
echo 🦀 启动后端服务...
start /B portfolio_pulse.exe

echo ✅ PortfolioPulse 后端已启动！
echo 🌐 后端 API: http://localhost:8000
echo 📊 前端访问: 请使用 IIS 或其他 Web 服务器托管前端静态文件
echo.
echo 按任意键退出...
pause >nul
"@

$winStartScript | Out-File -FilePath "$buildDir/start.bat" -Encoding UTF8

# 创建部署说明文档
$deploymentGuide = @"
# PortfolioPulse 部署指南

## 构建信息
- 构建时间: $(Get-Date)
- 构建环境: $Environment
- 构建方式: Binary

## 部署步骤

### 1. 环境准备
- 安装 MySQL 8.0+
- 配置环境变量（参考 .env 文件）
- 确保端口 8000 可用

### 2. 启动服务
chmod +x start.sh && ./start.sh (Linux/Mac)
start.bat (Windows)

### 3. 验证部署
- 后端健康检查: http://localhost:8000/api/health

## 故障排除
- 检查数据库连接: 验证 DATABASE_URL 配置
- 查看日志: 检查应用输出日志
- 端口占用: 确保 8000 端口未被占用

## 维护命令
- 停止服务: Ctrl+C 或 kill 进程
- 重启服务: 重新运行启动脚本
- 更新应用: 替换二进制文件并重启
"@

$deploymentGuide | Out-File -FilePath "$buildDir/DEPLOYMENT.md" -Encoding UTF8

# 计算构建包大小
$buildSize = (Get-ChildItem -Recurse $buildDir | Measure-Object -Property Length -Sum).Sum
$buildSizeMB = [math]::Round($buildSize / 1MB, 2)

Write-Host ''
Write-Host '🎉 构建完成！' -ForegroundColor Green
Write-Host "📦 构建产物: $buildDir/" -ForegroundColor Blue
Write-Host "💾 构建大小: ${buildSizeMB} MB" -ForegroundColor Blue
Write-Host "📚 部署文档: $buildDir/DEPLOYMENT.md" -ForegroundColor Blue

Write-Host ''
Write-Host '🚀 快速部署:' -ForegroundColor Cyan
Write-Host "   1. 将 $buildDir 目录上传到服务器"
Write-Host '   2. 配置数据库连接'
Write-Host '   3. 运行 start.sh 或 start.bat'
