@echo off
echo ☁️ 启动 PortfolioPulse GitHub Actions 云编译
echo.

echo 📦 添加文件...
git add .

echo 💾 提交更改...
git commit -m "feat: 添加 Ubuntu 22.04 交叉编译工作流 - 解决 Windows 本地编译问题，使用 GitHub Actions 云端编译，生成完整 Ubuntu 部署包"

echo 🚀 推送到 GitHub...
git push origin main

if %ERRORLEVEL% equ 0 (
    echo.
    echo 🎉 推送成功！
    echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    echo 📊 查看编译状态:
    echo 🔗 https://github.com/wyw121/PortfolioPulse/actions
    echo.
    echo ⏱️  预计编译时间: 5-10 分钟
    echo 📥 编译完成后在 Actions 页面下载部署包
    echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
) else (
    echo ❌ 推送失败，请检查网络和权限
)

pause
