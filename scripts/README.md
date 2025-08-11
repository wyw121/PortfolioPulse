# PortfolioPulse 增强脚本使用指南

## 📋 概述

这些增强脚本为 PortfolioPulse 提供了详细的启动诊断、优雅的服务管理和实时日志监控功能，帮助你快速定位和解决部署问题。

## 🚀 快速部署

### 方法1: 直接在服务器上部署

```bash
# 1. 上传部署脚本到服务器
scp deploy-enhanced-scripts.sh user@your-server:/tmp/

# 2. 在服务器上执行部署
ssh user@your-server
sudo bash /tmp/deploy-enhanced-scripts.sh

# 3. 启动服务
cd /opt/portfoliopulse
./start.sh
```

### 方法2: 手动复制脚本

如果你无法使用自动部署脚本，可以手动创建这些脚本：

```bash
# 在服务器的 /opt/portfoliopulse 目录下创建以下文件
sudo nano /opt/portfoliopulse/start.sh
sudo nano /opt/portfoliopulse/stop.sh
sudo nano /opt/portfoliopulse/status.sh
sudo nano /opt/portfoliopulse/logs.sh

# 添加执行权限
sudo chmod +x /opt/portfoliopulse/*.sh
```

## 📜 脚本功能详解

### 🚀 start.sh - 增强启动脚本

**主要功能:**
- 🔍 系统环境全面检查（CPU、内存、磁盘）
- 🔧 依赖软件验证（Node.js、MySQL 等）
- 🌐 环境变量加载和验证
- 📁 二进制文件存在性和权限检查
- 🔌 端口占用情况检查
- 🗄️ 数据库连接测试
- ⚡ 服务启动和健康检查
- 📊 详细的启动状态报告

**使用方法:**
```bash
cd /opt/portfoliopulse
./start.sh
```

**输出示例:**
```
🚀 PortfolioPulse 增强启动脚本
📅 启动时间: 2025-01-12 10:30:15
🏷️  版本: 1.0 Enhanced Debug

▶ 📋 系统信息检查
操作系统: Linux server 5.4.0-74-generic
当前用户: root
当前目录: /opt/portfoliopulse
磁盘空间: 15G  45G  29G  34% /

▶ 🔧 依赖检查
✅ node 已安装
v18.17.0

▶ 🌐 环境变量检查
✅ .env 文件存在
✅ 已加载环境变量

▶ 📁 文件检查
✅ ./portfolio_pulse_backend 存在且可执行
✅ 前端服务器文件: server.js

▶ 🔌 端口检查
✅ 端口 8000 可用
✅ 端口 3000 可用

▶ 🦀 启动后端服务 (端口 8000)
✅ 后端服务已启动 (PID: 12345)
✅ 后端服务健康检查通过

▶ 🟢 启动前端服务 (端口 3000)
✅ 前端服务已启动 (PID: 12346)
✅ 前端服务健康检查通过

🎉 PortfolioPulse 启动成功!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 服务状态:
  🦀 后端服务: 运行中 (PID: 12345) - http://localhost:8000
  🟢 前端服务: 运行中 (PID: 12346) - http://localhost:3000

🌐 访问地址: http://localhost:3000
```

### 🛑 stop.sh - 优雅停止脚本

**主要功能:**
- 🔍 智能进程查找（PID 文件 + 端口检测）
- 💫 优雅停止（SIGTERM → SIGKILL）
- ⏱️ 停止超时处理
- 🧹 临时文件清理
- 📊 停止过程统计

**使用方法:**
```bash
./stop.sh
```

### 📊 status.sh - 状态检查脚本

**主要功能:**
- 🔍 进程存活检查
- 🔌 端口监听状态
- 🌐 HTTP 响应测试
- 📈 资源使用情况
- 📄 日志文件摘要
- ⚡ 性能指标测试

**使用方法:**
```bash
./status.sh
```

### 📄 logs.sh - 日志监控脚本

**主要功能:**
- 🎨 彩色日志输出
- 🔍 关键词高亮（错误、警告、成功）
- 📊 多日志文件同时监控
- 🕐 时间戳显示
- 🎯 状态码高亮
- 🔧 灵活的监控选项

**使用方法:**
```bash
# 监控所有日志
./logs.sh

# 仅监控后端日志
./logs.sh -b

# 仅监控前端日志
./logs.sh -f

# 显示最后100行
./logs.sh -n 100

# 仅跟踪新日志
./logs.sh -t
```

## 🚨 故障排查指南

### 问题1: 后端服务启动失败

**可能原因:**
- 二进制文件不存在或无执行权限
- 端口 8000 被占用
- 数据库连接失败
- 环境变量配置错误

**解决步骤:**
1. 检查文件权限：`ls -la portfolio_pulse*`
2. 检查端口占用：`netstat -tulpn | grep :8000`
3. 查看后端日志：`tail -f backend.log`
4. 测试数据库连接：检查 DATABASE_URL 配置

### 问题2: 前端服务启动失败

**可能原因:**
- server.js 文件不存在
- Node.js 版本不兼容
- 端口 3000 被占用
- 前端构建文件缺失

**解决步骤:**
1. 确认 server.js 位置：`find . -name "server.js"`
2. 检查 Node.js 版本：`node --version`
3. 查看前端日志：`tail -f frontend.log`
4. 验证构建文件：`ls -la .next/` 或 `ls -la dist/`

### 问题3: 服务无法访问

**可能原因:**
- 防火墙阻止端口访问
- 服务绑定到 127.0.0.1 而非 0.0.0.0
- Nginx 配置问题

**解决步骤:**
1. 检查防火墙：`ufw status` 或 `iptables -L`
2. 测试本地访问：`curl http://localhost:3000`
3. 检查服务绑定：`netstat -tlnp | grep :3000`

## 🔧 高级配置

### 自定义端口配置

如需修改默认端口，编辑 `start.sh` 中的以下部分：

```bash
# 修改端口检查
check_port 8080  # 后端端口
check_port 3001  # 前端端口

# 修改健康检查
wait_for_service 8080 "后端服务"
wait_for_service 3001 "前端服务"
```

### 添加自定义检查项

在 `start.sh` 的检查阶段添加自定义验证：

```bash
# 自定义检查函数
check_custom_dependency() {
    if command -v your_tool >/dev/null 2>&1; then
        log_success "✅ your_tool 已安装"
        return 0
    else
        log_error "❌ your_tool 未找到"
        return 1
    fi
}

# 在依赖检查部分调用
check_custom_dependency || deps_ok=false
```

## 📝 日志管理建议

### 日志轮转配置

创建 logrotate 配置：

```bash
sudo nano /etc/logrotate.d/portfoliopulse
```

内容：
```
/opt/portfoliopulse/*.log {
    daily
    rotate 7
    compress
    delaycompress
    notifempty
    copytruncate
    su root root
}
```

### 日志清理脚本

```bash
#!/bin/bash
# cleanup-logs.sh

LOG_DIR="/opt/portfoliopulse"
cd "$LOG_DIR"

# 备份旧日志
mkdir -p logs/archive
mv backend.log frontend.log logs/archive/ 2>/dev/null || true

# 创建新日志文件
touch backend.log frontend.log
chmod 644 *.log

echo "日志清理完成"
```

## 🚀 性能优化建议

### 1. 系统资源监控

定期检查系统资源使用：
```bash
# CPU 使用率
top -p $(cat backend.pid),$(cat frontend.pid)

# 内存使用
ps -p $(cat backend.pid),$(cat frontend.pid) -o pid,comm,%mem,rss

# 磁盘 I/O
iotop -p $(cat backend.pid),$(cat frontend.pid)
```

### 2. 服务优化

- **后端优化**: 调整 Rust 编译参数，启用优化
- **前端优化**: 使用 `NODE_ENV=production`，启用缓存
- **数据库优化**: 配置连接池，优化查询

### 3. 监控集成

可以将这些脚本集成到监控系统中：

```bash
# crontab 示例
*/5 * * * * /opt/portfoliopulse/status.sh > /tmp/portfolio_status.log
```

## 💡 最佳实践

1. **定期备份**: 在重启服务前备份数据
2. **渐进式部署**: 先停止前端，再停止后端
3. **日志监控**: 使用 `logs.sh` 实时监控服务状态
4. **性能基准**: 记录正常运行时的资源使用情况
5. **故障预案**: 准备快速回滚方案

## 📞 技术支持

如果遇到问题：

1. **查看日志**: `./logs.sh` 获取实时错误信息
2. **检查状态**: `./status.sh` 确认服务状态
3. **重启服务**: `./stop.sh && sleep 2 && ./start.sh`
4. **系统检查**: 确认磁盘空间、内存、网络连接

---

**祝你使用愉快！** 🎉

这些增强脚本将大大简化 PortfolioPulse 的部署和维护工作。如果需要进一步定制或有其他问题，请随时联系。
