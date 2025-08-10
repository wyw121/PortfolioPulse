#!/usr/bin/env pwsh
# PortfolioPulse 快速本地测试脚本

param(
    [Parameter(Mandatory=$false)]
    [switch]$SkipBuild,

    [Parameter(Mandatory=$false)]
    [switch]$SkipDatabase
)

Write-Host "🧪 PortfolioPulse 快速本地测试" -ForegroundColor Green
Write-Host "=============================" -ForegroundColor Green

$ErrorActionPreference = 'Continue'  # 允许继续执行即使有错误

# 1. 环境检查
Write-Host ""
Write-Host "🔍 环境检查..." -ForegroundColor Yellow

$checks = @()
if (Get-Command node -ErrorAction SilentlyContinue) {
    $checks += "✅ Node.js: $(node --version)"
} else {
    $checks += "❌ Node.js: 未安装"
}

if (Get-Command cargo -ErrorAction SilentlyContinue) {
    $cargoVersion = (cargo --version).Split(' ')[1]
    $checks += "✅ Rust: $cargoVersion"
} else {
    $checks += "❌ Rust: 未安装"
}

if (Get-Command mysql -ErrorAction SilentlyContinue) {
    $checks += "✅ MySQL Client: 已安装"
} else {
    $checks += "⚠️ MySQL Client: 未找到"
}

foreach ($check in $checks) {
    Write-Host $check
}

# 2. 设置环境变量
Write-Host ""
Write-Host "⚙️ 设置环境变量..." -ForegroundColor Yellow

$env:NODE_ENV = "development"
$env:DATABASE_URL = "mysql://portfoliopulse:testpass123@localhost:3306/portfolio_pulse_dev"
$env:NEXT_PUBLIC_API_URL = "http://localhost:8000"
$env:RUST_LOG = "info"

Write-Host "✅ 环境变量已设置" -ForegroundColor Green

# 3. 数据库快速设置（可选）
if (-not $SkipDatabase) {
    Write-Host ""
    Write-Host "🗄️ 快速数据库设置..." -ForegroundColor Yellow

    $quickDbSetup = @"
CREATE DATABASE IF NOT EXISTS portfolio_pulse_dev;
CREATE USER IF NOT EXISTS 'portfoliopulse'@'localhost' IDENTIFIED BY 'testpass123';
GRANT ALL PRIVILEGES ON portfolio_pulse_dev.* TO 'portfoliopulse'@'localhost';
FLUSH PRIVILEGES;
"@

    $quickDbSetup | Out-File -FilePath "quick-db-setup.sql" -Encoding UTF8
    Write-Host "📄 生成了快速数据库设置文件: quick-db-setup.sql" -ForegroundColor Cyan
    Write-Host "💡 如果需要，请运行: mysql -u root -p < quick-db-setup.sql" -ForegroundColor Blue
}

# 4. 前端依赖检查
Write-Host ""
Write-Host "📦 检查前端依赖..." -ForegroundColor Yellow

Set-Location frontend
if (-not (Test-Path "node_modules")) {
    Write-Host "📥 安装前端依赖..." -ForegroundColor Cyan
    npm install --silent
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ 前端依赖安装完成" -ForegroundColor Green
    } else {
        Write-Host "⚠️ 前端依赖安装可能有问题" -ForegroundColor Yellow
    }
} else {
    Write-Host "✅ 前端依赖已存在" -ForegroundColor Green
}
Set-Location ..

# 5. 后端构建（可选）
if (-not $SkipBuild) {
    Write-Host ""
    Write-Host "🦀 检查后端构建..." -ForegroundColor Yellow

    Set-Location backend
    if (-not (Test-Path "target/debug/portfolio_pulse.exe")) {
        Write-Host "🔨 构建后端..." -ForegroundColor Cyan
        cargo build --quiet
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ 后端构建完成" -ForegroundColor Green
        } else {
            Write-Host "⚠️ 后端构建可能有问题" -ForegroundColor Yellow
        }
    } else {
        Write-Host "✅ 后端二进制文件已存在" -ForegroundColor Green
    }
    Set-Location ..
}

# 6. 创建测试启动脚本
Write-Host ""
Write-Host "📜 生成测试启动命令..." -ForegroundColor Yellow

$testCommands = @"
# PortfolioPulse 本地测试命令

## 🚀 启动服务（在不同终端窗口中运行）

### 启动后端 (终端 1):
cd backend
`$env:DATABASE_URL="mysql://portfoliopulse:testpass123@localhost:3306/portfolio_pulse_dev"
cargo run

### 启动前端 (终端 2):
cd frontend
npm run dev

## 📊 访问地址
- 前端: http://localhost:3000
- 后端 API: http://localhost:8000

## 🔧 测试命令
- 测试后端健康: curl http://localhost:8000/
- 测试 API: curl http://localhost:8000/api/projects

## 🛑 停止服务
Ctrl+C 在各自终端中停止服务
"@

$testCommands | Out-File -FilePath "LOCAL_TEST_COMMANDS.md" -Encoding UTF8

# 7. 创建一键启动脚本
$oneClickStart = @"
#!/usr/bin/env pwsh
# 一键启动本地测试

Write-Host "🚀 启动 PortfolioPulse 本地测试..." -ForegroundColor Green

# 设置环境变量
`$env:NODE_ENV="development"
`$env:DATABASE_URL="mysql://portfoliopulse:testpass123@localhost:3306/portfolio_pulse_dev"
`$env:NEXT_PUBLIC_API_URL="http://localhost:8000"
`$env:RUST_LOG="info"

Write-Host "🦀 启动后端服务..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-NoExit", "-WindowStyle", "Normal", "-Command", "Write-Host '🦀 PortfolioPulse 后端服务' -ForegroundColor Green; Set-Location backend; `$env:DATABASE_URL='mysql://portfoliopulse:testpass123@localhost:3306/portfolio_pulse_dev'; cargo run"

Write-Host "⏳ 等待后端启动..." -ForegroundColor Yellow
Start-Sleep -Seconds 3

Write-Host "⚛️ 启动前端服务..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-NoExit", "-WindowStyle", "Normal", "-Command", "Write-Host '⚛️ PortfolioPulse 前端服务' -ForegroundColor Green; Set-Location frontend; npm run dev"

Write-Host ""
Write-Host "🎉 启动完成！" -ForegroundColor Green
Write-Host "📊 前端: http://localhost:3000" -ForegroundColor Cyan
Write-Host "🔌 后端: http://localhost:8000" -ForegroundColor Cyan
Write-Host ""
Write-Host "💡 提示: 两个服务将在新的 PowerShell 窗口中运行"
Write-Host "🛑 关闭窗口或按 Ctrl+C 停止服务"
"@

$oneClickStart | Out-File -FilePath "start-test.ps1" -Encoding UTF8

Write-Host ""
Write-Host "🎯 测试环境准备完成！" -ForegroundColor Green
Write-Host "=====================" -ForegroundColor Green
Write-Host ""
Write-Host "📋 可用的测试方式：" -ForegroundColor Yellow
Write-Host ""
Write-Host "🚀 方式一：一键启动" -ForegroundColor Cyan
Write-Host "   .\start-test.ps1" -ForegroundColor White
Write-Host ""
Write-Host "🚀 方式二：手动启动" -ForegroundColor Cyan
Write-Host "   查看文件: LOCAL_TEST_COMMANDS.md" -ForegroundColor White
Write-Host ""
Write-Host "🗄️ 数据库设置（如需要）：" -ForegroundColor Yellow
Write-Host "   mysql -u root -p < quick-db-setup.sql" -ForegroundColor White
Write-Host ""
Write-Host "🧪 测试步骤建议：" -ForegroundColor Blue
Write-Host "1. 确保 MySQL 服务运行" -ForegroundColor White
Write-Host "2. 运行数据库设置（如果是首次）" -ForegroundColor White
Write-Host "3. 启动服务进行测试" -ForegroundColor White
Write-Host "4. 测试成功后运行生产构建" -ForegroundColor White
Write-Host ""
Write-Host "💡 生产构建命令: .\scripts\build-production.ps1" -ForegroundColor Green
