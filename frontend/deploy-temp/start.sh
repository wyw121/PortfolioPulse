#!/bin/bash
# Next.js Standalone 启动脚本

# 设置环境变量
export NODE_ENV=production
export PORT=3000
export HOSTNAME=0.0.0.0

echo "=========================================="
echo "启动 PortfolioPulse Frontend"
echo "=========================================="
echo "环境: $NODE_ENV"
echo "端口: $PORT"
echo "主机: $HOSTNAME"
echo "=========================================="

# 启动应用
node server.js
