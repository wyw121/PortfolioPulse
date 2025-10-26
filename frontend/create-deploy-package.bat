@echo off
REM Next.js Standalone 部署包生成脚本 (Windows批处理版本)

echo ========================================
echo Next.js Standalone 部署包生成工具
echo ========================================
echo.

REM 检查构建产物
if not exist ".next\standalone" (
    echo 错误: 未找到 .next\standalone 目录
    echo 请先运行: npm run build
    exit /b 1
)

REM 创建临时目录
set TEMP_DIR=deploy-temp
if exist %TEMP_DIR% rd /s /q %TEMP_DIR%
mkdir %TEMP_DIR%

echo 📦 正在准备部署文件...

REM 1. 复制 standalone 目录
echo   ├─ 复制 standalone 核心文件...
xcopy /E /I /Y ".next\standalone\*" "%TEMP_DIR%\" > nul

REM 2. 复制静态文件
echo   ├─ 复制静态资源文件...
if not exist "%TEMP_DIR%\.next\static" mkdir "%TEMP_DIR%\.next\static"
xcopy /E /I /Y ".next\static\*" "%TEMP_DIR%\.next\static\" > nul

REM 3. 复制 public 文件
if exist "public" (
    echo   ├─ 复制 public 目录...
    if not exist "%TEMP_DIR%\public" mkdir "%TEMP_DIR%\public"
    xcopy /E /I /Y "public\*" "%TEMP_DIR%\public\" > nul
)

REM 4. 复制部署脚本
echo   ├─ 复制部署脚本...
copy /Y "deploy-temp\start.sh" "%TEMP_DIR%\" > nul
copy /Y "deploy-temp\stop.sh" "%TEMP_DIR%\" > nul
copy /Y "deploy-temp\portfoliopulse-frontend.service" "%TEMP_DIR%\" > nul
copy /Y "deploy-temp\README.md" "%TEMP_DIR%\" > nul

REM 5. 打包
echo   └─ 正在打包...
set ZIP_FILE=portfoliopulse-frontend.zip
if exist %ZIP_FILE% del %ZIP_FILE%

REM 使用 PowerShell 压缩
powershell -Command "Compress-Archive -Path '%TEMP_DIR%\*' -DestinationPath '%ZIP_FILE%' -CompressionLevel Optimal"

echo.
echo ========================================
echo ✅ 部署包生成成功！
echo ========================================
echo.
echo 📦 文件位置: %CD%\%ZIP_FILE%
echo.
echo 📋 下一步操作:
echo   1. 将 %ZIP_FILE% 上传到服务器 ~/opt/ 目录
echo   2. 在服务器执行:
echo      cd ~/opt
echo      unzip portfoliopulse-frontend.zip
echo      cd portfoliopulse-frontend
echo      chmod +x start.sh stop.sh
echo      ./start.sh
echo.
echo 📖 详细部署说明请查看压缩包内的 README.md
echo.

pause
