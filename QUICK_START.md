# 🚀 快速开始指南

> 使用 Docker 挂载方式编译 Rust 项目并部署到 Ubuntu 服务器

## 前提条件

- ✅ Windows 系统 + Docker Desktop
- ✅ Ubuntu Server 22.04 LTS 目标服务器
- ✅ SSH 访问权限到目标服务器

## 🎯 三步快速部署

### 第一步：初始化服务器（仅首次）

```powershell
# 上传服务器设置脚本
scp scripts/setup-ubuntu-server.sh username@your-server-ip:~/

# 在服务器上运行（这将安装所有必要的软件和配置）
ssh username@your-server-ip "./setup-ubuntu-server.sh"
```

### 第二步：一键编译部署

```powershell
# 编译并部署到服务器，自动重启服务
.\one-click-deploy.ps1 -ServerIP "192.168.1.100" -Username "ubuntu" -AutoRestart
```

### 第三步：验证部署

```bash
# 在服务器上检查服务状态
sudo systemctl status portfolio-pulse

# 查看服务日志
sudo journalctl -u portfolio-pulse -f

# 测试 API 接口
curl http://localhost:3000/health
```

## 🔧 常用命令

### 开发机器上

```powershell
# 仅编译（不部署）
.\one-click-deploy.ps1

# 清理编译缓存后重新编译部署
.\one-click-deploy.ps1 -ServerIP "192.168.1.100" -Username "ubuntu" -Clean -AutoRestart

# 查看详细编译日志
.\build-with-docker.ps1 -Verbose
```

### 服务器上

```bash
# 服务管理
sudo systemctl start portfolio-pulse    # 启动
sudo systemctl stop portfolio-pulse     # 停止
sudo systemctl restart portfolio-pulse  # 重启
sudo systemctl status portfolio-pulse   # 状态

# 日志查看
sudo journalctl -u portfolio-pulse -f   # 实时日志
sudo journalctl -u portfolio-pulse -n 100  # 最近100行

# Nginx 管理
sudo systemctl restart nginx
sudo nginx -t  # 测试配置
```

## 📁 重要文件位置

### 开发机器

- `.\build-with-docker.ps1` - 编译脚本
- `.\deploy-to-server.ps1` - 部署脚本
- `.\one-click-deploy.ps1` - 一键编译部署
- `backend/target/x86_64-unknown-linux-gnu/release/` - 编译输出

### 服务器

- `/opt/portfolio-pulse/` - 应用部署目录
- `/etc/systemd/system/portfolio-pulse.service` - 服务配置
- `/etc/nginx/sites-available/portfolio-pulse` - Nginx 配置
- `/var/log/portfolio-pulse/` - 应用日志目录

## 🐛 故障排除

### 编译失败
```powershell
# 清理 Docker 缓存重新编译
docker system prune -f
.\build-with-docker.ps1 -Clean -Verbose
```

### 部署失败
```powershell
# 检查 SSH 连接
ssh username@server-ip "echo 'SSH 连接正常'"

# 检查服务器磁盘空间
ssh username@server-ip "df -h"
```

### 服务启动失败
```bash
# 查看详细错误日志
sudo journalctl -u portfolio-pulse -n 50

# 检查二进制文件权限
ls -la /opt/portfolio-pulse/

# 手动测试二进制文件
sudo -u www-data /opt/portfolio-pulse/portfolio_pulse_backend
```

## 🔄 更新部署

每次代码更新后，只需运行：

```powershell
.\one-click-deploy.ps1 -ServerIP "your-server-ip" -Username "username" -AutoRestart
```

这将：
1. 🔨 编译最新代码
2. 📤 上传到服务器
3. 🔄 自动重启服务
4. ✅ 验证部署状态

## 🎉 完成！

现在您可以：
- 💻 在 Windows 上开发 Rust 代码
- 🐳 使用 Docker 挂载方式快速编译
- 🚀 一键部署到 Ubuntu 服务器
- 📊 实时监控服务状态

更详细的配置和故障排除，请参考 [完整文档](DOCKER_MOUNT_BUILD_GUIDE.md)。
