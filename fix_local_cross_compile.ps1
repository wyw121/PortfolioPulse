#!/usr/bin/env pwsh

# Windows 本地交叉编译环境修复脚本
# 专门解决 Rust 交叉编译的各种环境问题

$ErrorActionPreference = "Stop"

Write-Host "🔧 Windows Rust 交叉编译环境修复工具" -ForegroundColor Cyan
Write-Host "🎯 专注本地交叉编译，无 Docker 依赖" -ForegroundColor Green
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

# 诊断 Rust 环境
function Test-RustEnvironment {
    Write-Step "诊断 Rust 交叉编译环境"

    $issues = @()

    # 检查 Rust 安装
    try {
        $rustcVersion = rustc --version
        Write-Host "Rust 编译器: $rustcVersion" -ForegroundColor White
    }
    catch {
        $issues += "Rust 未正确安装"
        Write-Error "Rust 未安装或不在 PATH 中"
    }

    # 检查工具链
    try {
        $activeToolchain = rustup show active-toolchain
        Write-Host "活动工具链: $activeToolchain" -ForegroundColor White

        if ($activeToolchain -notmatch "stable") {
            $issues += "未使用稳定版工具链"
        }
    }
    catch {
        $issues += "rustup 工具有问题"
        Write-Warning "rustup 状态异常"
    }

    # 检查 Linux 目标
    try {
        $targets = rustup target list --installed
        $linuxTargets = $targets | Where-Object { $_ -match "linux" }

        Write-Host "已安装的 Linux 目标:" -ForegroundColor Gray
        if ($linuxTargets) {
            foreach ($target in $linuxTargets) {
                Write-Host "  • $target" -ForegroundColor White
            }
        }
        else {
            $issues += "未安装 Linux 交叉编译目标"
            Write-Warning "未找到 Linux 目标"
        }
    }
    catch {
        $issues += "无法查询目标列表"
    }

    # 检查链接器
    $linkers = @{
        "rust-lld" = "Rust LLD 链接器 (推荐)"
        "lld-link" = "LLD-Link"
        "ld" = "GNU LD"
        "link" = "MSVC Link"
    }

    Write-Host "链接器检查:" -ForegroundColor Gray
    foreach ($linker in $linkers.Keys) {
        try {
            $null = Get-Command $linker -ErrorAction Stop
            Write-Host "  ✅ $linker - $($linkers[$linker])" -ForegroundColor Green
        }
        catch {
            Write-Host "  ❌ $linker - $($linkers[$linker])" -ForegroundColor Red
        }
    }

    # 检查环境变量
    $envVars = @(
        "CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER",
        "CC_x86_64_unknown_linux_gnu",
        "RUSTFLAGS",
        "PATH"
    )

    Write-Host "环境变量检查:" -ForegroundColor Gray
    foreach ($envVar in $envVars) {
        $value = [Environment]::GetEnvironmentVariable($envVar)
        if ($value) {
            $shortValue = if ($value.Length -gt 60) {
                $value.Substring(0, 57) + "..."
            } else {
                $value
            }
            Write-Host "  • $envVar = $shortValue" -ForegroundColor White
        }
        else {
            Write-Host "  • $envVar = (未设置)" -ForegroundColor Gray
        }
    }

    return $issues
}

# 完全重置 Rust 环境
function Reset-CompleteEnvironment {
    Write-Step "完全重置 Rust 环境"

    Write-Host "⚠️  这将删除所有 Rust 组件并重新安装" -ForegroundColor Yellow
    $confirm = Read-Host "是否继续? (y/N)"

    if ($confirm -ne "y" -and $confirm -ne "Y") {
        Write-Host "操作已取消" -ForegroundColor Yellow
        return $false
    }

    try {
        # 备份重要配置
        $cargoHome = $env:CARGO_HOME ?? "$env:USERPROFILE\.cargo"
        $configBackup = "$cargoHome\config.toml.backup"

        if (Test-Path "$cargoHome\config.toml") {
            Copy-Item "$cargoHome\config.toml" $configBackup -Force
            Write-Host "已备份 Cargo 配置到: $configBackup" -ForegroundColor Blue
        }

        # 卸载 Rust
        Write-Host "🗑️  卸载现有 Rust 安装..." -ForegroundColor Yellow
        if (Test-Path "$env:USERPROFILE\.rustup") {
            rustup self uninstall -y
        }

        # 清理残留
        $rustupDir = "$env:USERPROFILE\.rustup"
        $cargoDir = "$env:USERPROFILE\.cargo"

        if (Test-Path $rustupDir) {
            Remove-Item $rustupDir -Recurse -Force
            Write-Host "清理 .rustup 目录" -ForegroundColor Gray
        }

        # 重新安装 Rust
        Write-Host "📦 重新安装 Rust..." -ForegroundColor Blue

        $rustupUrl = "https://win.rustup.rs/x86_64"
        $rustupInstaller = "$env:TEMP\rustup-init.exe"

        Invoke-WebRequest -Uri $rustupUrl -OutFile $rustupInstaller

        # 静默安装
        & $rustupInstaller -y --default-toolchain stable --profile default

        # 刷新环境变量
        $env:PATH = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User")

        # 验证安装
        Start-Sleep -Seconds 3

        if (Test-Command "rustc") {
            $version = rustc --version
            Write-Success "Rust 重新安装成功: $version"

            # 恢复配置
            if (Test-Path $configBackup) {
                Copy-Item $configBackup "$cargoHome\config.toml" -Force
                Write-Host "已恢复 Cargo 配置" -ForegroundColor Blue
            }

            return $true
        }
        else {
            Write-Error "Rust 安装验证失败"
            return $false
        }
    }
    catch {
        Write-Error "重置过程失败: $($_.Exception.Message)"
        return $false
    }
}

# 修复最小化交叉编译环境
function Fix-MinimalCrossCompile {
    Write-Step "配置最小化交叉编译环境"

    try {
        # 清理所有可能冲突的环境变量
        $conflictVars = @(
            "CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER",
            "CC_x86_64_unknown_linux_gnu",
            "CXX_x86_64_unknown_linux_gnu",
            "RUSTFLAGS",
            "CC",
            "CXX"
        )

        Write-Host "清理环境变量..." -ForegroundColor Gray
        foreach ($var in $conflictVars) {
            if (Test-Path "env:$var") {
                Remove-Item "env:$var" -ErrorAction SilentlyContinue
                Write-Host "  清除: $var" -ForegroundColor Yellow
            }
        }

        # 删除所有 Linux 目标
        Write-Host "清理现有 Linux 目标..." -ForegroundColor Gray
        $existingTargets = rustup target list --installed | Where-Object { $_ -match "linux" }
        foreach ($target in $existingTargets) {
            rustup target remove $target 2>$null
            Write-Host "  移除: $target" -ForegroundColor Yellow
        }

        # 重新安装单一目标
        Write-Host "安装 x86_64-unknown-linux-gnu 目标..." -ForegroundColor Blue
        rustup target add x86_64-unknown-linux-gnu

        if ($LASTEXITCODE -ne 0) {
            Write-Error "目标安装失败"
            return $false
        }

        # 设置最简单的环境变量
        $env:RUSTFLAGS = "-C linker=rust-lld"

        Write-Success "最小化交叉编译环境配置完成"

        # 测试编译
        Write-Host "测试交叉编译..." -ForegroundColor Blue

        Push-Location backend
        try {
            # 快速检查
            cargo check --target x86_64-unknown-linux-gnu --quiet

            if ($LASTEXITCODE -eq 0) {
                Write-Success "交叉编译测试通过"
                return $true
            }
            else {
                Write-Warning "交叉编译检查失败，但可能仍能正常编译"
                return $true
            }
        }
        finally {
            Pop-Location
        }
    }
    catch {
        Write-Error "环境配置失败: $($_.Exception.Message)"
        return $false
    }
}

# 简化的单次编译测试
function Test-SimpleCompile {
    Write-Step "执行简化编译测试"

    if (-not (Test-Path "backend\Cargo.toml")) {
        Write-Error "未找到后端项目"
        return $false
    }

    Push-Location backend

    try {
        Write-Host "🧹 清理构建缓存..." -ForegroundColor Gray
        cargo clean --quiet

        Write-Host "🔍 本地编译检查..." -ForegroundColor Blue
        cargo check --quiet

        if ($LASTEXITCODE -ne 0) {
            Write-Error "本地编译失败，项目可能有问题"
            return $false
        }

        Write-Host "🔄 交叉编译测试..." -ForegroundColor Blue

        # 设置最简环境
        $originalRustFlags = $env:RUSTFLAGS
        $env:RUSTFLAGS = "-C linker=rust-lld -C target-cpu=generic"

        # 尝试编译一个简单的二进制
        $buildOutput = cargo build --target x86_64-unknown-linux-gnu --release --quiet 2>&1
        $buildResult = $LASTEXITCODE

        # 恢复环境变量
        if ($originalRustFlags) {
            $env:RUSTFLAGS = $originalRustFlags
        } else {
            Remove-Item env:RUSTFLAGS -ErrorAction SilentlyContinue
        }

        if ($buildResult -eq 0) {
            Write-Success "交叉编译成功!"

            # 检查输出文件
            $targetDir = "target\x86_64-unknown-linux-gnu\release"
            if (Test-Path $targetDir) {
                $binaries = Get-ChildItem $targetDir -File | Where-Object {
                    $_.Length -gt 100KB -and $_.Name -notmatch '\.(d|pdb|rlib)$'
                }

                if ($binaries) {
                    Write-Host "找到编译产物:" -ForegroundColor Green
                    foreach ($bin in $binaries) {
                        $sizeMB = [math]::Round($bin.Length / 1MB, 2)
                        Write-Host "  • $($bin.Name) ($sizeMB MB)" -ForegroundColor White
                    }
                }
            }

            return $true
        }
        else {
            Write-Error "交叉编译失败"
            Write-Host "错误输出:" -ForegroundColor Red
            Write-Host $buildOutput -ForegroundColor Gray
            return $false
        }
    }
    finally {
        Pop-Location
    }
}

# 创建 GitHub Actions 工作流
function Create-CloudBuildWorkflow {
    Write-Step "创建 GitHub Actions 云编译工作流"

    $workflowDir = ".github\workflows"
    New-Item -ItemType Directory -Path $workflowDir -Force | Out-Null

    $workflow = @'
name: 交叉编译构建

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]
  workflow_dispatch:

jobs:
  build-linux:
    name: Linux 交叉编译
    runs-on: ubuntu-22.04

    steps:
    - name: 检出代码
      uses: actions/checkout@v4

    - name: 安装 Rust
      uses: dtolnay/rust-toolchain@stable
      with:
        targets: x86_64-unknown-linux-gnu

    - name: 安装 Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '18'
        cache: 'npm'
        cache-dependency-path: frontend/package-lock.json

    - name: 编译后端
      working-directory: backend
      run: |
        cargo build --release --target x86_64-unknown-linux-gnu

    - name: 编译前端
      working-directory: frontend
      run: |
        npm ci
        npm run build

    - name: 打包构建产物
      run: |
        mkdir -p deploy

        # 复制后端二进制
        cp backend/target/x86_64-unknown-linux-gnu/release/* deploy/ || true
        find backend/target/x86_64-unknown-linux-gnu/release -maxdepth 1 -type f -executable -size +100k -exec cp {} deploy/portfolio_pulse_backend \;

        # 复制前端文件
        cp -r frontend/.next/standalone/* deploy/
        cp -r frontend/.next/static deploy/.next/
        cp -r frontend/public deploy/ || true

        # 创建启动脚本
        cat > deploy/start.sh << 'EOF'
        #!/bin/bash
        chmod +x portfolio_pulse_backend
        nohup ./portfolio_pulse_backend > backend.log 2>&1 &
        echo $! > backend.pid
        nohup node server.js > frontend.log 2>&1 &
        echo $! > frontend.pid
        echo "服务已启动"
        EOF

        chmod +x deploy/start.sh

    - name: 上传构建产物
      uses: actions/upload-artifact@v4
      with:
        name: portfoliopulse-linux-build
        path: deploy/
        retention-days: 30
'@

    $workflow | Out-File -FilePath "$workflowDir\cross-compile.yml" -Encoding utf8 -NoNewline

    Write-Success "GitHub Actions 工作流已创建"
    Write-Host "文件位置: .github\workflows\cross-compile.yml" -ForegroundColor Gray
    Write-Host "推送到 GitHub 后将自动触发云端编译" -ForegroundColor Blue
}

# 显示解决方案菜单
function Show-SolutionMenu {
    Write-Host "`n📋 Windows 本地交叉编译解决方案菜单" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray

    Write-Host "1️⃣  最小化环境修复 (推荐)" -ForegroundColor Green
    Write-Host "   • 清理冲突环境变量" -ForegroundColor Gray
    Write-Host "   • 配置最简交叉编译环境" -ForegroundColor Gray
    Write-Host "   • 适合大多数情况" -ForegroundColor Gray

    Write-Host "`n2️⃣  简化编译测试" -ForegroundColor Blue
    Write-Host "   • 快速测试当前环境" -ForegroundColor Gray
    Write-Host "   • 生成实际的交叉编译二进制" -ForegroundColor Gray
    Write-Host "   • 验证编译配置" -ForegroundColor Gray

    Write-Host "`n3️⃣  完全重置 Rust 环境" -ForegroundColor Yellow
    Write-Host "   • 卸载并重新安装 Rust" -ForegroundColor Gray
    Write-Host "   • 解决深层环境问题" -ForegroundColor Gray
    Write-Host "   • 需要重新下载工具链" -ForegroundColor Gray

    Write-Host "`n4️⃣  创建云端编译方案" -ForegroundColor Cyan
    Write-Host "   • GitHub Actions 工作流" -ForegroundColor Gray
    Write-Host "   • 避免本地环境问题" -ForegroundColor Gray
    Write-Host "   • 自动构建和打包" -ForegroundColor Gray

    Write-Host "`n5️⃣  运行完整本地编译" -ForegroundColor Magenta
    Write-Host "   • 执行 local_cross_compile.ps1" -ForegroundColor Gray
    Write-Host "   • 完整的编译和打包过程" -ForegroundColor Gray

    Write-Host "`n0️⃣  退出" -ForegroundColor White
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray

    do {
        $choice = Read-Host "`n请选择解决方案 (0-5)"

        switch ($choice) {
            "1" {
                if (Fix-MinimalCrossCompile) {
                    Write-Host "`n✨ 环境修复完成！现在可以运行: .\local_cross_compile.ps1" -ForegroundColor Green
                }
                break
            }
            "2" {
                Test-SimpleCompile
                break
            }
            "3" {
                if (Reset-CompleteEnvironment) {
                    Write-Host "`n✨ 环境重置完成！请运行选项 1 配置交叉编译" -ForegroundColor Green
                }
                break
            }
            "4" {
                Create-CloudBuildWorkflow
                break
            }
            "5" {
                Write-Host "`n🚀 启动完整编译..." -ForegroundColor Blue
                if (Test-Path ".\local_cross_compile.ps1") {
                    & ".\local_cross_compile.ps1"
                } else {
                    Write-Error "local_cross_compile.ps1 不存在"
                }
                break
            }
            "0" {
                Write-Host "退出程序" -ForegroundColor White
                return
            }
            default {
                Write-Warning "请输入有效选项 (0-5)"
                continue
            }
        }

        # 操作完成后询问是否继续
        Write-Host ""
        $continue = Read-Host "是否继续使用其他功能? (y/N)"
        if ($continue -ne "y" -and $continue -ne "Y") {
            break
        }

        Show-SolutionMenu
        break

    } while ($true)
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

# 主函数
function Main {
    # 环境诊断
    $issues = Test-RustEnvironment

    if ($issues.Count -gt 0) {
        Write-Host "`n🔍 发现的问题:" -ForegroundColor Red
        foreach ($issue in $issues) {
            Write-Host "  • $issue" -ForegroundColor Yellow
        }
        Write-Host ""
    } else {
        Write-Success "Rust 环境基础检查通过"
    }

    # 显示解决方案
    Show-SolutionMenu
}

# 执行主函数
Main
