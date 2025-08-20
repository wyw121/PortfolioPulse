#!/bin/bash
echo "🚀 启动 PortfolioPulse 前端..."
pm2 start ecosystem.config.js
pm2 save
echo "✅ 启动完成！访问地址: http://localhost:3000"
