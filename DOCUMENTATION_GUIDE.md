# PortfolioPulse 文档系统快速指南

## 🚀 5分钟上手指南

### 📖 新人入门路径
```bash
1. README.md                           # 项目概览 + 快速开始
2. .github/copilot-instructions.md     # AI助手开发指南
3. docs/DOCUMENTATION_INDEX.md         # 完整文档导航
```

### 🤖 GitHub Copilot 用户
**自动生效**: 编辑文件时，对应的 `.instructions.md` 会自动加载
- 编辑 `frontend/` → `frontend-development.instructions.md`
- 编辑 `backend/` → `backend-development.instructions.md`
- 编辑 `components/` → `ui-style-system.instructions.md`

### 👨‍💻 开发者日常使用

#### 快速开发命令
```bash
# 前端开发 (端口 3000)
cd frontend && npm run dev

# 后端开发 (端口 8000)
cd backend && cargo run

# 文档同步检查
cd scripts && node check-docs-sync.js
```

#### 查找文档技巧
- **概览信息**: 看 `README.md`
- **开发指导**: 看 `.github/instructions/`
- **深度学习**: 看 `docs/` 目录
- **导航迷路**: 看 `docs/DOCUMENTATION_INDEX.md`

## 🏗️ 文档架构一图了解

```
PortfolioPulse/
├── 📋 README.md                    # 入口导航
├── 🤖 .github/
│   ├── copilot-instructions.md     # 核心AI指令
│   └── instructions/               # 模块化开发指令
│       ├── frontend-development.instructions.md
│       ├── backend-development.instructions.md
│       └── ...
└── 📚 docs/
    ├── DOCUMENTATION_INDEX.md      # 导航中心
    ├── SYSTEM_ARCHITECTURE_ANALYSIS.md
    ├── TECHNICAL_IMPLEMENTATION_GUIDE.md
    └── ...
```

## 💡 最佳实践

### ✅ 开发时
- 让 GitHub Copilot 自动加载指令，获得精准建议
- 遇到复杂问题时查看 `docs/` 详细文档
- 定期运行 `check-docs-sync.js` 检查文档同步

### ✅ 更新文档时
- 修改 AI 指令后，记得更新对应的详细文档
- 新增文档时，更新 `DOCUMENTATION_INDEX.md`
- 重要改动记录在 Git 提交信息中

### ✅ 团队协作
- PR 中检查文档变更的一致性
- 使用 Conventional Commits 规范提交信息
- 定期回顾和优化文档架构

---

**🎯 核心理念**: AI指令简洁精准，技术文档深度完整，导航清晰易用。

更多详情请查看: [docs/DOCUMENTATION_OPTIMIZATION_SUMMARY.md](docs/DOCUMENTATION_OPTIMIZATION_SUMMARY.md)
