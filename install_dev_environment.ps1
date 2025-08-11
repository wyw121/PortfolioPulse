#!/usr/bin/env pwsh

# PortfolioPulse 开发环境自动安装脚本
# 自动安装 Rust、Node.js 和交叉编译工具链

param(
    [switch]$AutoInstall,
    [switch]$SkipRust,
    [switch]$SkipNode,
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"

Write-Host "🛠️  PortfolioPulse 开发环境安装脚本" -ForegroundColor Cyan
Write-Host "📅 安装时间: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
Write-Host ""

function Write-Step {
    param([string]$Message)
    Write-Host "`n🔹 $Message" -ForegroundColor Blue
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

function Test-Command {
    param([string]$Command)
    try {
        $null = Get-Command $Command -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

function Install-Rust {
    Write-Step "安装 Rust 开发环境"

    if (Test-Command "rustc") {
        $rustVersion = rustc --version
        Write-Success "Rust 已存在: $rustVersion"
        return $true
    }

    if (-not $AutoInstall) {
        Write-Warning "Rust 未安装"
        $choice = Read-Host "是否自动安装 Rust? (y/N)"
        if ($choice -ne "y" -and $choice -ne "Y") {
            Write-Host "请手动访问 https://rustup.rs/ 安装 Rust" -ForegroundColor Yellow
            return $false
        }
    }

    try {
        Write-Host "📥 正在下载和安装 Rust..." -ForegroundColor Yellow

        # 下载 rustup 安装器
        $rustupPath = "$env:TEMP\rustup-init.exe"
        Invoke-WebRequest -Uri "https://win.rustup.rs/x86_64" -OutFile $rustupPath

        # 静默安装 Rust
        Write-Host "🔧 执行 Rust 安装..." -ForegroundColor Blue
        & $rustupPath -y --default-toolchain stable --profile default

        # 刷新环境变量
        $env:PATH = "$env:USERPROFILE\.cargo\bin;$env:PATH"

        # 验证安装
        if (Test-Command "rustc") {
            $rustVersion = rustc --version
            $cargoVersion = cargo --version
            Write-Success "Rust 安装成功!"
            Write-Host "  🦀 Rust: $rustVersion" -ForegroundColor Gray
            Write-Host "  📦 Cargo: $cargoVersion" -ForegroundColor Gray
            return $true
        }
        else {
            Write-Error "Rust 安装验证失败"
            return $false
        }
    }
    catch {
        Write-Error "Rust 安装失败: $($_.Exception.Message)"
        return $false
    }
}

function Install-NodeJS {
    Write-Step "安装 Node.js 开发环境"

    if (Test-Command "node") {
        $nodeVersion = node --version
        $npmVersion = npm --version
        Write-Success "Node.js 已存在: $nodeVersion"
        Write-Host "  📦 npm: $npmVersion" -ForegroundColor Gray
        return $true
    }

    if (-not $AutoInstall) {
        Write-Warning "Node.js 未安装"
        $choice = Read-Host "是否自动安装 Node.js? (y/N)"
        if ($choice -ne "y" -and $choice -ne "Y") {
            Write-Host "请手动访问 https://nodejs.org/ 安装 Node.js LTS" -ForegroundColor Yellow
            return $false
        }
    }

    try {
        Write-Host "📥 正在下载和安装 Node.js LTS..." -ForegroundColor Yellow

        # 使用 winget 安装 (Windows 10/11)
        if (Test-Command "winget") {
            Write-Host "🔧 使用 winget 安装 Node.js..." -ForegroundColor Blue
            winget install OpenJS.NodeJS.LTS --accept-package-agreements --accept-source-agreements
        }
        # 或使用 chocolatey
        elseif (Test-Command "choco") {
            Write-Host "🔧 使用 chocolatey 安装 Node.js..." -ForegroundColor Blue
            choco install nodejs-lts -y
        }
        else {
            # 手动下载安装
            Write-Host "🔧 手动下载安装 Node.js..." -ForegroundColor Blue
            $nodeUrl = "https://nodejs.org/dist/v18.19.0/node-v18.19.0-x64.msi"
            $nodePath = "$env:TEMP\nodejs-installer.msi"

            Invoke-WebRequest -Uri $nodeUrl -OutFile $nodePath
            Start-Process -FilePath "msiexec.exe" -ArgumentList "/i", $nodePath, "/quiet" -Wait
        }

        # 刷新环境变量
        $env:PATH = "$env:ProgramFiles\nodejs;$env:PATH"
        refreshenv | Out-Null

        # 验证安装
        Start-Sleep -Seconds 5

        if (Test-Command "node") {
            $nodeVersion = node --version
            $npmVersion = npm --version
            Write-Success "Node.js 安装成功!"
            Write-Host "  🟢 Node.js: $nodeVersion" -ForegroundColor Gray
            Write-Host "  📦 npm: $npmVersion" -ForegroundColor Gray
            return $true
        }
        else {
            Write-Error "Node.js 安装验证失败"
            return $false
        }
    }
    catch {
        Write-Error "Node.js 安装失败: $($_.Exception.Message)"
        return $false
    }
}

function Install-CrossCompileTools {
    Write-Step "安装交叉编译工具链"

    # 检查 MSYS2 是否已安装
    $msys2Path = "C:\msys64"
    if (Test-Path $msys2Path) {
        Write-Success "MSYS2 已安装"

        # 检查是否有交叉编译工具
        $crossGcc = "$msys2Path\usr\bin\x86_64-linux-gnu-gcc.exe"
        if (Test-Path $crossGcc) {
            Write-Success "Linux 交叉编译工具已安装"
            return $true
        }
    }

    if (-not $AutoInstall) {
        Write-Warning "交叉编译工具链未完整安装"
        $choice = Read-Host "是否安装 MSYS2 和交叉编译工具? (y/N)"
        if ($choice -ne "y" -and $choice -ne "Y") {
            Write-Host "将使用 musl 静态编译代替" -ForegroundColor Yellow
            return $false
        }
    }

    try {
        if (-not (Test-Path $msys2Path)) {
            Write-Host "📥 正在安装 MSYS2..." -ForegroundColor Yellow

            if (Test-Command "winget") {
                winget install MSYS2.MSYS2 --accept-package-agreements --accept-source-agreements
            }
            elseif (Test-Command "choco") {
                choco install msys2 -y
            }
            else {
                # 手动下载安装
                $msysUrl = "https://github.com/msys2/msys2-installer/releases/latest/download/msys2-x86_64-latest.exe"
                $msysPath = "$env:TEMP\msys2-installer.exe"

                Invoke-WebRequest -Uri $msysUrl -OutFile $msysPath
                Start-Process -FilePath $msysPath -ArgumentList "install", "--root", "C:\msys64", "--confirm-command" -Wait
            }
        }

        if (Test-Path $msys2Path) {
            Write-Host "🔧 配置交叉编译工具..." -ForegroundColor Blue

            # 更新 MSYS2 并安装工具
            $msys2Shell = "$msys2Path\usr\bin\bash.exe"
            & $msys2Shell -lc "pacman -Syu --noconfirm"
            & $msys2Shell -lc "pacman -S --noconfirm mingw-w64-x86_64-toolchain"
            & $msys2Shell -lc "pacman -S --noconfirm mingw-w64-x86_64-gcc"

            Write-Success "MSYS2 和交叉编译工具安装完成"
            return $true
        }
        else {
            Write-Error "MSYS2 安装失败"
            return $false
        }
    }
    catch {
        Write-Error "交叉编译工具安装失败: $($_.Exception.Message)"
        Write-Warning "将回退到 musl 静态编译"
        return $false
    }
}

function Install-RustTargets {
    Write-Step "安装 Rust 交叉编译目标"

    if (-not (Test-Command "rustup")) {
        Write-Error "rustup 不可用，请先安装 Rust"
        return $false
    }

    $targets = @(
        "x86_64-unknown-linux-gnu",
        "x86_64-unknown-linux-musl"
    )

    foreach ($target in $targets) {
        Write-Host "📦 安装目标: $target" -ForegroundColor Yellow
        rustup target add $target

        if ($LASTEXITCODE -eq 0) {
            Write-Success "已安装: $target"
        }
        else {
            Write-Warning "安装失败: $target"
        }
    }

    return $true
}

function Test-Installation {
    Write-Step "验证安装结果"

    $allGood = $true

    # 检查 Rust
    if (Test-Command "rustc") {
        $rustVersion = rustc --version
        Write-Success "Rust: $rustVersion"
    }
    else {
        Write-Error "Rust 未正确安装"
        $allGood = $false
    }

    # 检查 Node.js
    if (Test-Command "node") {
        $nodeVersion = node --version
        Write-Success "Node.js: $nodeVersion"
    }
    else {
        Write-Error "Node.js 未正确安装"
        $allGood = $false
    }

    # 检查 Rust 目标
    $installedTargets = rustup target list --installed
    $linuxTargets = $installedTargets | Where-Object { $_ -match "linux" }

    if ($linuxTargets) {
        Write-Success "Linux 编译目标: $($linuxTargets -join ', ')"
    }
    else {
        Write-Warning "未找到 Linux 编译目标"
    }

    return $allGood
}

function Main {
    try {
        Write-Host "🎯 开始安装开发环境组件" -ForegroundColor Cyan
        Write-Host ""

        $installSuccess = $true

        # 安装 Rust
        if (-not $SkipRust) {
            if (-not (Install-Rust)) {
                $installSuccess = $false
            }
        }

        # 安装 Node.js
        if (-not $SkipNode) {
            if (-not (Install-NodeJS)) {
                $installSuccess = $false
            }
        }

        # 安装交叉编译工具
        Install-CrossCompileTools | Out-Null

        # 安装 Rust 目标
        if (Test-Command "rustup") {
            Install-RustTargets | Out-Null
        }

        # 验证安装
        Write-Host "`n" -NoNewline
        if (Test-Installation) {
            Write-Host "🎉 开发环境安装完成！" -ForegroundColor Green
            Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
            Write-Host "📋 下一步操作:" -ForegroundColor Cyan
            Write-Host "1. 重启终端或刷新环境变量" -ForegroundColor White
            Write-Host "2. 运行交叉编译脚本:" -ForegroundColor White
            Write-Host "   .\build_ubuntu_cross_compile.ps1" -ForegroundColor Gray
            Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
        }
        else {
            Write-Warning "某些组件安装可能有问题，请检查上述输出"
        }
    }
    catch {
        Write-Host "`n💥 安装过程中发生错误:" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        exit 1
    }
}

# 帮助信息
if ($args -contains "-h" -or $args -contains "--help") {
    Write-Host @"
🛠️  PortfolioPulse 开发环境安装脚本

用法:
  .\install_dev_environment.ps1 [选项]

选项:
  -AutoInstall     自动安装所有组件，不询问确认
  -SkipRust        跳过 Rust 安装
  -SkipNode        跳过 Node.js 安装
  -Verbose         显示详细安装信息
  -h, --help       显示此帮助信息

示例:
  .\install_dev_environment.ps1                 # 交互式安装
  .\install_dev_environment.ps1 -AutoInstall    # 自动安装所有组件
  .\install_dev_environment.ps1 -SkipRust       # 仅安装 Node.js 相关

安装组件:
  - Rust 工具链 (rustc, cargo, rustup)
  - Node.js LTS (node, npm)
  - Linux 交叉编译目标
  - MSYS2 和交叉编译工具 (可选)
"@
    exit 0
}

# 执行主函数
Main
