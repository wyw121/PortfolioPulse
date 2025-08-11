#!/bin/bash
# 数据库初始化脚本 - 用于 CI/CD

set -e

echo "🗄️ 初始化 PortfolioPulse 数据库..."

# 数据库连接参数
DB_HOST=${DB_HOST:-127.0.0.1}
DB_PORT=${DB_PORT:-3306}
DB_USER=${DB_USER:-root}
DB_PASS=${DB_PASS:-password}
DB_NAME=${DB_NAME:-portfolio_pulse}

# 等待数据库服务启动
echo "⏳ 等待 MySQL 服务启动..."
for i in {1..30}; do
    if mysqladmin ping -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" --silent; then
        echo "✅ MySQL 已就绪"
        break
    fi
    echo "等待 MySQL... ($i/30)"
    sleep 2
done

# 创建数据库
echo "🏗️ 创建数据库..."
mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" -e "
    DROP DATABASE IF EXISTS $DB_NAME;
    CREATE DATABASE $DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    USE $DB_NAME;
"

# 运行迁移
echo "📋 运行数据库迁移..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MIGRATIONS_DIR="$SCRIPT_DIR/../backend/migrations"

if [ -d "$MIGRATIONS_DIR" ]; then
    for migration in "$MIGRATIONS_DIR"/*.sql; do
        if [ -f "$migration" ]; then
            echo "运行: $(basename "$migration")"
            mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$migration"
        fi
    done
else
    echo "❌ 迁移目录不存在: $MIGRATIONS_DIR"
    exit 1
fi

echo "✅ 数据库初始化完成！"
echo "📊 连接信息: mysql://$DB_USER:****@$DB_HOST:$DB_PORT/$DB_NAME"
