# PortfolioPulse 本地交叉编译修复脚本
# 专门解决 "can't find crate for core" 错误

Write-Host "🔧 修复 Rust 交叉编译环境" -ForegroundColor Cyan
Write-Host "🎯 解决 'can't find crate for core' 错误" -ForegroundColor Yellow
Write-Host ""

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

# 第一步：完全重置交叉编译环境
Write-Host "🧹 第一步：重置交叉编译环境" -ForegroundColor Blue

# 移除所有 Linux 目标
$linuxTargets = @("x86_64-unknown-linux-gnu", "x86_64-unknown-linux-musl")
foreach ($target in $linuxTargets) {
    Write-Host "移除目标: $target" -ForegroundColor Gray
    rustup target remove $target 2>$null
}

# 清理所有相关环境变量
$envVarsToClean = @(
    "RUSTFLAGS",
    "CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER",
    "CC_x86_64_unknown_linux_gnu",
    "CXX_x86_64_unknown_linux_gnu",
    "CC",
    "CXX"
)

foreach ($var in $envVarsToClean) {
    if (Test-Path "env:$var") {
        Remove-Item "env:$var" -ErrorAction SilentlyContinue
        Write-Host "清除环境变量: $var" -ForegroundColor Yellow
    }
}

Write-Host "✅ 环境清理完成" -ForegroundColor Green

# 第二步：重新安装工具链组件
Write-Host "`n🔄 第二步：重新安装工具链组件" -ForegroundColor Blue

Write-Host "更新 Rust 工具链..." -ForegroundColor Gray
rustup update stable

Write-Host "重新安装标准库组件..." -ForegroundColor Gray
rustup component add rust-std-x86_64-unknown-linux-gnu --toolchain stable --force

Write-Host "添加交叉编译目标..." -ForegroundColor Gray
rustup target add x86_64-unknown-linux-gnu

Write-Host "✅ 组件安装完成" -ForegroundColor Green

# 第三步：验证安装
Write-Host "`n🔍 第三步：验证安装" -ForegroundColor Blue

$rustcOutput = rustc --version
Write-Host "Rust 版本: $rustcOutput" -ForegroundColor White

$targets = rustup target list --installed | Where-Object { $_ -match "linux" }
Write-Host "已安装的 Linux 目标:" -ForegroundColor White
foreach ($target in $targets) {
    Write-Host "  ✓ $target" -ForegroundColor Green
}

# 检查标准库
$rustSysroot = rustc --print sysroot
$stdlibPath = "$rustSysroot\lib\rustlib\x86_64-unknown-linux-gnu\lib"
if (Test-Path $stdlibPath) {
    $stdlibFiles = Get-ChildItem $stdlibPath -Filter "*.rlib" | Measure-Object
    Write-Host "Linux 标准库文件: $($stdlibFiles.Count) 个" -ForegroundColor Green
} else {
    Write-Host "⚠️ Linux 标准库路径不存在: $stdlibPath" -ForegroundColor Red
}

Write-Host "✅ 环境验证完成" -ForegroundColor Green

# 第四步：设置最小化编译环境
Write-Host "`n⚙️ 第四步：配置编译环境" -ForegroundColor Blue

# 使用最简单的配置，避免链接器冲突
$env:RUSTFLAGS = "-C target-feature=-crt-static"

Write-Host "环境变量设置:" -ForegroundColor White
Write-Host "  RUSTFLAGS = $env:RUSTFLAGS" -ForegroundColor Gray

Write-Host "✅ 编译环境配置完成" -ForegroundColor Green

# 第五步：测试编译
Write-Host "`n🧪 第五步：测试交叉编译" -ForegroundColor Blue

if (-not (Test-Path "backend\Cargo.toml")) {
    Write-Host "❌ 请在 PortfolioPulse 项目根目录运行此脚本" -ForegroundColor Red
    exit 1
}

Push-Location backend

try {
    Write-Host "清理构建缓存..." -ForegroundColor Gray
    cargo clean

    Write-Host "执行交叉编译测试..." -ForegroundColor Gray
    Write-Host "命令: cargo build --target x86_64-unknown-linux-gnu --release" -ForegroundColor Gray
    
    # 使用 PowerShell 的作业机制来捕获输出
    $job = Start-Job -ScriptBlock {
        Set-Location $args[0]
        $env:RUSTFLAGS = $args[1]
        cargo build --target x86_64-unknown-linux-gnu --release 2>&1
    } -ArgumentList (Get-Location), $env:RUSTFLAGS
    
    # 等待作业完成（最多 10 分钟）
    $timeout = 600
    $elapsed = 0
    
    while ($job.State -eq "Running" -and $elapsed -lt $timeout) {
        Write-Host "." -NoNewline -ForegroundColor Blue
        Start-Sleep 5
        $elapsed += 5
    }
    
    Write-Host ""
    
    $result = Receive-Job $job
    Remove-Job $job
    
    if ($result -match "error.*can't find crate for.*core") {
        Write-Host "❌ 仍然存在 'core' crate 错误" -ForegroundColor Red
        Write-Host "错误详情:" -ForegroundColor Red
        $result | Where-Object { $_ -match "error|can't find" } | ForEach-Object {
            Write-Host "  $_" -ForegroundColor Yellow
        }
        
        Write-Host "`n💡 建议的替代方案:" -ForegroundColor Cyan
        Write-Host "1. 使用 GitHub Actions 云编译 (已创建工作流)" -ForegroundColor White
        Write-Host "2. 在 Linux 虚拟机中编译" -ForegroundColor White
        Write-Host "3. 使用 Windows Subsystem for Linux (WSL)" -ForegroundColor White
        
    } elseif ($result -match "error") {
        Write-Host "❌ 编译失败，但不是 core crate 问题" -ForegroundColor Red
        Write-Host "错误详情:" -ForegroundColor Red
        $result | Where-Object { $_ -match "error" } | Select-Object -First 10 | ForEach-Object {
            Write-Host "  $_" -ForegroundColor Yellow
        }
        
    } else {
        Write-Host "✅ 交叉编译测试成功！" -ForegroundColor Green
        
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
                    Write-Host "  📦 $($bin.Name) ($sizeMB MB)" -ForegroundColor White
                }
                
                Write-Host "`n🎉 现在可以运行完整编译:" -ForegroundColor Cyan
                Write-Host ".\complete_cross_compile.ps1" -ForegroundColor White
            }
        }
    }
    
} catch {
    Write-Host "❌ 编译过程异常: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    Pop-Location
}

Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host "🎯 修复脚本执行完成" -ForegroundColor Cyan

if ((Get-ChildItem ".github\workflows" -Filter "*ubuntu*" -ErrorAction SilentlyContinue)) {
    Write-Host "`n☁️ 云编译方案已准备就绪:" -ForegroundColor Blue
    Write-Host "1. 提交并推送代码到 GitHub" -ForegroundColor White
    Write-Host "2. 在 Actions 页面查看自动编译结果" -ForegroundColor White
    Write-Host "3. 下载编译好的 Ubuntu 22.04 部署包" -ForegroundColor White
}

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
