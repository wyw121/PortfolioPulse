@echo off
chcp 65001 >nul
title PortfolioPulse 开发服务器启动器

echo.
echo === PortfolioPulse 开发服务器启动器 ===
echo.

:menu
echo 请选择要启动的服务:
echo 1. 前端开发服务器 (Next.js)
echo 2. 后端开发服务器 (Rust)  
echo 3. 同时启动前后端
echo 4. 退出
echo.
set /p choice="请输入选项 (1-4): "

if "%choice%"=="1" goto start_frontend
if "%choice%"=="2" goto start_backend
if "%choice%"=="3" goto start_both
if "%choice%"=="4" goto exit
echo 无效选项，请重新选择
goto menu

:start_frontend
echo.
echo 启动前端开发服务器...
if not exist "frontend\node_modules" (
    echo 首次运行，安装依赖...
    cd frontend
    call npm install
    cd ..
)
start "PortfolioPulse Frontend" cmd /k "cd frontend && npm run dev"
echo 前端服务已启动！访问 http://localhost:3000
pause
goto menu

:start_backend
echo.
echo 启动后端开发服务器...
start "PortfolioPulse Backend" cmd /k "cd backend && cargo run --release"
echo 后端服务已启动！API 地址 http://localhost:8000
pause
goto menu

:start_both
echo.
echo 同时启动前后端服务...
if not exist "frontend\node_modules" (
    echo 安装前端依赖...
    cd frontend
    call npm install
    cd ..
)
start "PortfolioPulse Frontend" cmd /k "cd frontend && npm run dev"
timeout /t 3 /nobreak >nul
start "PortfolioPulse Backend" cmd /k "cd backend && cargo run --release"
echo.
echo 服务启动完成！
echo 前端: http://localhost:3000
echo 后端: http://localhost:8000
pause
goto menu

:exit
echo 再见！
exit /b 0
