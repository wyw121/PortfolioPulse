# 博客功能快速部署脚本

Write-Host '=== PortfolioPulse 博客功能部署 ===' -ForegroundColor Green

# 1. 构建后端
Write-Host '正在构建后端...' -ForegroundColor Yellow
Set-Location backend
try {
    cargo build --release
    Write-Host '✓ 后端构建成功' -ForegroundColor Green
} catch {
    Write-Host '✗ 后端构建失败' -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

# 2. 运行数据库迁移
Write-Host '正在运行数据库迁移...' -ForegroundColor Yellow
try {
    # 确保数据库服务运行
    if (Get-Process 'mysqld' -ErrorAction SilentlyContinue) {
        Write-Host '✓ MySQL 服务正在运行' -ForegroundColor Green
    } else {
        Write-Host '✗ MySQL 服务未运行，请先启动MySQL' -ForegroundColor Red
        exit 1
    }

    Write-Host '✓ 数据库迁移准备就绪' -ForegroundColor Green
} catch {
    Write-Host '✗ 数据库迁移失败' -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

# 3. 构建前端
Write-Host '正在构建前端...' -ForegroundColor Yellow
Set-Location ../frontend
try {
    npm install
    npm run build
    Write-Host '✓ 前端构建成功' -ForegroundColor Green
} catch {
    Write-Host '✗ 前端构建失败' -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

# 4. 检查环境变量
Write-Host '正在检查环境配置...' -ForegroundColor Yellow
Set-Location ..

$envFile = '.env'
if (Test-Path $envFile) {
    $envContent = Get-Content $envFile -Raw
    if ($envContent -match 'DATABASE_URL') {
        Write-Host '✓ 数据库连接配置已找到' -ForegroundColor Green
    } else {
        Write-Host '⚠ 请配置 DATABASE_URL 环境变量' -ForegroundColor Yellow
    }

    if ($envContent -match 'NEXT_PUBLIC_API_URL') {
        Write-Host '✓ API URL 配置已找到' -ForegroundColor Green
    } else {
        Write-Host '⚠ 请配置 NEXT_PUBLIC_API_URL 环境变量' -ForegroundColor Yellow
    }
} else {
    Write-Host '⚠ .env 文件不存在，正在创建示例文件...' -ForegroundColor Yellow
    @'
# 数据库配置
DATABASE_URL=mysql://root:password@localhost/portfolio_pulse

# API配置
NEXT_PUBLIC_API_URL=http://localhost:8000

# 博客管理员配置（可选）
BLOG_ADMIN_USER=your-username
BLOG_ADMIN_TOKEN=your-secure-token
'@ | Out-File -FilePath $envFile -Encoding utf8
    Write-Host '✓ 已创建 .env 示例文件，请根据需要修改配置' -ForegroundColor Green
}

# 5. 测试启动
Write-Host '正在测试服务启动...' -ForegroundColor Yellow

# 启动后端（后台模式）
Write-Host '启动后端服务...' -ForegroundColor Cyan
Start-Process -FilePath 'backend/target/release/portfolio-pulse-backend.exe' -WindowStyle Hidden
Start-Sleep 3

# 检查后端是否启动成功
try {
    $response = Invoke-RestMethod -Uri 'http://localhost:8000/api/health' -TimeoutSec 5
    if ($response.status -eq 'healthy') {
        Write-Host '✓ 后端服务启动成功' -ForegroundColor Green
    } else {
        Write-Host '✗ 后端服务响应异常' -ForegroundColor Red
    }
} catch {
    Write-Host '✗ 后端服务启动失败' -ForegroundColor Red
    Write-Host '请手动运行: cd backend && cargo run --release' -ForegroundColor Yellow
}

# 启动前端（开发模式）
Write-Host '启动前端服务...' -ForegroundColor Cyan
Set-Location frontend
Start-Process -FilePath 'npm' -ArgumentList 'run', 'dev' -WindowStyle Normal

Write-Host '=== 部署完成 ===' -ForegroundColor Green
Write-Host ''
Write-Host '访问地址:' -ForegroundColor Cyan
Write-Host '  前端: http://localhost:3000' -ForegroundColor White
Write-Host '  博客: http://localhost:3000/blog' -ForegroundColor White
Write-Host '  管理: http://localhost:3000/admin/blog' -ForegroundColor White
Write-Host '  后端: http://localhost:8000' -ForegroundColor White
Write-Host ''
Write-Host '博客功能说明:' -ForegroundColor Cyan
Write-Host '  1. 访问 /blog 浏览博客文章' -ForegroundColor White
Write-Host '  2. 访问 /admin/blog 管理博客内容' -ForegroundColor White
Write-Host '  3. 访问 /admin/blog/upload 上传OneNote HTML文件' -ForegroundColor White
Write-Host ''
Write-Host '使用提示:' -ForegroundColor Yellow
Write-Host '  - OneNote导出: 文件 → 另存为 → 网页,已筛选(*.html)' -ForegroundColor Gray
Write-Host '  - 支持的分类: 金融学习、技术分享、生活感悟、学习笔记' -ForegroundColor Gray
Write-Host '  - 管理员功能暂无认证保护，建议通过服务器防火墙限制访问' -ForegroundColor Gray
Write-Host ''
Write-Host '详细文档: docs/BLOG_USAGE_GUIDE.md' -ForegroundColor Cyan

# 打开浏览器
Start-Process 'http://localhost:3000/blog'
