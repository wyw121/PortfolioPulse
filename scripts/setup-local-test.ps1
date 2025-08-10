#!/usr/bin/env pwsh
# PortfolioPulse 本地测试环境设置脚本 (无 Docker 依赖)

Write-Host "🚀 设置 PortfolioPulse 本地测试环境..." -ForegroundColor Green

$ErrorActionPreference = 'Stop'

# 1. 检查必需工具
Write-Host "🔍 检查开发工具..." -ForegroundColor Yellow

$tools = @{
    'node' = 'Node.js'
    'npm' = 'npm' 
    'cargo' = 'Rust'
    'mysql' = 'MySQL Client'
}

$missingTools = @()
foreach ($tool in $tools.Keys) {
    if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
        $missingTools += $tools[$tool]
        Write-Host "❌ $($tools[$tool]) 未安装" -ForegroundColor Red
    } else {
        $version = ""
        switch ($tool) {
            'node' { $version = "v" + (node --version).TrimStart('v') }
            'npm' { $version = "v" + (npm --version) }
            'cargo' { $version = (cargo --version).Split(' ')[1] }
            'mysql' { $version = "已安装" }
        }
        Write-Host "✅ $($tools[$tool]) $version" -ForegroundColor Green
    }
}

if ($missingTools.Count -gt 0) {
    Write-Host ""
    Write-Host "❌ 缺少必需工具，请先安装：" -ForegroundColor Red
    foreach ($tool in $missingTools) {
        Write-Host "   • $tool" -ForegroundColor Red
    }
    Write-Host ""
    Write-Host "安装指南：" -ForegroundColor Yellow
    Write-Host "• Node.js: https://nodejs.org/"
    Write-Host "• Rust: https://rustup.rs/"
    Write-Host "• MySQL: https://dev.mysql.com/downloads/mysql/"
    exit 1
}

# 2. 创建本地环境配置文件
Write-Host ""
Write-Host "📝 创建本地环境配置..." -ForegroundColor Yellow

$localEnv = @"
# PortfolioPulse 本地测试环境配置
NODE_ENV=development
DATABASE_URL=mysql://portfoliopulse:testpass123@localhost:3306/portfolio_pulse_dev
GITHUB_TOKEN=your_github_token_here
GITHUB_USERNAME=your_username

# API URLs
NEXT_PUBLIC_API_URL=http://localhost:8000
FRONTEND_URL=http://localhost:3000

# 调试选项
DEBUG=true
RUST_LOG=debug

# 服务器配置
BACKEND_PORT=8000
FRONTEND_PORT=3000
"@

if (-not (Test-Path ".env.local")) {
    $localEnv | Out-File -FilePath ".env.local" -Encoding UTF8
    Write-Host "✅ 创建 .env.local 配置文件" -ForegroundColor Green
} else {
    Write-Host "ℹ️ .env.local 已存在，跳过创建" -ForegroundColor Blue
}

# 3. 检查 MySQL 服务状态
Write-Host ""
Write-Host "🗄️ 检查 MySQL 服务..." -ForegroundColor Yellow

try {
    # 尝试连接 MySQL
    $mysqlTest = mysql -u root -e "SELECT 1;" 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ MySQL 服务运行正常" -ForegroundColor Green
    } else {
        Write-Host "⚠️ MySQL 服务未运行或需要密码" -ForegroundColor Yellow
        Write-Host "请确保 MySQL 服务已启动，并且可以通过以下方式连接：" -ForegroundColor Yellow
        Write-Host "   mysql -u root -p" -ForegroundColor Cyan
    }
} catch {
    Write-Host "⚠️ 无法测试 MySQL 连接" -ForegroundColor Yellow
}

# 4. 创建开发数据库
Write-Host ""
Write-Host "🔧 设置开发数据库..." -ForegroundColor Yellow

$setupDb = @"
-- 创建开发数据库和用户
CREATE DATABASE IF NOT EXISTS portfolio_pulse_dev;
CREATE USER IF NOT EXISTS 'portfoliopulse'@'localhost' IDENTIFIED BY 'testpass123';
GRANT ALL PRIVILEGES ON portfolio_pulse_dev.* TO 'portfoliopulse'@'localhost';
FLUSH PRIVILEGES;

-- 显示创建结果
SHOW DATABASES LIKE 'portfolio_pulse_dev';
SELECT User, Host FROM mysql.user WHERE User = 'portfoliopulse';
"@

$setupDb | Out-File -FilePath "setup-dev-db.sql" -Encoding UTF8

Write-Host "📄 已生成数据库设置脚本: setup-dev-db.sql" -ForegroundColor Cyan
Write-Host "请手动运行以下命令创建开发数据库：" -ForegroundColor Yellow
Write-Host "   mysql -u root -p < setup-dev-db.sql" -ForegroundColor Cyan

# 5. 安装前端依赖
Write-Host ""
Write-Host "📦 安装前端依赖..." -ForegroundColor Yellow
Set-Location frontend

if (-not (Test-Path "node_modules")) {
    npm install
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ 前端依赖安装完成" -ForegroundColor Green
    } else {
        Write-Error "❌ 前端依赖安装失败"
    }
} else {
    Write-Host "ℹ️ 前端依赖已存在，跳过安装" -ForegroundColor Blue
}

Set-Location ..

# 6. 安装 Diesel CLI (如果需要)
Write-Host ""
Write-Host "🔧 检查 Diesel CLI..." -ForegroundColor Yellow

if (-not (Get-Command diesel -ErrorAction SilentlyContinue)) {
    Write-Host "📥 安装 Diesel CLI..." -ForegroundColor Yellow
    cargo install diesel_cli --no-default-features --features mysql
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Diesel CLI 安装完成" -ForegroundColor Green
    } else {
        Write-Warning "⚠️ Diesel CLI 安装失败，您可能需要手动安装"
    }
} else {
    Write-Host "✅ Diesel CLI 已安装" -ForegroundColor Green
}

# 7. 构建后端项目 (开发版本)
Write-Host ""
Write-Host "🦀 构建 Rust 后端..." -ForegroundColor Yellow
Set-Location backend

if (-not (Test-Path "target/debug/portfolio_pulse.exe")) {
    cargo build
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ 后端构建完成" -ForegroundColor Green
    } else {
        Write-Error "❌ 后端构建失败"
    }
} else {
    Write-Host "ℹ️ 后端二进制文件已存在，跳过构建" -ForegroundColor Blue
    Write-Host "如需重新构建，请运行: cargo build" -ForegroundColor Cyan
}

Set-Location ..

# 8. 创建启动脚本
Write-Host ""
Write-Host "📜 创建本地测试启动脚本..." -ForegroundColor Yellow

$startScript = @"
#!/usr/bin/env pwsh
# PortfolioPulse 本地测试启动脚本

Write-Host "🚀 启动 PortfolioPulse 本地测试环境..." -ForegroundColor Green

# 加载环境变量
if (Test-Path ".env.local") {
    Get-Content ".env.local" | ForEach-Object {
        if ($_ -match "^([^#][^=]+)=(.*)$") {
            [Environment]::SetEnvironmentVariable($matches[1], $matches[2], "Process")
        }
    }
    Write-Host "✅ 环境变量已加载" -ForegroundColor Green
}

# 启动后端服务
Write-Host "🦀 启动后端服务 (端口 8000)..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-NoExit", "-Command", "Set-Location backend; `$env:DATABASE_URL='mysql://portfoliopulse:testpass123@localhost:3306/portfolio_pulse_dev'; cargo run" -WindowStyle Normal

# 等待后端启动
Write-Host "⏳ 等待后端服务启动..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# 测试后端连接
try {
    `$response = Invoke-WebRequest -Uri "http://localhost:8000/" -Method GET -TimeoutSec 5
    if (`$response.StatusCode -eq 200) {
        Write-Host "✅ 后端服务启动成功" -ForegroundColor Green
    }
} catch {
    Write-Host "⚠️ 后端服务可能还未完全启动，请稍等" -ForegroundColor Yellow
}

# 启动前端服务
Write-Host "⚛️ 启动前端服务 (端口 3000)..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-NoExit", "-Command", "Set-Location frontend; npm run dev" -WindowStyle Normal

Write-Host ""
Write-Host "🎉 启动完成！" -ForegroundColor Green
Write-Host "📊 前端访问: http://localhost:3000" -ForegroundColor Cyan
Write-Host "🔌 后端 API: http://localhost:8000" -ForegroundColor Cyan
Write-Host ""
Write-Host "按任意键退出..."
Read-Host
"@

$startScript | Out-File -FilePath "start-local-test.ps1" -Encoding UTF8
Write-Host "✅ 创建启动脚本: start-local-test.ps1" -ForegroundColor Green

# 9. 创建停止脚本
$stopScript = @"
#!/usr/bin/env pwsh
# PortfolioPulse 本地测试停止脚本

Write-Host "🛑 停止 PortfolioPulse 本地服务..." -ForegroundColor Yellow

# 停止 Node.js 进程 (前端)
Get-Process -Name "node" -ErrorAction SilentlyContinue | Stop-Process -Force
Write-Host "✅ 前端服务已停止" -ForegroundColor Green

# 停止 Rust 进程 (后端)
Get-Process -Name "portfolio_pulse" -ErrorAction SilentlyContinue | Stop-Process -Force
Write-Host "✅ 后端服务已停止" -ForegroundColor Green

Write-Host "🎉 所有服务已停止" -ForegroundColor Green
"@

$stopScript | Out-File -FilePath "stop-local-test.ps1" -Encoding UTF8
Write-Host "✅ 创建停止脚本: stop-local-test.ps1" -ForegroundColor Green

# 10. 显示下一步操作
Write-Host ""
Write-Host "🎯 环境设置完成！" -ForegroundColor Green
Write-Host "==================" -ForegroundColor Green
Write-Host ""
Write-Host "📋 下一步操作：" -ForegroundColor Yellow
Write-Host "1. 设置数据库：mysql -u root -p < setup-dev-db.sql" -ForegroundColor Cyan
Write-Host "2. 运行数据库迁移：cd backend && diesel migration run" -ForegroundColor Cyan
Write-Host "3. 启动测试服务：.\start-local-test.ps1" -ForegroundColor Cyan
Write-Host "4. 访问应用：http://localhost:3000" -ForegroundColor Cyan
Write-Host "5. 停止服务：.\stop-local-test.ps1" -ForegroundColor Cyan
Write-Host ""
Write-Host "🔧 故障排除：" -ForegroundColor Yellow
Write-Host "• 如果端口被占用，请检查并结束相关进程" -ForegroundColor White
Write-Host "• 如果数据库连接失败，请检查 MySQL 服务状态" -ForegroundColor White
Write-Host "• 如果构建失败，请检查 Rust 和 Node.js 版本" -ForegroundColor White
Write-Host ""
Write-Host "💡 提示：测试成功后，可以运行 .\scripts\build-production.ps1 进行生产构建" -ForegroundColor Blue
