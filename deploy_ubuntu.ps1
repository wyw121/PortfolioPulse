#!/usr/bin/env pwsh

# PortfolioPulse Ubuntu 22.04 部署方案选择器
# 智能推荐最适合的编译和部署方案

$ErrorActionPreference = "Stop"

function Write-Title {
    param([string]$Message)
    Write-Host "`n$Message" -ForegroundColor Cyan
    Write-Host ("=" * $Message.Length) -ForegroundColor Gray
}

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

function Test-Environment {
    Write-Title "🔍 环境检查"
    
    $env_status = @{
        Docker = Test-Command "docker"
        Rust = Test-Command "rustc"
        Node = Test-Command "node"
        Git = Test-Command "git"
    }
    
    foreach ($tool in $env_status.Keys) {
        if ($env_status[$tool]) {
            Write-Success "$tool 已安装"
            
            # 显示版本信息
            switch ($tool) {
                "Docker" { 
                    $version = docker --version
                    Write-Host "  版本: $version" -ForegroundColor Gray
                }
                "Rust" { 
                    $version = rustc --version
                    Write-Host "  版本: $version" -ForegroundColor Gray
                }
                "Node" { 
                    $version = node --version
                    Write-Host "  版本: $version" -ForegroundColor Gray
                }
                "Git" { 
                    $version = git --version
                    Write-Host "  版本: $version" -ForegroundColor Gray
                }
            }
        }
        else {
            Write-Warning "$tool 未安装"
        }
    }
    
    return $env_status
}

function Show-RecommendedSolution {
    param($Environment)
    
    Write-Title "💡 推荐方案"
    
    if ($Environment.Docker) {
        Write-Host "🥇 推荐: Docker 编译方案" -ForegroundColor Green
        Write-Host @"
优点:
✅ 无需复杂的交叉编译环境
✅ 完全隔离的 Ubuntu 22.04 环境  
✅ 保证 100% 兼容性
✅ 一键生成部署包

使用方法:
  .\windows_cross_compile.ps1 -UseDocker
"@ -ForegroundColor White
        return "docker"
    }
    elseif ($Environment.Rust -and $Environment.Node) {
        Write-Host "🥈 推荐: 尝试交叉编译 (可能需要修复)" -ForegroundColor Yellow
        Write-Host @"
优点:
✅ 使用现有开发环境
✅ 编译速度快

注意:
⚠️  Windows 交叉编译可能有环境问题
⚠️  如果失败，建议使用 Docker 方案

使用方法:
  .\fix_cross_compile.ps1  # 先修复环境
  .\windows_cross_compile.ps1 -UseMusl  # 然后编译
"@ -ForegroundColor White
        return "fix"
    }
    elseif ($Environment.Git) {
        Write-Host "🥉 推荐: GitHub Actions 云编译" -ForegroundColor Blue
        Write-Host @"
优点:
✅ 完全免费
✅ 自动化构建
✅ 无需本地环境

使用方法:
  .\windows_cross_compile.ps1 (选择云编译)
"@ -ForegroundColor White
        return "cloud"
    }
    else {
        Write-Host "🔧 推荐: 先安装开发环境" -ForegroundColor Red
        Write-Host @"
建议执行:
  .\install_dev_environment.ps1 -AutoInstall
  
然后选择适合的编译方案
"@ -ForegroundColor White
        return "install"
    }
}

function Show-AllSolutions {
    Write-Title "📋 所有可用方案"
    
    Write-Host @"
方案1: Musl 静态编译 🦀
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
适用: 已安装 Rust + Node.js
命令: .\simple_cross_compile.ps1 -UseMusl  
优点: 静态链接、无依赖、速度快
时间: ~3-5分钟

方案2: 完整交叉编译 🔧
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
适用: 完整开发环境 + 交叉编译工具链
命令: .\build_ubuntu_cross_compile.ps1
优点: 本地编译、完全控制、功能最全
时间: ~5-8分钟

方案3: Docker 编译 �
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
适用: 已安装 Docker Desktop
命令: .\simple_cross_compile.ps1 -UseDocker
优点: 环境隔离、兼容性好、一键编译
时间: ~10-15分钟

方案4: GitHub Actions 云编译 ☁️
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
适用: 有 GitHub 仓库
命令: .\simple_cross_compile.ps1 (选择3)
优点: 完全免费、自动化、无环境要求
时间: ~5-8分钟

方案5: 环境自动安装 ⚙️
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
适用: 全新系统需要安装开发环境
命令: .\install_dev_environment.ps1 -AutoInstall
优点: 一键安装所有依赖
时间: ~15-30分钟
"@ -ForegroundColor White
}

function Execute-RecommendedSolution {
    param([string]$Solution)
    
    Write-Title "🚀 执行推荐方案"
    
    switch ($Solution) {
        "docker" {
            Write-Host "正在使用 Docker 编译方案..." -ForegroundColor Blue
            & ".\simple_cross_compile.ps1" -UseDocker
        }
        "musl" {
            Write-Host "正在使用 Musl 静态编译方案..." -ForegroundColor Blue  
            & ".\simple_cross_compile.ps1" -UseMusl
        }
        "cloud" {
            Write-Host "正在配置云编译方案..." -ForegroundColor Blue
            & ".\simple_cross_compile.ps1"
        }
        "install" {
            Write-Host "正在安装开发环境..." -ForegroundColor Blue
            & ".\install_dev_environment.ps1" -AutoInstall
        }
        default {
            Write-Warning "未知方案: $Solution"
        }
    }
}

function Show-ManualMenu {
    Write-Title "🎯 请选择编译方案"
    
    Write-Host @"
1. Musl 静态编译 (推荐开发者)
2. 完整交叉编译 (推荐高级用户)  
3. Docker 编译 (推荐新手)
4. GitHub Actions 云编译 (推荐团队)
5. 安装开发环境 (推荐首次使用)
6. 查看所有方案详情
7. 退出

选择 (1-7):
"@ -ForegroundColor Cyan
    
    $choice = Read-Host
    
    switch ($choice) {
        "1" { 
            & ".\simple_cross_compile.ps1" -UseMusl 
        }
        "2" { 
            & ".\build_ubuntu_cross_compile.ps1" 
        }
        "3" { 
            & ".\simple_cross_compile.ps1" -UseDocker 
        }
        "4" { 
            & ".\simple_cross_compile.ps1" 
        }
        "5" { 
            & ".\install_dev_environment.ps1" -AutoInstall 
        }
        "6" { 
            Show-AllSolutions
            Show-ManualMenu
        }
        "7" { 
            Write-Host "再见! 👋" -ForegroundColor Green
            return
        }
        default {
            Write-Warning "无效选择，请重新选择"
            Show-ManualMenu
        }
    }
}

function Main {
    param(
        [switch]$Auto,
        [switch]$Menu,
        [string]$Force
    )
    
    Write-Host @"
🎯 PortfolioPulse Ubuntu 22.04 部署方案选择器
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🐧 目标系统: Ubuntu 22.04 LTS (x86_64)
📦 生成文件: 完整部署包含启动脚本
⚡ 智能推荐: 根据当前环境自动选择最佳方案
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
"@ -ForegroundColor Cyan
    
    # 检查项目结构
    if (-not (Test-Path "backend\Cargo.toml") -or -not (Test-Path "frontend\package.json")) {
        Write-Error "请在 PortfolioPulse 项目根目录运行此脚本"
        Write-Host "当前目录: $(Get-Location)" -ForegroundColor Yellow
        Write-Host "需要存在: backend/Cargo.toml 和 frontend/package.json" -ForegroundColor Yellow
        return
    }
    
    # 强制使用指定方案
    if ($Force) {
        switch ($Force.ToLower()) {
            "docker" { & ".\simple_cross_compile.ps1" -UseDocker }
            "musl" { & ".\simple_cross_compile.ps1" -UseMusl }
            "cloud" { & ".\simple_cross_compile.ps1" }
            "install" { & ".\install_dev_environment.ps1" -AutoInstall }
            "full" { & ".\build_ubuntu_cross_compile.ps1" }
            default { Write-Error "未知的强制方案: $Force" }
        }
        return
    }
    
    # 环境检查
    $environment = Test-Environment
    
    if ($Menu) {
        Show-AllSolutions
        Show-ManualMenu
        return
    }
    
    # 自动推荐
    if ($Auto) {
        $recommended = Show-RecommendedSolution $environment
        
        Write-Host "`n是否执行推荐方案? (Y/n): " -NoNewline -ForegroundColor Yellow
        $confirm = Read-Host
        
        if ($confirm -eq "" -or $confirm -eq "y" -or $confirm -eq "Y") {
            Execute-RecommendedSolution $recommended
        }
        else {
            Show-ManualMenu
        }
    }
    else {
        # 默认行为：显示推荐并提供选择
        $recommended = Show-RecommendedSolution $environment
        
        Write-Host @"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

选择操作:
A. 自动执行推荐方案
M. 显示所有方案菜单  
Q. 退出

选择 (A/M/Q):
"@ -ForegroundColor Cyan
        
        $choice = Read-Host
        
        switch ($choice.ToUpper()) {
            "A" { Execute-RecommendedSolution $recommended }
            "M" { Show-ManualMenu }
            "Q" { Write-Host "再见! 👋" -ForegroundColor Green }
            "" { Execute-RecommendedSolution $recommended }
            default { Execute-RecommendedSolution $recommended }
        }
    }
}

# 帮助信息
if ($args -contains "-h" -or $args -contains "--help") {
    Write-Host @"
🎯 PortfolioPulse Ubuntu 22.04 部署方案选择器

用法:
  .\deploy_ubuntu.ps1 [选项]

选项:
  -Auto              自动推荐并确认执行方案
  -Menu              显示所有方案的详细菜单
  -Force <方案>      强制使用指定方案
  -h, --help         显示此帮助信息

强制方案选项:
  docker            Docker 编译
  musl              Musl 静态编译  
  cloud             GitHub Actions 云编译
  install           安装开发环境
  full              完整交叉编译

示例:
  .\deploy_ubuntu.ps1              # 交互式智能推荐
  .\deploy_ubuntu.ps1 -Auto        # 自动执行推荐方案
  .\deploy_ubuntu.ps1 -Menu        # 显示详细菜单
  .\deploy_ubuntu.ps1 -Force docker # 强制使用 Docker 编译

工作流程:
1. 检查项目结构和开发环境
2. 智能分析并推荐最适合的方案
3. 执行选择的方案生成部署包
4. 提供详细的部署说明和脚本
"@
    exit 0
}

# 执行主函数
Main @args
