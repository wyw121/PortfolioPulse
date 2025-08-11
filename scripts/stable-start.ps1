# 简化的项目启动脚本
# 避免复杂的终端交互，降低崩溃风险

param(
    [switch]$Frontend,
    [switch]$Backend,
    [switch]$Both
)

function Start-Frontend {
    Write-Host '启动前端开发服务器...' -ForegroundColor Green

    if (-not (Test-Path 'frontend\node_modules')) {
        Write-Host '安装前端依赖...' -ForegroundColor Yellow
        Set-Location 'frontend'
        npm install --silent
        Set-Location '..'
    }

    # 使用 Start-Process 避免终端阻塞
    $frontendProcess = Start-Process -FilePath 'cmd' -ArgumentList '/c', 'cd frontend && npm run dev' -PassThru
    Write-Host "前端服务已启动 (PID: $($frontendProcess.Id))" -ForegroundColor Green
    Write-Host '访问地址: http://localhost:3000' -ForegroundColor Cyan
}

function Start-Backend {
    Write-Host '启动后端开发服务器...' -ForegroundColor Green

    # 检查 Rust 项目是否需要构建
    if (-not (Test-Path 'backend\target\release')) {
        Write-Host '构建后端项目...' -ForegroundColor Yellow
        Set-Location 'backend'
        cargo build --release
        Set-Location '..'
    }

    # 使用 Start-Process 避免终端阻塞
    $backendProcess = Start-Process -FilePath 'cmd' -ArgumentList '/c', 'cd backend && cargo run --release' -PassThru
    Write-Host "后端服务已启动 (PID: $($backendProcess.Id))" -ForegroundColor Green
    Write-Host 'API 地址: http://localhost:8000' -ForegroundColor Cyan
}

# 主逻辑
Write-Host '=== PortfolioPulse 稳定启动脚本 ===' -ForegroundColor Cyan

if ($Frontend -or $Both) {
    Start-Frontend
}

if ($Backend -or $Both) {
    Start-Backend
}

if (-not ($Frontend -or $Backend -or $Both)) {
    Write-Host '使用方法:' -ForegroundColor Yellow
    Write-Host '  .\scripts\stable-start.ps1 -Frontend    # 仅启动前端'
    Write-Host '  .\scripts\stable-start.ps1 -Backend     # 仅启动后端'
    Write-Host '  .\scripts\stable-start.ps1 -Both        # 同时启动前后端'
}

Write-Host "`n提示: 如果需要停止服务，请在任务管理器中结束相应进程" -ForegroundColor Yellow
