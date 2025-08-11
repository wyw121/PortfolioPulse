#!/usr/bin/env pwsh

# PortfolioPulse 最简化 Windows 交叉编译脚本
# 专门修复交叉编译问题

$ErrorActionPreference = "Stop"

Write-Host "🔧 PortfolioPulse Windows 交叉编译修复脚本" -ForegroundColor Cyan
Write-Host ""

function Write-Step {
    param([string]$Message)
    Write-Host "🔹 $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

function Fix-RustEnvironment {
    Write-Step "修复 Rust 交叉编译环境"

    # 重新安装目标
    Write-Host "🔄 重新安装目标..." -ForegroundColor Yellow
    rustup target remove x86_64-unknown-linux-musl
    rustup target remove x86_64-unknown-linux-gnu

    Start-Sleep -Seconds 2

    rustup target add x86_64-unknown-linux-gnu
    rustup target add x86_64-unknown-linux-musl

    # 更新工具链
    Write-Host "🔄 更新工具链..." -ForegroundColor Yellow
    rustup update

    Write-Success "Rust 环境修复完成"
}

function Try-SimpleCompile {
    Write-Step "尝试简单编译测试"

    Push-Location backend

    try {
        Write-Host "🧪 测试基本编译..." -ForegroundColor Yellow

        # 清理
        cargo clean

        # 尝试最简单的配置
        $env:RUSTFLAGS = ""
        $env:CC = ""
        $env:CXX = ""

        # 移除所有环境变量
        Get-ChildItem Env: | Where-Object { $_.Name -like "CARGO_TARGET_*" } | Remove-Item
        Get-ChildItem Env: | Where-Object { $_.Name -like "CC_*" } | Remove-Item
        Get-ChildItem Env: | Where-Object { $_.Name -like "CXX_*" } | Remove-Item

        # 首先尝试本地编译确认项目没问题
        Write-Host "1️⃣ 测试本地编译..." -ForegroundColor Cyan
        cargo check

        if ($LASTEXITCODE -ne 0) {
            Write-Error "本地编译检查失败，项目可能有问题"
            return $false
        }

        Write-Success "本地编译检查通过"

        # 尝试 GNU 目标，使用最少的配置
        Write-Host "2️⃣ 尝试 GNU 目标交叉编译..." -ForegroundColor Cyan

        cargo build --release --target x86_64-unknown-linux-gnu

        if ($LASTEXITCODE -eq 0) {
            Write-Success "GNU 目标编译成功!"
            return $true
        }

        Write-Warning "GNU 目标编译失败，尝试 Windows 目标确认环境..."

        # 如果失败，先确认 Windows 编译能工作
        cargo build --release

        if ($LASTEXITCODE -eq 0) {
            Write-Success "Windows 编译正常，问题是交叉编译配置"
            return $false
        }
        else {
            Write-Error "Windows 编译也失败，项目本身有问题"
            return $false
        }
    }
    finally {
        Pop-Location
    }
}

function Create-WindowsBinary {
    Write-Step "创建 Windows 二进制文件 (临时方案)"

    Write-Host "🔄 由于交叉编译问题，先创建 Windows 版本进行测试..." -ForegroundColor Yellow

    Push-Location backend

    try {
        cargo build --release

        if ($LASTEXITCODE -ne 0) {
            Write-Error "Windows 编译失败"
            return $false
        }

        # 查找 Windows 二进制文件
        $windowsBinary = Get-ChildItem "target\release" -File | Where-Object {
            $_.Name -match "(portfolio|backend|main)" -and $_.Extension -eq ".exe"
        } | Select-Object -First 1

        if ($windowsBinary) {
            # 创建输出目录
            New-Item -ItemType Directory -Path "..\build\windows-temp" -Force | Out-Null

            # 复制二进制文件
            Copy-Item $windowsBinary.FullName "..\build\windows-temp\portfolio_pulse_backend.exe" -Force

            Write-Success "Windows 二进制文件已创建"
            Write-Host "⚠️  注意：这是 Windows 版本，不能直接在 Linux 上运行" -ForegroundColor Yellow
            Write-Host "📁 位置: .\build\windows-temp\portfolio_pulse_backend.exe" -ForegroundColor Gray

            return $true
        }
        else {
            Write-Error "未找到 Windows 二进制文件"
            return $false
        }
    }
    finally {
        Pop-Location
    }
}

function Show-Recommendations {
    Write-Host "`n💡 推荐解决方案" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray

    Write-Host @"
由于 Rust 交叉编译环境存在问题，推荐以下方案：

🥇 方案1: 使用 Docker 编译 (推荐)
   .\windows_cross_compile.ps1 -UseDocker
   - 完全隔离的 Ubuntu 22.04 环境
   - 保证兼容性

🥈 方案2: 在 Linux 服务器上编译
   1. 上传源代码到 Ubuntu 22.04 服务器
   2. 在服务器上直接编译：
      cd backend && cargo build --release
      cd ../frontend && npm ci && npm run build

🥉 方案3: 使用 GitHub Actions
   .\windows_cross_compile.ps1 (选择云编译)
   - 免费的云端编译
   - 自动生成 Linux 二进制文件

🔧 调试选项: 重置 Rust 环境
   rustup self uninstall
   # 重新安装 Rust
   # 然后重试编译
"@ -ForegroundColor White

    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
}

# 主函数
function Main {
    Write-Host "🔍 诊断交叉编译问题..." -ForegroundColor Blue

    if (-not (Test-Path "backend\Cargo.toml")) {
        Write-Error "请在 PortfolioPulse 项目根目录运行"
        return
    }

    # 显示当前 Rust 状态
    Write-Host "`n📋 当前 Rust 环境:" -ForegroundColor Yellow
    rustup show

    Write-Host "`n选择操作:" -ForegroundColor Cyan
    Write-Host "1. 修复 Rust 环境并重试" -ForegroundColor White
    Write-Host "2. 测试简单编译" -ForegroundColor White
    Write-Host "3. 创建 Windows 版本 (临时)" -ForegroundColor White
    Write-Host "4. 显示推荐方案" -ForegroundColor White
    Write-Host "5. 退出" -ForegroundColor White

    $choice = Read-Host "`n选择 (1-5)"

    switch ($choice) {
        "1" {
            Fix-RustEnvironment
            Write-Host "`n现在可以尝试重新运行交叉编译脚本" -ForegroundColor Green
        }
        "2" {
            Try-SimpleCompile
        }
        "3" {
            Create-WindowsBinary
        }
        "4" {
            Show-Recommendations
        }
        "5" {
            Write-Host "退出" -ForegroundColor Green
        }
        default {
            Show-Recommendations
        }
    }
}

# 执行主函数
Main
