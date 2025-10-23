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
    Write-Host "📦 构建前端应用 (Next.js 15)..." -ForegroundColor Yellow
    Set-Location frontend
    npm ci
    npm run build
    Set-Location ..

    # 构建后端
    Write-Host "🦀 构建 Rust 后端 (API 服务)..." -ForegroundColor Yellow
    Set-Location backend
    cargo build --release
    Set-Location ..

    Write-Host "✅ 构建完成！" -ForegroundColor Green
    Write-Host "📄 Next.js 构建输出: frontend/.next/" -ForegroundColor Cyan
    Write-Host "🎯 后端二进制文件: backend/target/release/portfolio-pulse-backend.exe" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "🚀 启动服务器:" -ForegroundColor Green
    Write-Host "   前端: cd frontend && npm start (端口 3000)" -ForegroundColor White
    Write-Host "   后端: cd backend && cargo run --release (端口 8000)" -ForegroundColor White
    Write-Host "   或分别运行二进制文件" -ForegroundColor White
}
catch {
    Write-Host "❌ 构建失败: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
