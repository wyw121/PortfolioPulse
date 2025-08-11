# PortfolioPulse - 终端问题修复脚本
# 解决 PowerShell 进程异常终止问题

Write-Host '=== PortfolioPulse 终端问题诊断和修复 ===' -ForegroundColor Cyan

# 1. 检查系统信息
Write-Host "`n1. 系统环境检查..." -ForegroundColor Yellow
Write-Host 'PowerShell 版本:' -NoNewline
$PSVersionTable.PSVersion
Write-Host '操作系统:' -NoNewline
Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion

# 2. 检查 Node.js 环境
Write-Host "`n2. Node.js 环境检查..." -ForegroundColor Yellow
try {
    $nodeVersion = node --version
    Write-Host "Node.js 版本: $nodeVersion" -ForegroundColor Green

    $npmVersion = npm --version
    Write-Host "npm 版本: $npmVersion" -ForegroundColor Green
} catch {
    Write-Host '错误: Node.js 未安装或不在 PATH 中' -ForegroundColor Red
    Write-Host '请从 https://nodejs.org 下载并安装 Node.js 18.17.0 或更高版本'
}

# 3. 检查 Rust 环境
Write-Host "`n3. Rust 环境检查..." -ForegroundColor Yellow
try {
    $rustcVersion = rustc --version
    Write-Host "Rust 版本: $rustcVersion" -ForegroundColor Green

    $cargoVersion = cargo --version
    Write-Host "Cargo 版本: $cargoVersion" -ForegroundColor Green
} catch {
    Write-Host '错误: Rust 未安装或不在 PATH 中' -ForegroundColor Red
    Write-Host '请从 https://rustup.rs 安装 Rust'
}

# 4. 检查执行策略
Write-Host "`n4. PowerShell 执行策略检查..." -ForegroundColor Yellow
$executionPolicy = Get-ExecutionPolicy
Write-Host "当前执行策略: $executionPolicy"

if ($executionPolicy -eq 'Restricted') {
    Write-Host '警告: 执行策略过于严格，可能导致脚本执行失败' -ForegroundColor Yellow
    Write-Host '建议运行: Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser'
}

# 5. 清理缓存和临时文件
Write-Host "`n5. 清理开发环境..." -ForegroundColor Yellow

# 清理 npm 缓存
if (Test-Path 'frontend\node_modules') {
    Write-Host '删除 node_modules...' -ForegroundColor Yellow
    Remove-Item 'frontend\node_modules' -Recurse -Force -ErrorAction SilentlyContinue
}

if (Test-Path 'frontend\package-lock.json') {
    Write-Host '删除 package-lock.json...' -ForegroundColor Yellow
    Remove-Item 'frontend\package-lock.json' -Force -ErrorAction SilentlyContinue
}

# 清理 Cargo 缓存
if (Test-Path 'backend\target') {
    Write-Host '清理 Cargo target 目录...' -ForegroundColor Yellow
    Remove-Item 'backend\target' -Recurse -Force -ErrorAction SilentlyContinue
}

# 6. 重新安装依赖
Write-Host "`n6. 重新安装依赖..." -ForegroundColor Yellow

# 前端依赖
Write-Host '安装前端依赖...' -ForegroundColor Green
Set-Location 'frontend'
try {
    npm cache clean --force
    npm install --no-optional --verbose
    Write-Host '前端依赖安装完成' -ForegroundColor Green
} catch {
    Write-Host "前端依赖安装失败: $_" -ForegroundColor Red
}
Set-Location '..'

# 后端依赖
Write-Host '构建后端项目...' -ForegroundColor Green
Set-Location 'backend'
try {
    cargo clean
    cargo build --release
    Write-Host '后端构建完成' -ForegroundColor Green
} catch {
    Write-Host "后端构建失败: $_" -ForegroundColor Red
}
Set-Location '..'

# 7. 提供启动建议
Write-Host "`n=== 修复完成 ===" -ForegroundColor Cyan
Write-Host "`n建议的启动方式:" -ForegroundColor Yellow
Write-Host '1. 使用 Windows Terminal 或 CMD 而不是 VS Code 内置终端'
Write-Host '2. 分别启动前后端服务:'
Write-Host '   前端: cd frontend && npm run dev'
Write-Host '   后端: cd backend && cargo run --release'
Write-Host '3. 如果问题持续，尝试重启 VS Code 或重启计算机'

Write-Host "`n故障排查提示:" -ForegroundColor Yellow
Write-Host '- 检查防病毒软件是否阻止了进程'
Write-Host '- 确保没有其他程序占用端口 3000 和 8000'
Write-Host '- 考虑使用 Windows Subsystem for Linux (WSL)'
