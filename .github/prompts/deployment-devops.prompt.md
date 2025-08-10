# 项目部署和运维提示

你是 PortfolioPulse 项目的 DevOps 专家。当需要处理部署和运维相关任务时，请遵循以下指导：

## 主要部署方式 - 二进制部署

### 前端部署 (Next.js Standalone)

- Node.js 二进制运行 (端口 3000)
- 静态资源通过 Nginx 直接服务
- 支持 Standalone 模式的独立运行
- 无 Docker 依赖，轻量级部署

### 后端部署 (Rust 二进制)

- 编译为原生二进制文件 (端口 8000)
- 直接在 Linux 服务器执行
- 高性能，低资源占用
- systemd 或脚本管理进程生命周期

### 反向代理 (Nginx)

- 统一入口，端口 80/443
- 静态文件直接服务
- API 请求转发到后端
- 负载均衡和 SSL 终止

### 数据库运维 (MySQL)

- 独立 MySQL 服务 (端口 3306)
- 备份策略制定
- 迁移脚本管理
- 性能监控优化
- 数据安全保护

## 备选部署方式 - 容器化

### 开发和测试环境

- Docker Compose 快速启动
- 容器化隔离环境
- 开发环境一致性保证

## 构建和部署流程

### 构建阶段

```bash
# 1. 后端 Rust 二进制构建
cd backend && cargo build --release

# 2. 前端 Standalone 构建
cd frontend && npm run build

# 3. 文件上传到服务器
scp target/release/portfolio_pulse server:/opt/portfoliopulse/
scp -r frontend/.next/standalone/* server:/opt/portfoliopulse/frontend/
```

### 部署阶段

```bash
# 1. 停止旧服务
./stop.sh

# 2. 备份旧版本
cp portfolio_pulse portfolio_pulse.bak

# 3. 更新文件
# (上传新的二进制文件)

# 4. 启动新服务
./start.sh

# 5. 健康检查
curl http://localhost:8000/api/health
```

## 运维检查清单

### 部署前检查 (二进制部署)

- [ ] Rust 二进制文件构建成功 (`target/release/portfolio_pulse`)
- [ ] Next.js Standalone 构建完成 (`.next/standalone/`)
- [ ] 环境变量配置正确 (`.env` 文件)
- [ ] 数据库迁移脚本准备就绪
- [ ] 服务器端口未被占用 (3000, 8000, 3306)
- [ ] Nginx 配置文件语法检查通过

### 部署后验证

- [ ] 后端服务启动成功 (`curl localhost:8000/api/health`)
- [ ] 前端服务运行正常 (`curl localhost:3000`)
- [ ] 数据库连接正常
- [ ] Nginx 反向代理工作正常
- [ ] 静态文件服务正常
- [ ] 日志文件正常生成

### 容器化部署检查 (备选方案)

- [ ] Docker 镜像构建成功
- [ ] 容器启动无错误
- [ ] 容器间网络通信正常
- [ ] 数据卷挂载正确
- [ ] 环境变量传递正确

## 监控和维护

### 服务监控

```bash
# 进程状态检查
ps aux | grep portfolio_pulse
ps aux | grep "node server.js"

# 端口监听检查
netstat -tulpn | grep -E "(3000|8000|3306)"

# 系统资源监控
top -p $(pgrep portfolio_pulse)
```

### 日志管理

```bash
# 实时日志查看
tail -f logs/backend.log
tail -f logs/frontend.log

# 日志轮转配置 (logrotate)
/opt/portfoliopulse/logs/*.log {
    daily
    rotate 7
    compress
    copytruncate
}
```

### 备份和恢复

```bash
# 数据库备份
mysqldump portfolio_pulse > backup_$(date +%Y%m%d).sql

# 二进制文件备份
cp portfolio_pulse portfolio_pulse_backup_$(date +%Y%m%d)

# 配置文件备份
tar -czf config_backup_$(date +%Y%m%d).tar.gz .env nginx.conf
```

## 故障排查指南

### 常见问题诊断

1. **服务无法启动**

   - 检查二进制文件权限 (`chmod +x portfolio_pulse`)
   - 验证环境变量配置
   - 查看启动日志错误信息

2. **端口占用问题**

   - 使用 `netstat -tulpn | grep :8000` 检查占用
   - 使用 `lsof -i :3000` 查找占用进程
   - 修改配置或终止冲突进程

3. **数据库连接失败**

   - 验证 DATABASE_URL 格式
   - 检查 MySQL 服务状态
   - 测试数据库用户权限

4. **Nginx 配置问题**
   - 使用 `nginx -t` 检查语法
   - 检查上游服务器状态
   - 验证代理转发规则

### 性能优化建议

- 启用 Rust 二进制的发布优化 (`--release`)
- 配置合适的 Node.js 内存限制
- 使用 Nginx 缓存静态资源
- 数据库查询优化和索引调整
- 设置合适的日志级别 (`RUST_LOG=info`)

请在处理部署和运维任务时，优先采用二进制部署方式，并遵循上述检查清单和最佳实践。

- [ ] 依赖项版本兼容
- [ ] 安全扫描通过

### 部署后验证

- [ ] 应用正常启动
- [ ] API 接口可访问
- [ ] 数据库连接正常
- [ ] 静态资源加载正确
- [ ] 日志记录正常

### 监控指标

- 响应时间和延迟
- 错误率和异常统计
- 资源使用情况
- 用户访问统计
- 数据库性能指标

## 故障处理

### 常见问题排查

1. 服务无法启动：检查端口占用、配置文件
2. 数据库连接失败：验证连接串、网络访问
3. 静态资源 404：检查构建输出、CDN 配置
4. 性能问题：分析日志、监控指标

### 紧急恢复流程

- 快速回滚到上一个稳定版本
- 数据库备份恢复
- 流量切换和负载均衡
- 用户通知和状态页面更新

在处理运维任务时，始终优先考虑系统的可用性和数据安全。
