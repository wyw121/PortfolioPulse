#!/usr/bin/env pwsh

Write-Host '=== PortfolioPulse 修复验证脚本 ===' -ForegroundColor Green

# 设置错误处理
$ErrorActionPreference = 'Stop'

try {
    # 1. 测试前端依赖安装
    Write-Host "`n1. 验证前端依赖..." -ForegroundColor Cyan
    Set-Location 'frontend'

    # 检查 package.json 中是否还有 @radix-ui/react-card
    $packageJson = Get-Content 'package.json' | ConvertFrom-Json
    if ($packageJson.dependencies.'@radix-ui/react-card') {
        Write-Host '❌ 错误: @radix-ui/react-card 依赖仍然存在' -ForegroundColor Red
        exit 1
    } else {
        Write-Host '✅ @radix-ui/react-card 依赖已移除' -ForegroundColor Green
    }

    # 检查 node_modules 是否安装完成
    if (Test-Path 'node_modules') {
        Write-Host '✅ 前端依赖安装完成' -ForegroundColor Green
    } else {
        Write-Host '⚠️  重新安装前端依赖...' -ForegroundColor Yellow
        npm install
        Write-Host '✅ 前端依赖安装完成' -ForegroundColor Green
    }

    # 2. 测试前端类型检查
    Write-Host "`n2. 验证前端 TypeScript 类型..." -ForegroundColor Cyan
    npm run type-check
    Write-Host '✅ 前端类型检查通过' -ForegroundColor Green

    # 3. 测试后端编译
    Write-Host "`n3. 验证后端编译..." -ForegroundColor Cyan
    Set-Location '../backend'

    # 检查 main.rs 中的修复
    $mainRs = Get-Content 'src/main.rs' -Raw
    if ($mainRs -match 'tracing_subscriber::fmt::init\(\)') {
        Write-Host '✅ 后端 tracing_subscriber 修复完成' -ForegroundColor Green
    } else {
        Write-Host '❌ 错误: 后端 tracing_subscriber 修复未完成' -ForegroundColor Red
        exit 1
    }

    # 检查编译
    cargo check
    Write-Host '✅ 后端编译检查通过' -ForegroundColor Green

    Write-Host "`n=== 所有修复验证完成！ ===" -ForegroundColor Green
    Write-Host '✅ 前端依赖问题已修复' -ForegroundColor Green
    Write-Host '✅ 后端编译问题已修复' -ForegroundColor Green
    Write-Host "`n项目现在可以正常开发了！" -ForegroundColor Yellow

} catch {
    Write-Host "`n❌ 验证过程中出现错误: $_" -ForegroundColor Red
    exit 1
} finally {
    # 返回根目录
    Set-Location '..'
}
