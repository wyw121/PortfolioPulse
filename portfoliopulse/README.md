# PortfolioPulse 前端部署包

## 部署步骤

1. 将此整个目录上传到服务器的 `/opt/portfoliopulse-frontend`
2. 在服务器上运行: `chmod +x *.sh`
3. 启动应用: `./start.sh`

## 服务器要求

- Node.js 18+
- PM2 进程管理器

## 管理命令

- 启动: `./start.sh`
- 停止: `./stop.sh`  
- 重启: `./restart.sh`
- 查看状态: `pm2 status`
- 查看日志: `pm2 logs portfoliopulse-frontend`

## 访问地址

- 本地: http://localhost:3000
- 外网: http://your-server-ip:3000

## 文件说明

- `server.js` - Next.js 服务器主文件
- `.next/` - Next.js 构建产物
- `ecosystem.config.js` - PM2 配置文件
- `*.sh` - 管理脚本
