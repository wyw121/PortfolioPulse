# PortfolioPulse 工作区模块化划分指南

## 📁 优化后的工作区结构

### 主工作区配置
```
PortfolioPulse.code-workspace - 完整项目工作区（推荐日常开发使用）
```

### 模块专用工作区
```
frontend/frontend-only.code-workspace - 纯前端开发工作区
backend/backend-only.code-workspace - 纯后端开发工作区
```

## 🎯 模块划分详解

### 1. 📁 项目根目录
- **作用**: 项目全局配置和文档
- **包含**: README.md, .gitignore, 环境变量文件, 全局脚本
- **使用场景**: 项目概览、全局配置管理

### 2. 🎨 前端应用 (Next.js) - 端口 3000
- **技术栈**: Next.js 15, TypeScript, Tailwind CSS, shadcn/ui
- **目录结构**:
  ```
  frontend/
  ├── app/          # App Router 页面
  ├── components/   # React 组件
  │   ├── ui/      # shadcn/ui 基础组件
  │   └── custom/  # 自定义业务组件
  ├── lib/         # 工具库和配置
  ├── hooks/       # 自定义 React Hooks
  ├── store/       # Zustand 状态管理
  ├── types/       # TypeScript 类型定义
  └── styles/      # 全局样式和主题
  ```

### 3. ⚙️ 后端服务 (Rust) - 端口 8000
- **技术栈**: Rust, Axum, MySQL, Diesel ORM
- **目录结构**:
  ```
  backend/
  ├── src/
  │   ├── main.rs      # 应用入口
  │   ├── handlers.rs  # API 处理器
  │   ├── models.rs    # 数据模型
  │   ├── auth.rs      # 认证模块
  │   └── services/    # 业务逻辑
  └── migrations/      # 数据库迁移
  ```

### 4. 🗄️ 数据库配置 - 端口 3306
- **技术**: MySQL 8.0+
- **包含**:
  - 数据库架构设计
  - 初始化脚本
  - 种子数据
  - 备份策略

### 5. 📜 部署脚本
- **功能**: 自动化构建和部署
- **包含**:
  - 生产构建脚本
  - 环境设置脚本
  - 服务启动/停止脚本
  - 数据库迁移脚本

### 6. 📚 项目文档
- **内容**: 技术文档、API 文档、部署指南
- **格式**: Markdown + 图表

### 7. ⚙️ 配置文件
- **包含**: 各种环境的配置模板
- **类型**: 数据库配置、服务器配置、构建配置

## 🛠️ 工作区功能特性

### 智能配置
- ✅ **前后端分离**: 独立的开发环境和构建流程
- ✅ **类型安全**: TypeScript 严格模式 + Rust 类型系统
- ✅ **代码格式化**: Prettier + rustfmt 自动格式化
- ✅ **实时检查**: ESLint + Clippy 代码质量检查
- ✅ **智能提示**: 完整的 IntelliSense 支持

### 集成任务
- 🏗️ **构建任务**: 前端 Next.js 构建 + 后端 Rust 编译
- 🚀 **开发服务器**: 热重载开发环境
- 🧪 **测试套件**: 前端 Jest + 后端 Cargo test
- 🗄️ **数据库操作**: Diesel 迁移管理
- 🔧 **代码格式化**: 一键格式化所有代码

### 调试支持
- 🐛 **Rust 调试**: LLDB 集成，支持断点调试
- 🌐 **前端调试**: 浏览器开发工具集成
- 📊 **性能监控**: 内置性能分析工具

## 🚀 使用指南

### 1. 初始化工作区
```powershell
# 运行工作区优化脚本
./setup-workspace.ps1
```

### 2. 选择工作区模式

#### 🔄 全栈开发（推荐）
```bash
# 打开主工作区
code PortfolioPulse.code-workspace
```

#### 🎨 纯前端开发
```bash
# 打开前端专用工作区
code frontend/frontend-only.code-workspace
```

#### ⚙️ 纯后端开发
```bash
# 打开后端专用工作区
code backend/backend-only.code-workspace
```

### 3. 快速启动开发

#### 使用 VS Code 任务（推荐）
1. `Ctrl+Shift+P` 打开命令面板
2. 输入 `Tasks: Run Task`
3. 选择需要的任务：
   - 🚀 启动前端开发服务器
   - 🚀 启动后端开发服务器
   - 🏗️ 构建前端/后端
   - 🧪 运行测试

#### 使用命令行
```powershell
# 前端开发
cd frontend
npm run dev

# 后端开发
cd backend
cargo run

# 数据库迁移
cd backend
diesel migration run
```

## 🎯 最佳实践

### 开发流程
1. **启动顺序**: 数据库 → 后端 → 前端
2. **代码提交**: 格式化 → 测试 → 提交
3. **分支策略**: main (生产) → develop (开发) → feature/* (功能)

### 性能优化
- **前端**: 使用 Next.js 图片优化、组件懒加载
- **后端**: Rust 编译优化、数据库查询优化
- **部署**: 二进制部署，减少运行时开销

### 代码质量
- **TypeScript**: 严格模式，避免 any 类型
- **Rust**: 使用 clippy，处理所有 warnings
- **测试**: 保持高测试覆盖率

## 📊 工作区对比

| 特性 | 主工作区 | 前端专用 | 后端专用 |
|------|----------|----------|----------|
| 完整项目视图 | ✅ | ❌ | ❌ |
| 前端开发 | ✅ | ✅ | ❌ |
| 后端开发 | ✅ | ❌ | ✅ |
| 数据库管理 | ✅ | ❌ | ✅ |
| 部署管理 | ✅ | ❌ | ❌ |
| 性能占用 | 高 | 低 | 中 |
| 启动速度 | 慢 | 快 | 中 |

## 🔧 故障排查

### 常见问题

1. **端口冲突**
   ```powershell
   # 检查端口占用
   netstat -ano | findstr :3000
   netstat -ano | findstr :8000
   ```

2. **依赖问题**
   ```powershell
   # 清理前端依赖
   cd frontend && rm -rf node_modules package-lock.json && npm install

   # 清理 Rust 缓存
   cd backend && cargo clean && cargo build
   ```

3. **数据库连接**
   ```powershell
   # 测试数据库连接
   mysql -u root -p -h localhost
   ```

### 性能调优

1. **VS Code 设置**
   - 禁用不需要的扩展
   - 排除大型目录（target, node_modules）
   - 限制文件监听范围

2. **开发环境**
   - 使用 SSD 存储
   - 分配足够的内存
   - 关闭不必要的后台程序

## 📝 更新日志

- **v1.0.0**: 初始工作区配置
- **v1.1.0**: 添加模块化划分
- **v1.2.0**: 集成任务和调试配置
- **v1.3.0**: 优化性能和扩展推荐

---

🎉 **恭喜！您的 PortfolioPulse 工作区已经完全优化！**

使用 `./setup-workspace.ps1` 快速开始开发！
