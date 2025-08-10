#!/bin/bash

# 快速启动脚本

set -e

echo "🚀 启动 PortfolioPulse 服务..."

# 检查 Docker 是否运行
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker 未运行，请先启动 Docker 服务"
    echo "   sudo systemctl start docker"
    exit 1
fi

# 检查环境变量文件
if [ ! -f ".env" ]; then
    echo "⚠️  .env 文件不存在，复制默认配置..."
    cp .env.example .env
    echo "📝 请编辑 .env 文件后重新运行此脚本"
    exit 1
fi

# 构建和启动服务
echo "📦 构建和启动 Docker 容器..."
docker-compose up --build -d

# 等待服务启动
echo "⏳ 等待服务启动..."
sleep 10

# 检查服务状态
echo "📊 检查服务状态..."
docker-compose ps

# 检查后端健康状态
echo "🔍 检查后端健康状态..."
if curl -f http://localhost:8000/api/health > /dev/null 2>&1; then
    echo "✅ 后端服务健康"
else
    echo "❌ 后端服务启动异常"
    echo "查看后端日志: docker-compose logs backend"
fi

# 检查前端状态
echo "🔍 检查前端状态..."
if curl -f http://localhost:3000 > /dev/null 2>&1; then
    echo "✅ 前端服务健康"
else
    echo "❌ 前端服务启动异常"
    echo "查看前端日志: docker-compose logs frontend"
fi

echo ""
echo "🎉 PortfolioPulse 启动完成！"
echo ""
echo "服务地址:"
echo "- 前端: http://localhost:3000"
echo "- 后端: http://localhost:8000"
echo "- API健康检查: http://localhost:8000/api/health"
echo ""
echo "管理命令:"
echo "- 查看日志: docker-compose logs -f [service]"
echo "- 停止服务: docker-compose down"
echo "- 重启服务: docker-compose restart [service]"
echo "- 查看状态: docker-compose ps"
