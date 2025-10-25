# PortfolioPulse 部署打包脚本
# 用途: 自动构建并打包 Next.js 应用用于 Ubuntu 部署

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "  PortfolioPulse 部署打包工具" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# 设置错误处理
$ErrorActionPreference = "Stop"

# 项目路径（脚本在 scripts/ 目录下，需要返回上一级）
$ScriptDir = $PSScriptRoot
$ProjectRoot = Split-Path -Parent $ScriptDir
$FrontendDir = Join-Path $ProjectRoot "frontend"
$DeployDir = Join-Path $ProjectRoot "deploy"
$ZipFile = Join-Path $ProjectRoot "portfoliopulse.zip"

# 步骤 1: 清理旧的部署文件
Write-Host "[1/5] 清理旧的部署文件..." -ForegroundColor Yellow
if (Test-Path $DeployDir) {
    Remove-Item $DeployDir -Recurse -Force
}
if (Test-Path $ZipFile) {
    Remove-Item $ZipFile -Force
}

# 步骤 2: 构建前端
Write-Host "[2/5] 构建 Next.js 应用..." -ForegroundColor Yellow
Set-Location $FrontendDir

# 检查 node_modules
if (-not (Test-Path "node_modules")) {
    Write-Host "    安装依赖..." -ForegroundColor Gray
    npm install
}

Write-Host "    执行构建（这可能需要几分钟）..." -ForegroundColor Gray
npm run build

if ($LASTEXITCODE -ne 0) {
    Write-Host "✖ 构建失败！" -ForegroundColor Red
    exit 1
}

# 步骤 3: 检查构建产物
Write-Host "[3/5] 检查构建产物..." -ForegroundColor Yellow
$StandaloneDir = Join-Path $FrontendDir ".next\standalone"
$StaticDir = Join-Path $FrontendDir ".next\static"

if (-not (Test-Path $StandaloneDir)) {
    Write-Host "✖ 错误: standalone 目录不存在！" -ForegroundColor Red
    Write-Host "   请确保 next.config.js 中设置了 output: 'standalone'" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $StaticDir)) {
    Write-Host "✖ 错误: static 目录不存在！" -ForegroundColor Red
    exit 1
}

# 步骤 4: 打包部署文件
Write-Host "[4/5] 打包部署文件..." -ForegroundColor Yellow
Set-Location $ProjectRoot

# 创建部署目录
New-Item -ItemType Directory -Path $DeployDir -Force | Out-Null

# 复制 standalone 应用（主体）
Write-Host "    复制 standalone 应用..." -ForegroundColor Gray
Copy-Item -Path "$StandaloneDir\*" -Destination $DeployDir -Recurse

# 复制静态资源（CRITICAL: 必须放到正确位置）
Write-Host "    复制静态资源..." -ForegroundColor Gray
$DeployStaticDir = Join-Path $DeployDir ".next\static"
New-Item -ItemType Directory -Path $DeployStaticDir -Force | Out-Null
Copy-Item -Path "$StaticDir\*" -Destination $DeployStaticDir -Recurse

# 复制 public 文件夹
Write-Host "    复制 public 文件..." -ForegroundColor Gray
$PublicDir = Join-Path $FrontendDir "public"
if (Test-Path $PublicDir) {
    Copy-Item -Path $PublicDir -Destination "$DeployDir\public" -Recurse
}

# 复制博客内容
Write-Host "    复制博客内容..." -ForegroundColor Gray
$ContentDir = Join-Path $FrontendDir "content"
if (Test-Path $ContentDir) {
    Copy-Item -Path $ContentDir -Destination "$DeployDir\content" -Recurse
}

# 创建启动说明
Write-Host "    生成部署说明..." -ForegroundColor Gray
$ReadmeContent = @"
# PortfolioPulse 部署包

## 快速启动

1. 确保已安装 Node.js 18.x 或更高版本
2. 解压此文件到服务器
3. 运行启动命令:

``````bash
# 直接运行
node server.js

# 或使用 PM2
pm2 start server.js --name portfoliopulse
``````

## 环境变量（可选）

创建 .env 文件:
``````env
NODE_ENV=production
PORT=3000
HOSTNAME=0.0.0.0
``````

## 访问

默认端口: 3000
访问地址: http://localhost:3000

## 文件说明

- server.js - Next.js 启动文件
- .next/ - 构建产物
- public/ - 静态文件
- content/ - 博客文章（Markdown）

构建时间: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
构建平台: Windows
"@

Set-Content -Path "$DeployDir\README.txt" -Value $ReadmeContent -Encoding UTF8

# 步骤 5: 压缩打包
Write-Host "[5/5] 压缩打包..." -ForegroundColor Yellow
Compress-Archive -Path "$DeployDir\*" -DestinationPath $ZipFile -Force

# 获取文件大小
$ZipSize = (Get-Item $ZipFile).Length / 1MB

# 完成
Write-Host ""
Write-Host "======================================" -ForegroundColor Green
Write-Host "✓ 打包完成！" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host ""
Write-Host "部署包信息:" -ForegroundColor Cyan
Write-Host "  文件: $ZipFile" -ForegroundColor White
Write-Host "  大小: $([math]::Round($ZipSize, 2)) MB" -ForegroundColor White
Write-Host ""
Write-Host "下一步:" -ForegroundColor Cyan
Write-Host "  1. 上传到 Ubuntu 服务器" -ForegroundColor White
Write-Host "     scp $ZipFile user@server:~/" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. 在服务器上解压并运行" -ForegroundColor White
Write-Host "     unzip portfoliopulse.zip -d ~/portfoliopulse" -ForegroundColor Gray
Write-Host "     cd ~/portfoliopulse && node server.js" -ForegroundColor Gray
Write-Host ""
Write-Host "详细部署说明请查看: DEPLOY.md" -ForegroundColor Yellow
Write-Host ""
