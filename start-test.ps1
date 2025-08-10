#!/usr/bin/env pwsh
# 一键启动本地测试

Write-Host "🚀 启动 PortfolioPulse 本地测试..." -ForegroundColor Green

# 设置环境变量
$env:NODE_ENV="development"
$env:DATABASE_URL="mysql://portfoliopulse:testpass123@localhost:3306/portfolio_pulse_dev"
$env:NEXT_PUBLIC_API_URL="http://localhost:8000"
$env:RUST_LOG="info"

Write-Host "🦀 启动后端服务..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-NoExit", "-WindowStyle", "Normal", "-Command", "Write-Host '🦀 PortfolioPulse 后端服务' -ForegroundColor Green; Set-Location backend; $env:DATABASE_URL='mysql://portfoliopulse:testpass123@localhost:3306/portfolio_pulse_dev'; cargo run"

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
