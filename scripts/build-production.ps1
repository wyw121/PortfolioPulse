#!/usr/bin/env pwsh
# PortfolioPulse 生产构建脚本

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("development", "production")]
    [string]$Environment = "production",

    [Parameter(Mandatory=$false)]
    [switch]$Docker,

    [Parameter(Mandatory=$false)]
    [switch]$Binary
)

Write-Host "🏗️ 构建 PortfolioPulse ($Environment 环境)..." -ForegroundColor Green

$ErrorActionPreference = "Stop"

# 创建构建目录
$buildDir = "build"
if (Test-Path $buildDir) {
    Remove-Item -Recurse -Force $buildDir
}
New-Item -ItemType Directory -Path $buildDir | Out-Null

Write-Host "📁 创建构建目录: $buildDir" -ForegroundColor Blue

if ($Docker) {
    # Docker 构建方式
    Write-Host "🐳 使用 Docker 构建..." -ForegroundColor Yellow

    # 构建前端镜像
    Write-Host "🔨 构建前端 Docker 镜像..." -ForegroundColor Cyan
    docker build -f Dockerfile.frontend -t portfoliopulse-frontend:latest .

    # 构建后端镜像
    Write-Host "🔨 构建后端 Docker 镜像..." -ForegroundColor Cyan
    docker build -f Dockerfile.backend -t portfoliopulse-backend:latest .

    # 保存镜像到文件
    Write-Host "💾 导出 Docker 镜像..." -ForegroundColor Cyan
    docker save portfoliopulse-frontend:latest > "$buildDir/frontend-image.tar"
    docker save portfoliopulse-backend:latest > "$buildDir/backend-image.tar"

    # 复制 docker-compose 文件
    Copy-Item "docker-compose.yml" "$buildDir/"
    Copy-Item ".env.example" "$buildDir/.env"

    Write-Host "✅ Docker 镜像构建完成" -ForegroundColor Green

} elseif ($Binary) {
    # 二进制文件构建方式
    Write-Host "⚙️ 构建可执行二进制文件..." -ForegroundColor Yellow

    # 构建前端静态文件
    Write-Host "🔨 构建前端静态文件..." -ForegroundColor Cyan
    Set-Location frontend

    # 设置生产环境变量
    $env:NODE_ENV = $Environment
    $env:NEXT_PUBLIC_API_URL = "http://localhost:8000"

    npm run build
    if ($LASTEXITCODE -ne 0) {
        throw "前端构建失败"
    }

    # 复制构建产物
    Copy-Item -Recurse ".next/static" "../$buildDir/frontend-static"
    Copy-Item -Recurse "public" "../$buildDir/frontend-public"
    if (Test-Path ".next/standalone") {
        Copy-Item -Recurse ".next/standalone" "../$buildDir/frontend-standalone"
    }

    Set-Location ..
    Write-Host "✅ 前端构建完成" -ForegroundColor Green

    # 构建后端二进制文件
    Write-Host "🔨 构建后端二进制文件..." -ForegroundColor Cyan
    Set-Location backend

    # 设置 Rust 环境
    $env:CARGO_BUILD_TARGET = "x86_64-pc-windows-msvc"
    if ($Environment -eq "production") {
        cargo build --release
        $binaryPath = "target/release/portfolio_pulse.exe"
    } else {
        cargo build
        $binaryPath = "target/debug/portfolio_pulse.exe"
    }

    if ($LASTEXITCODE -ne 0) {
        throw "后端构建失败"
    }

    # 复制二进制文件
    Copy-Item $binaryPath "../$buildDir/portfolio_pulse.exe"
    Copy-Item "Cargo.toml" "../$buildDir/"
    if (Test-Path "migrations") {
        Copy-Item -Recurse "migrations" "../$buildDir/"
    }

    Set-Location ..
    Write-Host "✅ 后端构建完成" -ForegroundColor Green

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

} else {
    # 传统方式：复制源代码和依赖
    Write-Host "📦 准备传统部署包..." -ForegroundColor Yellow

    # 复制前端代码
    Write-Host "📄 准备前端代码..." -ForegroundColor Cyan
    Copy-Item -Recurse "frontend" "$buildDir/"

    # 复制后端代码
    Write-Host "📄 准备后端代码..." -ForegroundColor Cyan
    Copy-Item -Recurse "backend" "$buildDir/"

    # 复制配置文件
    Copy-Item "docker-compose.yml" "$buildDir/"
    Copy-Item ".env.example" "$buildDir/.env"
    Copy-Item "README.md" "$buildDir/"

    Write-Host "✅ 部署包准备完成" -ForegroundColor Green
}

# 创建部署说明文档
$deploymentGuide = @"
# PortfolioPulse 部署指南

## 构建信息
- 构建时间: $(Get-Date)
- 构建环境: $Environment
- 构建方式: $(if ($Docker) { "Docker" } elseif ($Binary) { "Binary" } else { "Traditional" })

## 部署步骤

### 1. 环境准备
$(if ($Binary) { "- 安装 MySQL 8.0+`n- 配置环境变量（参考 .env 文件）`n- 确保端口 8000 可用" } else { "- 安装 Docker 和 Docker Compose`n- 配置 .env 文件`n- 确保端口 3000, 8000, 3306 可用" })

### 2. 启动服务
$(if ($Docker) { "docker load < frontend-image.tar`ndocker load < backend-image.tar`ndocker-compose up -d" } elseif ($Binary) { "chmod +x start.sh && ./start.sh (Linux/Mac)`nstart.bat (Windows)" } else { "cd frontend && npm install && npm run build`ncd ../backend && cargo build --release`ndocker-compose up -d" })

### 3. 验证部署
- 后端健康检查: http://localhost:8000/api/health
$(if (-not $Binary) { "- 前端访问: http://localhost:3000" })

## 故障排除
- 检查日志: docker-compose logs -f
- 重启服务: docker-compose restart
- 数据库连接问题: 检查 DATABASE_URL 配置

## 维护命令
- 查看状态: docker-compose ps
- 停止服务: docker-compose down
- 更新镜像: 重新构建并替换镜像文件
"@

$deploymentGuide | Out-File -FilePath "$buildDir/DEPLOYMENT.md" -Encoding UTF8

# 计算构建包大小
$buildSize = (Get-ChildItem -Recurse $buildDir | Measure-Object -Property Length -Sum).Sum
$buildSizeMB = [math]::Round($buildSize / 1MB, 2)

Write-Host ""
Write-Host "🎉 构建完成！" -ForegroundColor Green
Write-Host "📦 构建产物: $buildDir/" -ForegroundColor Blue
Write-Host "💾 构建大小: ${buildSizeMB} MB" -ForegroundColor Blue
Write-Host "📚 部署文档: $buildDir/DEPLOYMENT.md" -ForegroundColor Blue

if ($Binary) {
    Write-Host ""
    Write-Host "🚀 快速部署:" -ForegroundColor Cyan
    Write-Host "   1. 将 $buildDir 目录上传到服务器"
    Write-Host "   2. 配置数据库连接"
    Write-Host "   3. 运行 start.sh 或 start.bat"
} elseif ($Docker) {
    Write-Host ""
    Write-Host "🐳 Docker 部署:" -ForegroundColor Cyan
    Write-Host "   1. 将 $buildDir 目录上传到服务器"
    Write-Host "   2. 加载镜像: docker load < frontend-image.tar"
    Write-Host "   3. 加载镜像: docker load < backend-image.tar"
    Write-Host "   4. 启动服务: docker-compose up -d"
}
