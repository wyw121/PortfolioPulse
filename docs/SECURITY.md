# Security Guidelines for PortfolioPulse

## 🔒 重要安全提醒

### 1. 敏感信息处理

**永远不要将以下信息提交到 Git 仓库：**
- GitHub Personal Access Tokens (`ghp_...`)
- 数据库密码
- API 密钥
- 私钥文件
- 生产环境配置

### 2. 环境变量最佳实践

**本地开发：**
```bash
# 复制示例文件
cp .env.example .env

# 编辑你的实际配置
vim .env  # 或使用你偏好的编辑器
```

**生产环境：**
- 在 Vercel/部署平台的环境变量设置中配置
- 不要在代码中硬编码敏感信息

### 3. GitHub Token 安全

**创建 GitHub Token：**
1. 访问 GitHub Settings > Developer settings > Personal access tokens
2. 选择 "Tokens (classic)"
3. 点击 "Generate new token (classic)"
4. 设置适当的权限范围：
   - `repo` - 访问私有仓库（如果需要）
   - `read:user` - 读取用户信息
   - `user:email` - 读取用户邮箱

**Token 权限最小化原则：**
- 只授予必要的权限
- 定期轮换 Token
- 为不同项目使用不同的 Token

### 4. 文件保护

**`.gitignore` 必需配置：**
```gitignore
# 环境变量
.env
.env.local
.env.production
.env.development

# 密钥文件
*.key
*.pem
secrets/

# 数据库备份
*.sql.backup
*.dump
```

### 5. 如果意外提交了敏感信息

**立即行动清单：**
1. 撤销/重新生成受影响的令牌
2. 从历史记录中移除敏感信息：
   ```bash
   # 创建新的干净历史
   git checkout --orphan new-main
   git add .
   git commit -m "Clean repository - remove sensitive data"
   git branch -D main
   git branch -M new-main main
   git push --force origin main
   ```
3. 更新所有使用该令牌的服务

### 6. 代码审查检查点

**提交前自检：**
- [ ] 没有硬编码的密码或令牌
- [ ] `.env` 文件在 `.gitignore` 中
- [ ] 使用 `your_token_here` 等占位符
- [ ] 文档中没有真实凭证

### 7. 生产部署安全

**Vercel 环境变量设置：**
1. 项目设置 > Environment Variables
2. 添加所有必需的环境变量
3. 选择适当的环境（Development/Production）

**数据库安全：**
- 使用强密码
- 启用 SSL/TLS 连接
- 限制数据库访问 IP
- 定期备份数据

### 8. 监控和告警

**设置安全监控：**
- GitHub Security Alerts
- Dependabot 自动更新
- Secret Scanning (已启用)
- Code Scanning

## ⚡ 紧急响应

如果发现安全问题：
1. 立即撤销相关凭证
2. 评估影响范围
3. 清理历史记录
4. 更新所有相关系统
5. 记录事件和响应措施

---

**记住：安全是一个持续的过程，不是一次性的任务。**
