@echo off
echo 🦀 PortfolioPulse 本地交叉编译
echo 🚫 不使用 Docker 的解决方案
echo.

echo 🔍 检查环境...
where rustc >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ❌ Rust 未安装
    pause
    exit /b 1
)

where node >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ❌ Node.js 未安装
    pause
    exit /b 1
)

echo ✅ 环境检查通过

echo.
echo 🧹 清理环境...
set RUSTFLAGS=-C linker=rust-lld
set CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER=

echo.
echo 📦 安装 Linux 目标...
rustup target add x86_64-unknown-linux-gnu

echo.
echo 🦀 编译后端...
cd backend
cargo clean
echo 执行: cargo build --release --target x86_64-unknown-linux-gnu
cargo build --release --target x86_64-unknown-linux-gnu

if %ERRORLEVEL% neq 0 (
    echo ❌ 后端编译失败
    cd ..
    pause
    exit /b 1
)

echo ✅ 后端编译成功

echo.
echo 📁 查找编译产物...
if not exist "target\x86_64-unknown-linux-gnu\release\" (
    echo ❌ 编译输出目录不存在
    cd ..
    pause
    exit /b 1
)

cd target\x86_64-unknown-linux-gnu\release
dir /b *.exe 2>nul | findstr /v "\.d$" | findstr /v "\.pdb$" > temp_files.txt
for /f %%i in (temp_files.txt) do (
    echo 找到可执行文件: %%i
    copy "%%i" "..\..\..\build\portfolio_pulse_backend" >nul
)
del temp_files.txt
cd ..\..\..\..

echo.
echo 🟢 编译前端...
cd frontend
call npm ci
if %ERRORLEVEL% neq 0 (
    echo ❌ 前端依赖安装失败
    cd ..
    pause
    exit /b 1
)

call npm run build
if %ERRORLEVEL% neq 0 (
    echo ❌ 前端编译失败
    cd ..
    pause
    exit /b 1
)

echo ✅ 前端编译成功

echo.
echo 📦 创建部署包...
if not exist "..\build" mkdir "..\build"
if exist ".next\standalone" (
    xcopy /s /e /y ".next\standalone\*" "..\build\" >nul
    echo 前端文件已复制
) else (
    echo ⚠️ 未找到 standalone 输出
)

cd ..

echo.
echo 📝 创建启动脚本...
(
echo #!/bin/bash
echo echo "🚀 启动 PortfolioPulse..."
echo chmod +x portfolio_pulse_backend
echo nohup ./portfolio_pulse_backend ^> backend.log 2^>^&1 ^&
echo echo $! ^> backend.pid
echo nohup node server.js ^> frontend.log 2^>^&1 ^&
echo echo $! ^> frontend.pid
echo echo "✅ 服务已启动"
echo echo "🌐 访问: http://localhost:3000"
) > build\start.sh

echo.
echo 🎉 编译完成!
echo 📁 输出目录: build\
echo 📦 后端文件: portfolio_pulse_backend
echo 🚀 启动脚本: start.sh
echo.
echo 部署到 Ubuntu:
echo 1. 上传 build\ 目录到服务器
echo 2. chmod +x portfolio_pulse_backend start.sh
echo 3. ./start.sh
echo.
pause
