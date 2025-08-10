# PortfolioPulse 本地测试指南

## 🚀 快速开始

### 1. 环境准备检查

确保已安装以下工具：
- ✅ Node.js (v18+)
- ✅ Rust (latest stable)
- ✅ MySQL (8.0+)

### 2. 数据库初始化

运行以下命令初始化开发数据库：

```bash
# 使用我们提供的初始化脚本
mysql -u root -p < init-dev-database.sql
```

这个脚本将会：
- 创建 `portfolio_pulse_dev` 数据库
- 创建用户 `portfoliopulse` (密码: `testpass123`)
- 创建所有必需的表
- 插入测试数据

### 3. 安装依赖

```bash
# 安装前端依赖
cd frontend
npm install

# 检查后端依赖
cd ../backend
cargo check
```

### 4. 启动服务

#### 方式一：手动启动（推荐用于调试）

**终端1 - 启动后端：**
```bash
cd backend
$env:DATABASE_URL="mysql://portfoliopulse:testpass123@localhost:3306/portfolio_pulse_dev"
$env:RUST_LOG="info"
cargo run
```

**终端2 - 启动前端：**
```bash
cd frontend  
$env:NEXT_PUBLIC_API_URL="http://localhost:8000"
npm run dev
```

#### 方式二：一键启动
```bash
.\start-test.ps1
```

### 5. 访问测试

- 🌐 前端界面: http://localhost:3000
- 🔌 后端 API: http://localhost:8000
- 📊 API 测试: http://localhost:8000/api/projects

### 6. 验证功能

测试以下功能是否正常：

1. **健康检查**
   ```bash
   curl http://localhost:8000/
   ```

2. **项目列表**
   ```bash
   curl http://localhost:8000/api/projects
   ```

3. **前端页面加载**
   - 访问 http://localhost:3000
   - 检查项目展示
   - 检查 API 数据获取

## 🔧 故障排除

### 数据库连接问题
```bash
# 检查 MySQL 服务状态
Get-Service mysql*

# 测试数据库连接
mysql -u portfoliopulse -p portfolio_pulse_dev
# 密码: testpass123
```

### 端口占用问题
```bash
# 检查端口占用
netstat -ano | findstr ":3000"
netstat -ano | findstr ":8000"

# 终止占用进程
taskkill /PID <进程ID> /F
```

### 构建失败
```bash
# 清理后端缓存
cd backend
cargo clean
cargo build

# 清理前端缓存  
cd frontend
rm -rf node_modules .next
npm install
```

## 📊 测试数据

数据库包含以下测试数据：
- 3个示例项目
- Git 活动记录
- 提交历史
- 学习记录

## 🎯 测试成功标准

✅ 后端服务正常启动（端口8000）
✅ 前端服务正常启动（端口3000）
✅ API 返回正确的项目数据
✅ 前端页面正常显示项目信息
✅ 数据库连接正常

## 🚀 测试成功后的下一步

当本地测试完全成功后，您可以运行生产构建：

```bash
.\scripts\build-production.ps1
```

构建完成后，在 `build/` 目录中将包含：
- 后端二进制文件
- 前端静态文件
- 启动脚本
- 部署文档

## 💡 开发提示

- 使用 `RUST_LOG=debug` 获取详细日志
- 前端热重载在开发模式下自动启用
- 数据库表结构变更需要运行迁移
- 建议使用 VS Code 的 Rust 和 TypeScript 扩展
