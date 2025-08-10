#!/usr/bin/env pwsh
# PortfolioPulse 数据库初始化脚本

param(
    [Parameter(Mandatory=$false)]
    [string]$RootPassword = "",
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipPasswordPrompt
)

Write-Host "🗄️ PortfolioPulse 数据库初始化" -ForegroundColor Green
Write-Host "==============================" -ForegroundColor Green

# 检查 MySQL 客户端是否可用
if (-not (Get-Command mysql -ErrorAction SilentlyContinue)) {
    Write-Host "❌ 未找到 MySQL 客户端" -ForegroundColor Red
    Write-Host "请确保 MySQL 已安装并添加到 PATH 环境变量" -ForegroundColor Yellow
    exit 1
}

# 检查数据库脚本文件是否存在
if (-not (Test-Path "init-dev-database.sql")) {
    Write-Host "❌ 未找到数据库初始化脚本文件: init-dev-database.sql" -ForegroundColor Red
    exit 1
}

Write-Host "📄 找到数据库初始化脚本文件" -ForegroundColor Green

# 方式一：如果提供了密码参数
if ($RootPassword) {
    Write-Host "🔐 使用提供的密码连接数据库..." -ForegroundColor Yellow
    try {
        Get-Content "init-dev-database.sql" | mysql -u root -p$RootPassword 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ 数据库初始化成功！" -ForegroundColor Green
        } else {
            Write-Host "❌ 数据库初始化失败" -ForegroundColor Red
            Write-Host "请检查密码是否正确" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "❌ 执行数据库脚本时出错: $_" -ForegroundColor Red
    }
}
# 方式二：交互式输入密码
elseif (-not $SkipPasswordPrompt) {
    Write-Host "🔐 请输入 MySQL root 密码..." -ForegroundColor Yellow
    Write-Host "💡 提示：如果没有设置密码，直接按回车" -ForegroundColor Blue
    
    try {
        Get-Content "init-dev-database.sql" | mysql -u root -p
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ 数据库初始化成功！" -ForegroundColor Green
        } else {
            Write-Host "❌ 数据库初始化失败" -ForegroundColor Red
        }
    } catch {
        Write-Host "❌ 执行数据库脚本时出错: $_" -ForegroundColor Red
    }
}
# 方式三：尝试无密码连接
else {
    Write-Host "🔐 尝试无密码连接..." -ForegroundColor Yellow
    try {
        Get-Content "init-dev-database.sql" | mysql -u root 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ 数据库初始化成功！" -ForegroundColor Green
        } else {
            Write-Host "❌ 无密码连接失败" -ForegroundColor Red
            Write-Host "请使用: .\init-database.ps1 (会提示输入密码)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "❌ 执行数据库脚本时出错: $_" -ForegroundColor Red
    }
}

# 验证初始化结果
if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "🎯 验证数据库初始化..." -ForegroundColor Yellow
    
    $testQuery = "USE portfolio_pulse_dev; SELECT COUNT(*) as project_count FROM projects;"
    
    try {
        if ($RootPassword) {
            $result = echo $testQuery | mysql -u root -p$RootPassword 2>$null
        } elseif ($SkipPasswordPrompt) {
            $result = echo $testQuery | mysql -u root 2>$null
        } else {
            Write-Host "请再次输入密码进行验证..."
            $result = echo $testQuery | mysql -u root -p
        }
        
        Write-Host "✅ 数据库验证成功" -ForegroundColor Green
        Write-Host ""
        Write-Host "📊 数据库连接信息：" -ForegroundColor Cyan
        Write-Host "   数据库: portfolio_pulse_dev" -ForegroundColor White
        Write-Host "   用户名: portfoliopulse" -ForegroundColor White
        Write-Host "   密码: testpass123" -ForegroundColor White
        Write-Host "   主机: localhost:3306" -ForegroundColor White
        
    } catch {
        Write-Host "⚠️ 数据库验证失败，但初始化可能已成功" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "🚀 下一步：启动测试服务" -ForegroundColor Green
Write-Host "   .\start-test.ps1" -ForegroundColor Cyan
