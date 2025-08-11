# PowerShell 安全配置文件 - VS Code 兼容版本
# 问题修复: PowerShell 终端崩溃 (栈溢出 -1073741571)
# 修复时间: 2025-08-11

# 检测运行环境
$isVSCode = $env:TERM_PROGRAM -eq "vscode" -or $env:VSCODE_PID
$isWindowsTerminal = $env:WT_SESSION

Write-Host "PowerShell 环境检测:" -ForegroundColor Cyan
Write-Host "  - VS Code: $isVSCode" -ForegroundColor Gray
Write-Host "  - Windows Terminal: $($null -ne $isWindowsTerminal)" -ForegroundColor Gray
Write-Host "  - PowerShell 版本: $($PSVersionTable.PSVersion)" -ForegroundColor Gray

# 只在安全环境中应用编码设置
if (-not $isVSCode) {
    try {
        # 安全的编码设置 (避免全局覆盖)
        [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
        $global:OutputEncoding = [System.Text.Encoding]::UTF8

        # 避免通配符参数设置 (这是崩溃的主要原因)
        # $PSDefaultParameterValues['*:Encoding'] = 'utf8'  # 危险！不要使用
        $PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
        $PSDefaultParameterValues['Set-Content:Encoding'] = 'utf8'
        $PSDefaultParameterValues['Add-Content:Encoding'] = 'utf8'

        # 环境变量设置
        $env:PYTHONIOENCODING = 'utf-8'

        # Windows PowerShell 5.x 特殊处理 (避免 chcp 冲突)
        if ($PSVersionTable.PSVersion.Major -eq 5) {
            # 不使用 chcp 命令，避免与 VS Code 冲突
            Write-Host "Windows PowerShell 5.x 检测到，跳过 chcp 设置" -ForegroundColor Yellow
        }

        Write-Host "PowerShell UTF-8 编码配置成功 (非 VS Code 环境)" -ForegroundColor Green
    }
    catch {
        Write-Warning "编码设置失败: $($_.Message)"
    }
}
else {
    Write-Host "VS Code 环境检测到，使用默认配置避免冲突" -ForegroundColor Yellow

    # VS Code 环境中的最小化设置
    $env:PYTHONIOENCODING = 'utf-8'
}

# 添加项目特定的别名和函数
if (Test-Path "D:\repositories\PortfolioPulse") {
    Set-Location "D:\repositories\PortfolioPulse"

    # 项目快捷命令
    function Start-Frontend {
        Set-Location "D:\repositories\PortfolioPulse\frontend"
        npm run dev
    }
    function Start-Backend {
        Set-Location "D:\repositories\PortfolioPulse\backend"
        cargo run
    }
    function Build-Project {
        Write-Host "构建前端..." -ForegroundColor Cyan
        Set-Location "D:\repositories\PortfolioPulse\frontend"
        npm run build

        Write-Host "构建后端..." -ForegroundColor Cyan
        Set-Location "D:\repositories\PortfolioPulse\backend"
        cargo build --release

        Set-Location "D:\repositories\PortfolioPulse"
    }

    # 创建别名
    Set-Alias -Name "pp-frontend" -Value Start-Frontend
    Set-Alias -Name "pp-backend" -Value Start-Backend
    Set-Alias -Name "pp-build" -Value Build-Project

    Write-Host "PortfolioPulse 项目环境已加载" -ForegroundColor Green
    Write-Host "可用命令: pp-frontend, pp-backend, pp-build" -ForegroundColor Gray
}

Write-Host "PowerShell 配置加载完成 ✅" -ForegroundColor Green
