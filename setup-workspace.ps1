# PortfolioPulse 工作区优化设置脚本
# 作用：快速配置开发环境和工作区设置

Write-Host '🚀 开始优化 PortfolioPulse 工作区...' -ForegroundColor Green

# 检查必要的工具
Write-Host '📋 检查开发环境...' -ForegroundColor Yellow

# 检查 Node.js
if (Get-Command 'node' -ErrorAction SilentlyContinue) {
    $nodeVersion = node --version
    Write-Host "✅ Node.js: $nodeVersion" -ForegroundColor Green
} else {
    Write-Host '❌ Node.js 未安装，请先安装 Node.js' -ForegroundColor Red
}

# 检查 Rust
if (Get-Command 'rustc' -ErrorAction SilentlyContinue) {
    $rustVersion = rustc --version
    Write-Host "✅ Rust: $rustVersion" -ForegroundColor Green
} else {
    Write-Host '❌ Rust 未安装，请先安装 Rust' -ForegroundColor Red
}

# 检查 MySQL
if (Get-Command 'mysql' -ErrorAction SilentlyContinue) {
    Write-Host '✅ MySQL 工具已安装' -ForegroundColor Green
} else {
    Write-Host '⚠️  MySQL 客户端工具未找到' -ForegroundColor Yellow
}

Write-Host "`n📁 设置工作区文件夹权限..." -ForegroundColor Yellow

# 确保构建目录存在
$buildDirs = @(
    '.\frontend\.next',
    '.\backend\target',
    '.\build'
)

foreach ($dir in $buildDirs) {
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "✅ 创建目录: $dir" -ForegroundColor Green
    }
}

Write-Host "`n🔧 配置 VS Code 工作区..." -ForegroundColor Yellow

# 复制优化后的工作区文件
if (Test-Path '.\PortfolioPulse-Optimized.code-workspace') {
    Copy-Item '.\PortfolioPulse-Optimized.code-workspace' '.\PortfolioPulse.code-workspace' -Force
    Write-Host '✅ 已更新主工作区配置' -ForegroundColor Green
}

Write-Host "`n📦 安装前端依赖..." -ForegroundColor Yellow
Push-Location '.\frontend'
try {
    if (Test-Path 'package.json') {
        npm install
        Write-Host '✅ 前端依赖安装完成' -ForegroundColor Green
    }
} catch {
    Write-Host "❌ 前端依赖安装失败: $_" -ForegroundColor Red
} finally {
    Pop-Location
}

Write-Host "`n🦀 检查 Rust 依赖..." -ForegroundColor Yellow
Push-Location '.\backend'
try {
    if (Test-Path 'Cargo.toml') {
        cargo check
        Write-Host '✅ Rust 依赖检查完成' -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Rust 依赖检查失败: $_" -ForegroundColor Red
} finally {
    Pop-Location
}

Write-Host "`n✨ 工作区优化完成！" -ForegroundColor Green
Write-Host '📋 可用的工作区配置文件：' -ForegroundColor Cyan
Write-Host '  • PortfolioPulse.code-workspace - 主工作区（推荐）' -ForegroundColor White
Write-Host '  • frontend/frontend-only.code-workspace - 纯前端开发' -ForegroundColor White
Write-Host '  • backend/backend-only.code-workspace - 纯后端开发' -ForegroundColor White

Write-Host "`n🚀 快速启动命令：" -ForegroundColor Cyan
Write-Host '  • 前端开发: cd frontend && npm run dev' -ForegroundColor White
Write-Host '  • 后端开发: cd backend && cargo run' -ForegroundColor White
Write-Host '  • 完整构建: ./scripts/build-production.ps1' -ForegroundColor White

Write-Host "`n🔧 VS Code 任务快捷键：" -ForegroundColor Cyan
Write-Host '  • Ctrl+Shift+P -> Tasks: Run Task' -ForegroundColor White
Write-Host '  • 选择需要的任务（构建、运行、测试等）' -ForegroundColor White

Pause
