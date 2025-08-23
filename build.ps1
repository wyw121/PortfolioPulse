# PortfolioPulse 统一构建脚本 (PowerShell)

Write-Host "🚀 开始构建 PortfolioPulse..." -ForegroundColor Cyan

# 检查必要的工具
if (!(Get-Command npm -ErrorAction SilentlyContinue)) {
    Write-Host "❌ 需要安装 npm" -ForegroundColor Red
    exit 1
}

if (!(Get-Command cargo -ErrorAction SilentlyContinue)) {
    Write-Host "❌ 需要安装 Rust" -ForegroundColor Red
    exit 1
}

try {
    # 构建前端
    Write-Host "📦 构建前端应用..." -ForegroundColor Yellow
    Set-Location frontend-vite
    npm ci
    npm run build
    Set-Location ..

    # 构建后端
    Write-Host "🦀 构建 Rust 后端..." -ForegroundColor Yellow
    Set-Location backend
    cargo build --release
    Set-Location ..

    Write-Host "✅ 构建完成！" -ForegroundColor Green
    Write-Host "📄 静态文件已生成到: backend/static/" -ForegroundColor Cyan
    Write-Host "🎯 后端二进制文件: backend/target/release/portfolio-pulse-backend.exe" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "🚀 启动服务器:" -ForegroundColor Green
    Write-Host "   cd backend; cargo run --release" -ForegroundColor White
    Write-Host "   或者运行: ./backend/target/release/portfolio-pulse-backend.exe" -ForegroundColor White
}
catch {
    Write-Host "❌ 构建失败: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
