#!/bin/bash

# 停止和清理脚本

echo "🛑 停止 PortfolioPulse 服务..."

# 停止所有容器
docker-compose down

# 可选：清理未使用的镜像和容器
read -p "是否清理未使用的 Docker 资源? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🧹 清理 Docker 资源..."
    docker system prune -f
    docker volume prune -f
fi

echo "✅ 服务已停止"
