#!/usr/bin/env pwsh

# 创建部署压缩包脚本
Write-Host "📦 创建 PortfolioPulse 部署包..." -ForegroundColor Green

$DeployDir = "build\deploy"
$PackageName = "PortfolioPulse-Ubuntu-$(Get-Date -Format 'yyyyMMdd-HHmm').tar.gz"

if (-not (Test-Path $DeployDir)) {
    Write-Error "部署目录不存在: $DeployDir"
    exit 1
}

# 检查必要文件
$RequiredFiles = @(
    "portfolio_pulse_backend",
    "server.js",
    "start.sh",
    "stop.sh",
    "status.sh",
    "README.md",
    ".env.example"
)

foreach ($file in $RequiredFiles) {
    if (-not (Test-Path "$DeployDir\$file")) {
        Write-Warning "缺少文件: $file"
    } else {
        Write-Host "✅ $file" -ForegroundColor Green
    }
}

# 创建压缩包 (需要 WSL 或者安装了 tar)
if (Get-Command wsl -ErrorAction SilentlyContinue) {
    Write-Host "🗜️ 使用 WSL 创建 tar.gz 包..." -ForegroundColor Yellow
    wsl tar -czf $PackageName -C build deploy

    if (Test-Path $PackageName) {
        $Size = [math]::Round((Get-Item $PackageName).Length / 1MB, 2)
        Write-Host "🎉 部署包创建成功!" -ForegroundColor Green
        Write-Host "📄 文件名: $PackageName" -ForegroundColor Yellow
        Write-Host "📊 大小: ${Size} MB" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "📋 上传到服务器:" -ForegroundColor Cyan
        Write-Host "scp $PackageName user@your-server:/tmp/" -ForegroundColor White
        Write-Host "ssh user@your-server" -ForegroundColor White
        Write-Host "cd /opt && sudo tar -xzf /tmp/$PackageName" -ForegroundColor White
        Write-Host "cd portfoliopulse && cp .env.example .env && nano .env" -ForegroundColor White
        Write-Host "chmod +x *.sh && ./start.sh" -ForegroundColor White
    }
} else {
    Write-Host "⚠️  未找到 WSL，创建 ZIP 包..." -ForegroundColor Yellow
    $ZipName = $PackageName.Replace('.tar.gz', '.zip')
    Compress-Archive -Path $DeployDir -DestinationPath $ZipName -Force

    if (Test-Path $ZipName) {
        $Size = [math]::Round((Get-Item $ZipName).Length / 1MB, 2)
        Write-Host "🎉 部署包创建成功!" -ForegroundColor Green
        Write-Host "📄 文件名: $ZipName" -ForegroundColor Yellow
        Write-Host "📊 大小: ${Size} MB" -ForegroundColor Yellow
    }
}
