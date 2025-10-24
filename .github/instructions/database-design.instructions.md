---
applyTo: "database/**/*"
---

# ⚠️ 已弃用 - 数据库设计指引

> **注意**: 本项目已移除数据库依赖，改用以下架构：
> - **博客系统**: Git + Markdown 文件 (`frontend/content/blog/*.md`)
> - **数据存储**: 前端静态数据或 Rust API 硬编码数据
> - **状态管理**: 前端 Zustand 或 React Context
>
> 此文件保留仅供历史参考，不再适用于当前项目。

---

## 原数据库架构设计 (已废弃)

### 表结构规范
- 表名使用复数形式 (`users`, `projects`, `commits`)
- 字段名使用 snake_case 命名
- 主键使用 `id` (AUTO_INCREMENT)
- 时间戳字段：`created_at`, `updated_at`

### 数据类型选择
- 字符串：`VARCHAR(255)` 或 `TEXT`
- 整数：`INT` 或 `BIGINT`
- 时间：`TIMESTAMP` 或 `DATETIME`
- 布尔值：`BOOLEAN` 或 `TINYINT(1)`
- JSON 数据：`JSON` 类型

### 索引策略
- 主键自动创建聚簇索引
- 外键字段创建索引
- 查询频繁的字段创建索引
- 复合索引考虑字段顺序

## 核心数据表

### 用户表 (users)
- id, username, email, avatar_url
- github_id, access_token (加密存储)
- created_at, updated_at

### 项目表 (projects)  
- id, name, description, repository_url
- user_id (外键), status, visibility
- tech_stack (JSON), created_at, updated_at

### 提交记录表 (commits)
- id, project_id (外键), commit_hash
- message, author, committed_at
- files_changed, lines_added, lines_deleted

### 学习记录表 (learning_records)
- id, user_id (外键), title, content
- category, tags (JSON), progress
- created_at, updated_at

## 数据完整性

### 外键约束
- 定义适当的外键关系
- 设置级联删除或更新规则
- 考虑软删除策略

### 数据验证
- 非空约束 (NOT NULL)
- 唯一性约束 (UNIQUE)
- 检查约束 (CHECK)
- 默认值设置
