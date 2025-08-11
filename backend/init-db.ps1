# 初始化数据库脚本

Write-Host '初始化PortfolioPulse数据库...' -ForegroundColor Green

# 1. 创建数据库
Write-Host '创建数据库...' -ForegroundColor Yellow
$createDB = @'
CREATE DATABASE IF NOT EXISTS portfolio_pulse CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE portfolio_pulse;
'@

$createDB | mysql -u root

# 2. 运行初始迁移
Write-Host '运行001_initial.sql...' -ForegroundColor Yellow
$initialSql = Get-Content 'migrations/001_initial.sql' -Raw
$initialSql | mysql -u root portfolio_pulse

# 3. 运行种子数据
Write-Host '运行002_seed_data.sql...' -ForegroundColor Yellow
$seedSql = Get-Content 'migrations/002_seed_data.sql' -Raw
$seedSql | mysql -u root portfolio_pulse

# 4. 运行博客表迁移
Write-Host '运行003_blog_tables.sql...' -ForegroundColor Yellow
$blogSql = Get-Content 'migrations/003_blog_tables.sql' -Raw
$blogSql | mysql -u root portfolio_pulse

# 5. 验证表创建
Write-Host '验证表创建...' -ForegroundColor Yellow
$checkTables = 'SHOW TABLES;'
$tables = $checkTables | mysql -u root portfolio_pulse

Write-Host '数据库表列表:' -ForegroundColor Green
Write-Host $tables

Write-Host '数据库初始化完成!' -ForegroundColor Green
