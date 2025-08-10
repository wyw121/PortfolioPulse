#!/usr/bin/env pwsh
# PortfolioPulse 快速验证部署脚本

param(
    [Parameter(Mandatory = $false)]
    [ValidateSet('binary', 'docker')]
    [string]$DeployType = 'binary'
)

Write-Host '🎯 PortfolioPulse 部署方式验证' -ForegroundColor Green
Write-Host '====================================='

if ($DeployType -eq 'binary') {
    Write-Host ''
    Write-Host '📦 二进制部署方式' -ForegroundColor Cyan
    Write-Host '=================='

    Write-Host '✅ 优势:' -ForegroundColor Green
    Write-Host '   • 轻量级，启动快'
    Write-Host '   • 资源占用低'
    Write-Host '   • 直接控制进程'
    Write-Host '   • 适合个人项目'

    Write-Host ''
    Write-Host '❌ 劣势:' -ForegroundColor Red
    Write-Host '   • 需要手动配置环境'
    Write-Host '   • 进程管理复杂'
    Write-Host '   • 版本依赖问题'

    Write-Host ''
    Write-Host '🚀 构建步骤:' -ForegroundColor Yellow
    Write-Host '   1. 后端: cd backend && cargo build --release'
    Write-Host '   2. 前端: cd frontend && npm run build'
    Write-Host '   3. 上传: scp 文件到服务器'
    Write-Host '   4. 启动: ./start.sh'

    Write-Host ''
    Write-Host '📁 服务器上的文件结构:' -ForegroundColor Magenta
    Write-Host @'
   /opt/portfoliopulse/
   ├── portfolio_pulse          # 后端二进制文件
   ├── frontend/
   │   ├── server.js           # Next.js 服务器
   │   ├── .next/static/       # 静态文件
   │   └── public/             # 公共文件
   ├── start.sh                # 启动脚本
   ├── stop.sh                 # 停止脚本
   └── .env                    # 环境变量
'@

} else {
    Write-Host ''
    Write-Host '⚙️ 二进制部署方式' -ForegroundColor Cyan
    Write-Host '=================='

    Write-Host '✅ 优势:' -ForegroundColor Green
    Write-Host '   • 启动速度快'
    Write-Host '   • 资源占用少'
    Write-Host '   • 不依赖容器环境'
    Write-Host '   • 简单直接'

    Write-Host ''
    Write-Host '❌ 劣势:' -ForegroundColor Red
    Write-Host '   • 需要手动配置环境'
    Write-Host '   • 跨平台部署复杂'
    Write-Host '   • 依赖管理需要注意'

    Write-Host ''
    Write-Host '🚀 构建步骤:' -ForegroundColor Yellow
    Write-Host '   1. 构建: .\scripts\build-production.ps1'
    Write-Host '   2. 部署: 上传构建产物'
    Write-Host '   3. 启动: ./start.sh 或 start.bat'

    Write-Host ''
    Write-Host '📁 二进制部署架构:' -ForegroundColor Magenta
    Write-Host @'
   服务器架构:
   ├── portfolio_pulse.exe (后端服务 - 端口 8000)
   ├── 前端静态文件 (Nginx 托管)
   ├── MySQL 数据库 (端口 3306)
   └── Nginx 反向代理 (端口 80/443)
'@
}

Write-Host ''
Write-Host '🎯 多项目部署示例' -ForegroundColor Green
Write-Host '=================='
Write-Host @'
你的服务器可以这样部署：

🌐 域名访问:
├── yourdomain.com          → PortfolioPulse (3000)
├── yourdomain.com/blog     → 个人博客 (3001)
├── yourdomain.com/shop     → 电商系统 (3002)
└── api.yourdomain.com      → 统一 API 入口

⚡ 后端服务:
├── localhost:8000          → PortfolioPulse API
├── localhost:8001          → 博客 API
├── localhost:8002          → 电商 API
└── localhost:3306          → MySQL 数据库

📊 资源占用预估 (4核8GB服务器):
├── 3个前端服务: ~600MB 内存
├── 3个后端服务: ~300MB 内存
├── MySQL数据库: ~500MB 内存
├── Nginx代理: ~50MB 内存
└── 系统预留: ~1GB 内存
💡 总计: ~2.5GB (还有足够空间扩展)
'@

Write-Host ''
Write-Host '🚀 推荐的实施路径' -ForegroundColor Green
Write-Host '=================='

if ($DeployType -eq 'binary') {
    Write-Host '第一阶段 (现在开始):'
    Write-Host '  1. 运行本地开发环境: .\scripts\setup-dev-environment.ps1'
    Write-Host '  2. 构建生产文件: .\scripts\build-production.ps1'
    Write-Host '  3. 部署到服务器: 按照 BINARY_DEPLOYMENT_GUIDE.md'
    Write-Host ''
    Write-Host '第二阶段 (熟练后):'
    Write-Host '  1. 添加更多项目'
    Write-Host '  2. 配置 Nginx 路由'
    Write-Host '  3. 建立监控系统'
} else {
    Write-Host '第一阶段 (现在开始):'
    Write-Host '  1. 运行本地开发环境: .\scripts\setup-dev-environment.ps1'
    Write-Host '  2. 构建二进制文件: .\scripts\build-production.ps1'
    Write-Host '  3. 服务器部署: 按照构建产物中的说明'
    Write-Host ''
    Write-Host '第二阶段 (扩展期):'
    Write-Host '  1. 多项目管理'
    Write-Host '  2. 自动化部署脚本'
    Write-Host '  3. 监控和日志系统'
}

Write-Host ''
Write-Host '💡 我的建议' -ForegroundColor Yellow
Write-Host '==========='
Write-Host '1. 🚀 立即开始: 先运行 .\scripts\setup-dev-environment.ps1'
Write-Host '2. 📖 选择路径: 二进制部署更适合你的需求（简单、轻量）'
Write-Host '3. 🎯 逐步扩展: 先跑通一个项目，再添加其他项目'
Write-Host '4. 🔄 后期优化: 熟练后可以考虑 Docker 或 Kubernetes'

Write-Host ''
Write-Host '❓ 下一步行动' -ForegroundColor Cyan
Write-Host '============='
Write-Host '想要立即开始吗？输入以下命令：'
Write-Host '  1. .\scripts\setup-dev-environment.ps1    # 本地开发环境'
Write-Host '  2. .\scripts\build-production.ps1 -Binary # 生产构建'
Write-Host ''
Write-Host '需要帮助？查看文档：'
Write-Host '  • docs/BINARY_DEPLOYMENT_GUIDE.md      # 二进制部署指南'
Write-Host '  • docs/MULTI_PROJECT_DEPLOYMENT.md     # 多项目部署策略'
