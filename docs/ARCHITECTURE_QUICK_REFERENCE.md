# 架构优化快速参考卡

> 📌 **目的**: 为开发者提供架构优化的速查指南  
> 🔗 **详细文档**: [ARCHITECTURE_ANALYSIS.md](./ARCHITECTURE_ANALYSIS.md)

---

## 🚀 立即行动 (本周完成)

### 1️⃣ 创建Repository层 (优先级1)

```bash
# 创建目录
mkdir backend/src/repositories
```

```rust
// backend/src/repositories/mod.rs
pub mod project;

#[async_trait]
pub trait ProjectRepository: Send + Sync {
    async fn find_all(&self) -> Result<Vec<Project>>;
    async fn find_by_id(&self, id: Uuid) -> Result<Option<Project>>;
}
```

**解决问题**: 问题1, 问题2

---

### 2️⃣ 引入前端状态管理 (优先级1)

```bash
cd frontend-vite
npm install zustand
```

```typescript
// src/store/projectStore.ts
import { create } from 'zustand';

export const useProjectStore = create<ProjectStore>((set) => ({
  projects: [],
  fetchProjects: async () => { /* 实现 */ }
}));
```

**解决问题**: 问题7

---

### 3️⃣ 分离类型定义 (优先级2)

```bash
# 创建类型目录
mkdir frontend-vite/src/types
```

```typescript
// src/types/models.ts
export interface Project { /* ... */ }
export interface BlogPost { /* ... */ }

// src/lib/api.ts
import type { Project } from '@/types/models';
```

**解决问题**: 问题9

---

## 📋 架构检查清单

### 后端 (Rust)

- [ ] Service层是否包含硬编码数据? → ❌ 移到Repository
- [ ] 是否直接在Handler中构造Service? → ❌ 使用依赖注入
- [ ] models是否混合了多种职责? → ❌ 分离domain/dto/external
- [ ] 是否有足够的单元测试? → ✅ 每个Service/Repository都要测试

### 前端 (React)

- [ ] 是否有状态管理? → ✅ 使用Zustand/Jotai
- [ ] 组件是否直接调用API? → ❌ 使用自定义Hook
- [ ] 类型定义是否集中管理? → ✅ 放在types/目录
- [ ] API错误是否妥善处理? → ✅ 统一错误处理

---

## 🔧 代码模板

### Repository模式 (Rust)

```rust
// 1. 定义Trait
#[async_trait]
pub trait ProjectRepository {
    async fn find_all(&self) -> Result<Vec<Project>>;
}

// 2. 实现真实Repository
pub struct MySqlProjectRepository {
    pool: MySqlPool,
}

// 3. 实现Mock Repository
pub struct MockProjectRepository {
    data: Vec<Project>,
}

// 4. Service使用Repository
pub struct ProjectService {
    repo: Arc<dyn ProjectRepository>,
}
```

---

### 自定义Hook模式 (React)

```typescript
// hooks/useProjects.ts
export function useProjects() {
  const [projects, setProjects] = useState<Project[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchProjects = async () => {
    try {
      setLoading(true);
      const data = await api.getProjects();
      setProjects(data);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { fetchProjects(); }, []);

  return { projects, loading, error, refetch: fetchProjects };
}
```

---

### 状态管理模式 (Zustand)

```typescript
// store/projectStore.ts
import { create } from 'zustand';

interface ProjectStore {
  projects: Project[];
  loading: boolean;
  fetchProjects: () => Promise<void>;
}

export const useProjectStore = create<ProjectStore>((set) => ({
  projects: [],
  loading: false,
  
  fetchProjects: async () => {
    set({ loading: true });
    try {
      const data = await api.getProjects();
      set({ projects: data });
    } finally {
      set({ loading: false });
    }
  },
}));

// 使用
function ProjectList() {
  const { projects, fetchProjects } = useProjectStore();
  // ...
}
```

---

## 🎯 架构决策记录

### 为什么需要Repository层?

**问题**: Service层直接操作数据库或硬编码数据  
**方案**: 引入Repository抽象层  
**收益**: 
- ✅ 数据访问逻辑可复用
- ✅ 易于Mock进行单元测试
- ✅ 切换数据源不影响业务逻辑

---

### 为什么需要状态管理?

**问题**: 组件各自管理状态,导致重复请求  
**方案**: 使用Zustand集中管理  
**收益**:
- ✅ 全局状态共享
- ✅ 减少API调用
- ✅ 状态更新一致

---

### 为什么分离类型定义?

**问题**: 类型定义散落在API文件中  
**方案**: 集中到types/目录  
**收益**:
- ✅ 类型定义可复用
- ✅ 便于生成和维护
- ✅ 前后端类型同步

---

## 📊 重构前后对比

### Service层

**重构前** ❌:
```rust
pub async fn get_all(&self) -> Result<Vec<ProjectResponse>> {
    // 硬编码数据
    let projects = vec![Project { ... }];
    Ok(projects.into_iter().map(Into::into).collect())
}
```

**重构后** ✅:
```rust
pub async fn get_all(&self) -> Result<Vec<ProjectResponse>> {
    let projects = self.repository.find_all().await?;
    Ok(projects.into_iter().map(Into::into).collect())
}
```

---

### 组件状态

**重构前** ❌:
```tsx
function ProjectList() {
  const [projects, setProjects] = useState<Project[]>([]);
  
  useEffect(() => {
    api.getProjects().then(setProjects);
  }, []);
  
  return <div>{/* render */}</div>;
}
```

**重构后** ✅:
```tsx
function ProjectList() {
  const { projects, loading, error } = useProjects();
  
  if (loading) return <Loading />;
  if (error) return <Error message={error} />;
  
  return <div>{/* render */}</div>;
}
```

---

## 🛡️ 防御性编程检查

### Rust

- [ ] 使用`Result<T, E>`而非`panic!`
- [ ] 外部输入必须验证
- [ ] 数据库查询使用参数化
- [ ] 错误信息不暴露敏感信息

### TypeScript

- [ ] 所有API调用有错误处理
- [ ] 外部数据有类型守卫
- [ ] 异步操作有loading状态
- [ ] 组件边界有错误边界

---

## 📈 度量指标

### 代码质量

- **圈复杂度**: < 10
- **函数行数**: < 50
- **文件行数**: < 500
- **测试覆盖率**: > 60%

### 架构质量

- **模块耦合度**: 低 (< 3层依赖)
- **模块内聚度**: 高 (单一职责)
- **依赖方向**: 向内 (外层→内层)

---

## 🔄 持续改进

### 每周检查

- 新增代码是否符合架构规范?
- 是否有新的技术债务?
- 测试覆盖率是否下降?

### 每月复查

- 架构决策是否需要调整?
- 重构计划执行情况?
- 团队反馈收集

---

## 🆘 常见问题

### Q: 重构会影响现有功能吗?
**A**: 采用增量式重构,保持功能不变。使用feature flag控制新旧代码切换。

### Q: 需要多长时间完成?
**A**: 核心重构约3-4周,完整优化约5周。可分阶段进行。

### Q: 如何保证重构质量?
**A**: 
1. 每步都写单元测试
2. Code Review必须通过
3. 保留原代码直到新代码稳定

---

**创建日期**: 2025年10月23日  
**适用版本**: v0.1.0+  
**维护**: 随架构演进更新
