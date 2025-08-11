# PortfolioPulse GitHub Actions 云编译启动脚本

Write-Host "☁️ PortfolioPulse GitHub Actions 云编译" -ForegroundColor Cyan
Write-Host "🚫 无需本地交叉编译环境" -ForegroundColor Green
Write-Host ""

# 检查 Git 状态
Write-Host "🔍 检查 Git 仓库状态..." -ForegroundColor Blue

if (-not (Test-Path ".git")) {
    Write-Host "❌ 当前目录不是 Git 仓库" -ForegroundColor Red
    Write-Host "请确保在 PortfolioPulse 项目根目录运行此脚本" -ForegroundColor Yellow
    exit 1
}

try {
    $gitStatus = git status --porcelain
    $hasChanges = $gitStatus.Count -gt 0

    if ($hasChanges) {
        Write-Host "📝 发现未提交的更改:" -ForegroundColor Yellow
        git status --short
    } else {
        Write-Host "✅ 工作目录干净" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Git 命令执行失败" -ForegroundColor Red
    exit 1
}

# 检查 GitHub 工作流文件
$workflowFile = ".github\workflows\ubuntu-cross-compile.yml"
if (-not (Test-Path $workflowFile)) {
    Write-Host "❌ GitHub Actions 工作流文件不存在" -ForegroundColor Red
    Write-Host "预期位置: $workflowFile" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ GitHub Actions 工作流文件存在" -ForegroundColor Green

# 显示工作流信息
Write-Host "`n📋 工作流功能:" -ForegroundColor Blue
Write-Host "  🦀 自动编译 Rust 后端到 Ubuntu 22.04" -ForegroundColor White
Write-Host "  🟢 自动构建 Next.js 前端" -ForegroundColor White
Write-Host "  📦 生成完整部署包" -ForegroundColor White
Write-Host "  🚀 包含启动/停止脚本" -ForegroundColor White

# 询问是否继续
Write-Host "`n❓ 是否要提交更改并推送到 GitHub 触发云编译?" -ForegroundColor Cyan
$choice = Read-Host "输入 Y 继续，N 取消 (Y/N)"

if ($choice -ne "Y" -and $choice -ne "y") {
    Write-Host "操作已取消" -ForegroundColor Yellow
    exit 0
}

# 添加所有更改
Write-Host "`n📦 添加文件到 Git..." -ForegroundColor Blue
git add .

# 提交更改
$commitMessage = "feat: 添加 Ubuntu 22.04 交叉编译 GitHub Actions 工作流

- 自动交叉编译 Rust 后端
- 自动构建 Next.js 前端
- 生成完整 Ubuntu 部署包
- 包含启动/停止/状态脚本
- 支持一键部署到服务器"

Write-Host "💾 提交更改..." -ForegroundColor Blue
git commit -m $commitMessage

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Git 提交失败" -ForegroundColor Red
    exit 1
}

# 推送到 GitHub
Write-Host "🚀 推送到 GitHub..." -ForegroundColor Blue
git push origin main

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Git 推送失败" -ForegroundColor Red
    Write-Host "请检查:" -ForegroundColor Yellow
    Write-Host "  - GitHub 远程仓库配置" -ForegroundColor Gray
    Write-Host "  - 网络连接" -ForegroundColor Gray
    Write-Host "  - 权限设置" -ForegroundColor Gray
    exit 1
}

Write-Host "`n🎉 推送成功！" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray

# 获取仓库信息
try {
    $remoteUrl = git config --get remote.origin.url
    if ($remoteUrl -match "github\.com[:/]([^/]+)/([^/.]+)") {
        $owner = $Matches[1]
        $repo = $Matches[2] -replace "\.git$", ""
        $actionsUrl = "https://github.com/$owner/$repo/actions"

        Write-Host "📊 查看编译状态:" -ForegroundColor Cyan
        Write-Host "🔗 $actionsUrl" -ForegroundColor Blue
    }
} catch {
    Write-Host "📊 请在 GitHub 仓库的 Actions 页面查看编译状态" -ForegroundColor Cyan
}

Write-Host "`n⏱️ 预计编译时间: 5-10 分钟" -ForegroundColor Yellow
Write-Host "`n📥 编译完成后:" -ForegroundColor Blue
Write-Host "1. 在 Actions 页面找到成功的工作流运行" -ForegroundColor White
Write-Host "2. 点击运行记录，滚动到底部" -ForegroundColor White
Write-Host "3. 下载 'portfoliopulse-ubuntu-22.04-xxx' 构建产物" -ForegroundColor White
Write-Host "4. 解压到服务器并运行 ./start.sh" -ForegroundColor White

Write-Host "`n🎯 Ubuntu 22.04 部署步骤:" -ForegroundColor Cyan
Write-Host @"
# 1. 下载并解压构建产物
wget <下载链接> -O portfoliopulse.zip
unzip portfoliopulse.zip -d /opt/portfoliopulse/

# 2. 设置权限
cd /opt/portfoliopulse/
chmod +x *.sh portfolio_pulse_backend

# 3. 配置环境变量 (可选)
cp .env.example .env
nano .env

# 4. 启动服务
./start.sh

# 5. 检查状态
./status.sh
"@ -ForegroundColor Gray

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host "✨ 云编译已启动，无需等待本地 Rust 安装！" -ForegroundColor Green
