# PortfolioPulse Ubuntu 22.04 交叉编译方案

## 🎯 问题解决

**原始问题**: Windows 编译的二进制文件在 Linux 服务器上无法运行 (PE32+ vs ELF 格式不兼容)

**解决方案**: 提供了 6 种不同的交叉编译和部署方案，适应不同的环境和需求。

## 🚀 快速开始

### 一键智能推荐 (推荐)

```powershell
.\deploy_ubuntu.ps1
```

这个脚本会:
1. 自动检查你的开发环境
2. 智能推荐最适合的方案  
3. 提供交互式选择界面
4. 一键执行选择的方案

### 直接使用特定方案

```powershell
# Docker 编译 (最简单)
.\deploy_ubuntu.ps1 -Force docker

# Musl 静态编译 (最快)
.\deploy_ubuntu.ps1 -Force musl

# 安装开发环境
.\deploy_ubuntu.ps1 -Force install
```

## 📋 可用方案对比

| 方案 | 脚本文件 | 前置要求 | 编译时间 | 优点 | 适用场景 |
|------|----------|----------|----------|------|----------|
| **Docker编译** | `simple_cross_compile.ps1 -UseDocker` | Docker Desktop | 10-15分钟 | 环境隔离、兼容性最好 | 新手、生产环境 |
| **Musl静态编译** | `simple_cross_compile.ps1 -UseMusl` | Rust + Node.js | 3-5分钟 | 静态链接、无依赖 | 开发者、快速测试 |
| **云编译** | `simple_cross_compile.ps1` | GitHub仓库 | 5-8分钟 | 完全免费、自动化 | 团队协作、CI/CD |
| **服务器编译** | `compile-on-server.sh` | SSH访问权限 | 5-10分钟 | 原生编译、兼容最佳 | 运维人员 |
| **完整交叉编译** | `build_ubuntu_cross_compile.ps1` | 完整工具链 | 5-8分钟 | 功能最全、完全控制 | 高级用户 |
| **环境安装** | `install_dev_environment.ps1` | 管理员权限 | 15-30分钟 | 自动安装所有依赖 | 全新系统 |

## 🛠️ 脚本文件说明

### 主要脚本

1. **`deploy_ubuntu.ps1`** - 智能方案选择器
   - 自动检测环境并推荐最佳方案
   - 提供交互式菜单选择
   - 支持强制指定方案

2. **`simple_cross_compile.ps1`** - 简化交叉编译
   - Docker 编译支持
   - Musl 静态编译
   - GitHub Actions 工作流生成

3. **`build_ubuntu_cross_compile.ps1`** - 完整交叉编译
   - 全功能交叉编译工具链
   - 详细的系统检查和诊断
   - 生成完整的部署包

4. **`install_dev_environment.ps1`** - 开发环境安装
   - 自动安装 Rust 工具链
   - 自动安装 Node.js LTS
   - 安装交叉编译工具链

### 辅助脚本

5. **`scripts/compile-on-server.sh`** - 服务器端编译
   - 604行完整的服务器编译脚本
   - 自动依赖安装和管理
   - 跨平台支持

6. **增强脚本集** - 详细的运维管理脚本
   - `scripts/start-enhanced.sh` - 增强启动脚本
   - `scripts/stop-enhanced.sh` - 增强停止脚本
   - `scripts/status-enhanced.sh` - 状态检查脚本
   - `scripts/logs-enhanced.sh` - 日志管理脚本

## 🎯 推荐使用流程

### 首次使用者
1. `.\deploy_ubuntu.ps1` - 查看环境和推荐方案
2. 如提示缺少工具，运行 `.\install_dev_environment.ps1 -AutoInstall`
3. 重新运行 `.\deploy_ubuntu.ps1 -Auto`

### 有Docker环境
```powershell
.\simple_cross_compile.ps1 -UseDocker
```

### 有完整开发环境
```powershell  
.\build_ubuntu_cross_compile.ps1
```

### 偏好云编译
```powershell
.\simple_cross_compile.ps1
# 选择方案 3: GitHub Actions
```

## 📦 生成的部署包

所有方案都会生成包含以下文件的部署包：

```
linux-deploy/
├── portfolio_pulse_backend     # 后端二进制文件
├── server.js                   # 前端服务器
├── .next/                      # Next.js 构建产物
├── public/                     # 静态资源
├── start.sh                    # 启动脚本
├── stop.sh                     # 停止脚本  
├── status.sh                   # 状态检查脚本
├── .env.example                # 环境变量模板
└── README.md                   # 部署说明
```

## 🚀 服务器部署步骤

1. **上传文件**
   ```bash
   scp -r linux-deploy/ user@server:/opt/portfoliopulse/
   ```

2. **设置权限**
   ```bash
   cd /opt/portfoliopulse
   chmod +x *.sh portfolio_pulse_backend
   ```

3. **配置环境**
   ```bash
   cp .env.example .env
   nano .env  # 编辑配置
   ```

4. **启动服务**
   ```bash
   ./start.sh
   ```

5. **检查状态**
   ```bash
   ./status.sh
   ```

## 🔧 故障排除

### 常见问题

1. **"Rust 未安装"**
   ```powershell
   .\install_dev_environment.ps1 -AutoInstall
   ```

2. **"Docker 未找到"**
   - 安装 Docker Desktop: https://www.docker.com/products/docker-desktop

3. **"编译失败"**
   - 检查网络连接
   - 清理缓存: `cargo clean` / `npm ci`

4. **"Linux 服务器启动失败"**
   - 检查文件权限: `ls -la`
   - 查看日志: `cat backend.log frontend.log`
   - 检查端口占用: `netstat -tlnp`

### 获得帮助

所有脚本都支持帮助参数：
```powershell
.\deploy_ubuntu.ps1 --help
.\simple_cross_compile.ps1 --help
.\build_ubuntu_cross_compile.ps1 --help
.\install_dev_environment.ps1 --help
```

## 🎉 总结

这套完整的交叉编译解决方案解决了 Windows 开发者向 Ubuntu 22.04 服务器部署 Rust + Next.js 应用的所有痛点：

✅ **智能推荐** - 根据环境自动选择最佳方案  
✅ **多种选择** - 6种不同方案适应各种需求  
✅ **一键部署** - 自动生成完整部署包和脚本  
✅ **详细文档** - 每个步骤都有清晰说明  
✅ **故障排除** - 完善的错误处理和诊断  

现在你可以根据自己的环境和需求，选择最合适的方案来生成 Ubuntu 22.04 兼容的 PortfolioPulse 部署包！
