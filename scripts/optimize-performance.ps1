#!/usr/bin/env pwsh

Write-Host "PortfolioPulse Performance Optimization Script" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green

# Check current directory
$currentDir = Get-Location
Write-Host "Current directory: $currentDir" -ForegroundColor Yellow

# 1. Clean build cache
Write-Host "Cleaning build cache..." -ForegroundColor Cyan
if (Test-Path "backend/target") {
    Remove-Item -Recurse -Force "backend/target" -ErrorAction SilentlyContinue
    Write-Host "Cleaned Rust target directory" -ForegroundColor Green
}

if (Test-Path "frontend/.next") {
    Remove-Item -Recurse -Force "frontend/.next" -ErrorAction SilentlyContinue
    Write-Host "Cleaned Next.js .next directory" -ForegroundColor Green
}

# 2. Check and install dependencies
Write-Host "Checking dependencies..." -ForegroundColor Cyan

# Frontend dependencies
Set-Location "frontend"
if (-not (Test-Path "node_modules")) {
    Write-Host "Installing frontend dependencies..." -ForegroundColor Yellow
    npm install --silent
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Frontend dependencies installed successfully" -ForegroundColor Green
    } else {
        Write-Host "Frontend dependencies installation failed" -ForegroundColor Red
    }
} else {
    Write-Host "Frontend dependencies already exist" -ForegroundColor Green
}

Set-Location ".."

# 3. Check Rust toolchain
Write-Host "Checking Rust toolchain..." -ForegroundColor Cyan
$rustVersion = cargo --version 2>$null
if ($rustVersion) {
    Write-Host "Rust: $rustVersion" -ForegroundColor Green
} else {
    Write-Host "Rust not installed or not in PATH" -ForegroundColor Red
}

# 4. Performance recommendations
Write-Host ""
Write-Host "Performance optimization recommendations:" -ForegroundColor Magenta
Write-Host "- Disabled rust-analyzer build scripts and macro processing" -ForegroundColor White
Write-Host "- Configured file watching to exclude target/ and node_modules/" -ForegroundColor White
Write-Host "- Recommend restarting VS Code to apply new configurations" -ForegroundColor White
Write-Host "- If still laggy, consider disabling unnecessary VS Code extensions" -ForegroundColor White

Write-Host ""
Write-Host "Startup suggestions:" -ForegroundColor Magenta
Write-Host "Frontend: cd frontend; npm run dev" -ForegroundColor White
Write-Host "Backend: cd backend; cargo run" -ForegroundColor White

Write-Host ""
Write-Host "Optimization completed!" -ForegroundColor Green
