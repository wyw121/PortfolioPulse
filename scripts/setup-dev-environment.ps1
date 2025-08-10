#!/usr/bin/env pwsh
# PortfolioPulse 本地开发环境设置脚本

Write-Host "🚀 设置 PortfolioPulse 本地开发环境..." -ForegroundColor Green

# 1. 检查必需工具
$tools = @{
    'node' = 'Node.js'
    'npm' = 'npm'
    'cargo' = 'Rust'
    'docker' = 'Docker'
}

foreach ($tool in $tools.Keys) {
    if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
        Write-Error "❌ $($tools[$tool]) 未安装。请先安装 $($tools[$tool])"
        exit 1
    } else {
        Write-Host "✅ $($tools[$tool]) 已安装" -ForegroundColor Green
    }
}

# 2. 创建本地配置文件
Write-Host "📝 创建本地环境配置..." -ForegroundColor Yellow
$localEnv = @"
# 本地开发环境配置
NODE_ENV=development
DATABASE_URL=mysql://portfoliopulse:password@localhost:3306/portfolio_pulse_dev
GITHUB_TOKEN=your_github_token_here
GITHUB_USERNAME=your_username

# API URLs
NEXT_PUBLIC_API_URL=http://localhost:8000
FRONTEND_URL=http://localhost:3000

# 调试选项
DEBUG=true
RUST_LOG=debug
"@

$localEnv | Out-File -FilePath ".env.local" -Encoding UTF8
Write-Host "✅ 创建 .env.local 配置文件" -ForegroundColor Green

# 3. 启动本地数据库
Write-Host "🗄️ 启动本地 MySQL 数据库..." -ForegroundColor Yellow
try {
    docker run --name portfolio-mysql-dev `
        -e MYSQL_ROOT_PASSWORD=password `
        -e MYSQL_DATABASE=portfolio_pulse_dev `
        -e MYSQL_USER=portfoliopulse `
        -e MYSQL_PASSWORD=password `
        -p 3306:3306 `
        -d mysql:8.0

    Write-Host "✅ MySQL 数据库已启动" -ForegroundColor Green
    Write-Host "📊 数据库连接: mysql://portfoliopulse:password@localhost:3306/portfolio_pulse_dev"
} catch {
    Write-Warning "⚠️ 数据库可能已存在或端口被占用"
}

# 4. 安装前端依赖
Write-Host "📦 安装前端依赖..." -ForegroundColor Yellow
Set-Location frontend
npm install
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ 前端依赖安装完成" -ForegroundColor Green
} else {
    Write-Error "❌ 前端依赖安装失败"
    exit 1
}
Set-Location ..

# 5. 构建后端项目
Write-Host "🦀 构建 Rust 后端..." -ForegroundColor Yellow
Set-Location backend
cargo build
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ 后端构建完成" -ForegroundColor Green
} else {
    Write-Error "❌ 后端构建失败"
    exit 1
}
Set-Location ..

# 6. 运行数据库迁移
Write-Host "🔄 运行数据库迁移..." -ForegroundColor Yellow
Set-Location backend
# 等待数据库启动
Start-Sleep -Seconds 5

# 如果没有diesel CLI，先安装
if (-not (Get-Command diesel -ErrorAction SilentlyContinue)) {
    Write-Host "📥 安装 Diesel CLI..." -ForegroundColor Yellow
    cargo install diesel_cli --no-default-features --features mysql
}

# 运行迁移
$env:DATABASE_URL = "mysql://portfoliopulse:password@localhost:3306/portfolio_pulse_dev"
diesel migration run
Set-Location ..

Write-Host "🎉 本地开发环境设置完成！" -ForegroundColor Green
Write-Host ""
Write-Host "🚀 启动开发服务器:" -ForegroundColor Cyan
Write-Host "   前端: cd frontend && npm run dev"
Write-Host "   后端: cd backend && cargo run"
Write-Host ""
Write-Host "🌐 访问地址:" -ForegroundColor Cyan
Write-Host "   前端: http://localhost:3000"
Write-Host "   后端: http://localhost:8000"
