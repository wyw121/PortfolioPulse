# PortfolioPulse 项目风格建议

## 📋 设计风格定位

**选定风格**: **渐变科技风格（Gradient Tech）**
**参考标杆**: Vercel、Stripe
**布局模式**: **Vercel 风格 - 大屏中心式布局** ⭐ 已确定
**适用场景**: 个人技术项目展示平台、开发者作品集

### 🎯 布局特色
- **极简主义设计**: 大量留白空间，内容居中对齐
- **全屏 Hero Section**: 突出个人品牌和核心信息
- **卡片式展示**: 项目以3列网格形式展示
- **专业简洁**: 营造高端专业的视觉形象
- **响应式设计**: 完美适配各种屏幕尺寸

---

## 📝 内容策略 (已确定)

### 🎨 品牌标识与 Hero Section
- **个人品牌 Slogan**: 渐变背景方块 + "V" 字母标识
- **技术栈定位**:
  - **前端**: Next.js 15 + React 18 + TypeScript + Tailwind CSS
  - **后端**: Rust + Axum + MySQL + Diesel ORM
  - **专业定位**: 全栈开发者，专注于现代 Web 应用和服务器部署
- **主要行动按钮**: "查看项目" / "联系我"

### 🚀 项目展示策略
- **项目数量**: 当前 3-4 个，支持灵活添加
- **项目类型**: 主要为**部署到服务器的项目**，其他类型预留扩展
- **展示方式**: 无需筛选搜索，体量小巧简洁
- **添加方式**: 通过代码修改实现，一个项目一个增量

### 🧭 导航结构 (已确认)
- **主导航**: 首页 / 项目 / 博客 / 关于 / 联系
- **位置**: 顶部居中对齐
- **子菜单**: 暂不需要，保持简洁
- **样式**: 透明背景 + 渐变科技感效果

---

## 🎨 核心设计规范

### 主题色彩系统

#### 品牌主色调
```css
/* 蓝紫粉渐变主题 */
--primary-gradient: linear-gradient(135deg, #3b82f6 0%, #8b5cf6 50%, #ec4899 100%);
--primary-blue: #3b82f6;      /* 主蓝色 */
--primary-purple: #8b5cf6;    /* 主紫色 */
--primary-pink: #ec4899;      /* 主粉色 */
```

#### 暗色模式配色
```css
:root[data-theme="dark"] {
  /* 背景色系 */
  --bg-primary: #0f0f0f;      /* 主背景 - 极深灰 */
  --bg-secondary: #1e1e1e;    /* 卡片背景 - 深灰 */
  --bg-tertiary: #2a2a2a;     /* 悬停背景 - 中灰 */

  /* 文字色系 */
  --text-primary: #ffffff;     /* 主文字 - 纯白 */
  --text-secondary: #a3a3a3;  /* 辅助文字 - 中灰 */
  --text-muted: #6b7280;      /* 弱化文字 - 浅灰 */

  /* 边框色系 */
  --border-primary: #333333;   /* 主边框 */
  --border-secondary: #404040; /* 辅助边框 */

  /* 品牌渐变色 */
  --accent-gradient: linear-gradient(135deg, #3b82f6 0%, #8b5cf6 50%, #ec4899 100%);
  --accent-blue: #60a5fa;      /* 亮蓝色 */
  --accent-purple: #a78bfa;    /* 亮紫色 */
  --accent-pink: #f472b6;      /* 亮粉色 */
}
```

#### 亮色模式配色
```css
:root[data-theme="light"] {
  /* 背景色系 */
  --bg-primary: #ffffff;       /* 主背景 - 纯白 */
  --bg-secondary: #f8fafc;     /* 卡片背景 - 浅灰 */
  --bg-tertiary: #f1f5f9;      /* 悬停背景 - 更浅灰 */

  /* 文字色系 */
  --text-primary: #1e293b;     /* 主文字 - 深蓝灰 */
  --text-secondary: #64748b;   /* 辅助文字 - 中蓝灰 */
  --text-muted: #94a3b8;       /* 弱化文字 - 浅蓝灰 */

  /* 边框色系 */
  --border-primary: #e2e8f0;   /* 主边框 */
  --border-secondary: #cbd5e1; /* 辅助边框 */

  /* 品牌渐变色 */
  --accent-gradient: linear-gradient(135deg, #2563eb 0%, #7c3aed 50%, #db2777 100%);
  --accent-blue: #2563eb;      /* 深蓝色 */
  --accent-purple: #7c3aed;    /* 深紫色 */
  --accent-pink: #db2777;      /* 深粉色 */
}
```

#### 功能性色彩
```css
/* 状态色彩 - 适配明暗主题 */
--success: #10b981;    /* 成功 - 绿色 */
--warning: #f59e0b;    /* 警告 - 橙色 */
--error: #ef4444;      /* 错误 - 红色 */
--info: #3b82f6;       /* 信息 - 蓝色 */

/* 语义色彩透明度变体 */
--success-bg: rgba(16, 185, 129, 0.1);
--warning-bg: rgba(245, 158, 11, 0.1);
--error-bg: rgba(239, 68, 68, 0.1);
--info-bg: rgba(59, 130, 246, 0.1);
```

### 字体系统

#### 字体族选择
```css
/* 主字体 - 无衬线字体 */
--font-primary: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;

/* 代码字体 - 等宽字体 */
--font-mono: 'JetBrains Mono', 'Fira Code', 'SF Mono', 'Monaco', 'Cascadia Code', monospace;

/* 展示字体 - 现代无衬线 */
--font-display: 'Inter', 'SF Pro Display', -apple-system, sans-serif;
```

#### 字体大小系统
```css
/* 字体大小 - 流体响应式 */
--text-xs: 0.75rem;    /* 12px - 辅助信息 */
--text-sm: 0.875rem;   /* 14px - 小文字 */
--text-base: 1rem;     /* 16px - 正文 */
--text-lg: 1.125rem;   /* 18px - 大正文 */
--text-xl: 1.25rem;    /* 20px - 小标题 */
--text-2xl: 1.5rem;    /* 24px - 中标题 */
--text-3xl: 1.875rem;  /* 30px - 大标题 */
--text-4xl: 2.25rem;   /* 36px - 超大标题 */
--text-5xl: 3rem;      /* 48px - 巨大标题 */
--text-6xl: 3.75rem;   /* 60px - 展示标题 */

/* 响应式流体字体 */
--text-fluid-sm: clamp(0.875rem, 2.5vw, 1rem);
--text-fluid-base: clamp(1rem, 2.5vw, 1.125rem);
--text-fluid-lg: clamp(1.125rem, 3vw, 1.5rem);
--text-fluid-xl: clamp(1.5rem, 4vw, 2.25rem);
--text-fluid-2xl: clamp(2.25rem, 5vw, 3.75rem);
```

#### 字重系统
```css
--font-light: 300;     /* 细体 - 装饰性文字 */
--font-normal: 400;    /* 常规 - 正文 */
--font-medium: 500;    /* 中等 - 重要文字 */
--font-semibold: 600;  /* 半粗 - 小标题 */
--font-bold: 700;      /* 粗体 - 标题 */
--font-extrabold: 800; /* 超粗 - 展示标题 */
```

### 视觉层级系统

#### 圆角系统
```css
--radius-xs: 0.25rem;  /* 4px - 小元素 */
--radius-sm: 0.375rem; /* 6px - 按钮、输入框 */
--radius-base: 0.5rem; /* 8px - 卡片 */
--radius-lg: 0.75rem;  /* 12px - 大卡片 */
--radius-xl: 1rem;     /* 16px - 容器 */
--radius-2xl: 1.5rem;  /* 24px - 特殊容器 */
--radius-full: 9999px; /* 圆形 */
```

#### 阴影系统
```css
/* 阴影层级 - 适配明暗主题 */
--shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.05);
--shadow-base: 0 1px 3px rgba(0, 0, 0, 0.1), 0 1px 2px rgba(0, 0, 0, 0.06);
--shadow-md: 0 4px 6px rgba(0, 0, 0, 0.07), 0 2px 4px rgba(0, 0, 0, 0.06);
--shadow-lg: 0 10px 15px rgba(0, 0, 0, 0.1), 0 4px 6px rgba(0, 0, 0, 0.05);
--shadow-xl: 0 20px 25px rgba(0, 0, 0, 0.1), 0 10px 10px rgba(0, 0, 0, 0.04);
--shadow-2xl: 0 25px 50px rgba(0, 0, 0, 0.25);

/* 彩色阴影 - 品牌色 */
--shadow-blue: 0 8px 30px rgba(59, 130, 246, 0.12);
--shadow-purple: 0 8px 30px rgba(139, 92, 246, 0.12);
--shadow-pink: 0 8px 30px rgba(236, 72, 153, 0.12);
--shadow-gradient: 0 8px 30px rgba(59, 130, 246, 0.12), 0 12px 40px rgba(139, 92, 246, 0.08);
```

#### 间距系统
```css
/* 间距系统 - 8px 基准 */
--space-1: 0.25rem;   /* 4px */
--space-2: 0.5rem;    /* 8px */
--space-3: 0.75rem;   /* 12px */
--space-4: 1rem;      /* 16px */
--space-5: 1.25rem;   /* 20px */
--space-6: 1.5rem;    /* 24px */
--space-8: 2rem;      /* 32px */
--space-10: 2.5rem;   /* 40px */
--space-12: 3rem;     /* 48px */
--space-16: 4rem;     /* 64px */
--space-20: 5rem;     /* 80px */
--space-24: 6rem;     /* 96px */
```

### 动画系统

#### 缓动函数
```css
--ease-linear: linear;
--ease-in: cubic-bezier(0.4, 0, 1, 1);
--ease-out: cubic-bezier(0, 0, 0.2, 1);
--ease-in-out: cubic-bezier(0.4, 0, 0.2, 1);
--ease-back: cubic-bezier(0.68, -0.55, 0.265, 1.55);
--ease-bounce: cubic-bezier(0.68, -0.55, 0.265, 1.55);
```

#### 动画持续时间
```css
--duration-fast: 150ms;     /* 快速交互 */
--duration-normal: 250ms;   /* 常规过渡 */
--duration-slow: 400ms;     /* 慢速动画 */
--duration-slower: 600ms;   /* 页面转场 */
```

---

## � 交互效果规范 (Vercel 风格)

### 核心交互特色
基于用户选择的 **Vercel 风格 - 大屏中心式布局**，以下交互效果已确定并经过测试验证：

#### 1. 渐变边框效果 ⭐
```css
/* 悬停时显示彩色边框 */
.gradient-border {
  position: relative;
  border: 1px solid var(--border-primary);
  transition: all 0.3s ease;
}

.gradient-border:hover {
  border-color: transparent;
}

.gradient-border:hover::before {
  content: '';
  position: absolute;
  inset: 0;
  padding: 1px;
  background: linear-gradient(135deg, #3b82f6 0%, #8b5cf6 50%, #ec4899 100%);
  border-radius: inherit;
  mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
  mask-composite: xor;
  -webkit-mask-composite: xor;
}
```

#### 2. 发光阴影效果 ✨
```css
/* 科技感光晕效果 */
.glow-effect {
  transition: box-shadow 0.3s ease;
}

.glow-effect:hover {
  box-shadow:
    0 0 20px rgba(59, 130, 246, 0.3),
    0 0 40px rgba(139, 92, 246, 0.2),
    0 0 60px rgba(236, 72, 153, 0.1);
}
```

#### 3. 平滑动画过渡 🎯
```css
/* 300ms 标准过渡动画 */
.smooth-transition {
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

/* 快速反馈动画 */
.quick-feedback {
  transition: transform 0.15s ease;
}
```

#### 4. 悬停提升效果 🚀
```css
/* translateY(-4px) 标准提升 */
.hover-lift {
  transition: transform 0.3s ease, box-shadow 0.3s ease;
}

.hover-lift:hover {
  transform: translateY(-4px);
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
}

/* 卡片专用提升效果 */
.card-lift:hover {
  transform: translateY(-4px) scale(1.02);
}
```

### 交互层次设计
1. **微交互** (100-200ms): 按钮反馈、输入框聚焦
2. **标准交互** (300ms): 卡片悬停、边框变化
3. **页面动画** (400-600ms): 页面切换、内容加载

---

## �🎯 核心设计原则

### 1. 科技感优先
- 使用渐变色彩营造未来感
- 深色主题为主，突出专业性
- 微妙的发光和阴影效果
- 现代化的几何形状

### 2. 功能导向
- 信息层级清晰明确
- 交互反馈及时准确
- 内容为王，装饰适度
- 响应式优先设计

### 3. 视觉一致性
- 统一的色彩语言
- 一致的间距节奏
- 规范的组件样式
- 协调的动画效果

### 4. 性能友好
- 合理使用动画效果
- 优化图像和字体加载
- 响应式图片处理
- 代码分割和懒加载

---

## 🚀 技术实现要求

### CSS 架构
```css
/* 使用 CSS 自定义属性实现主题切换 */
:root {
  color-scheme: dark; /* 浏览器原生暗色模式支持 */
}

/* 主题切换动画 */
* {
  transition: background-color var(--duration-normal) var(--ease-out),
              color var(--duration-normal) var(--ease-out),
              border-color var(--duration-normal) var(--ease-out);
}
```

### 组件设计规范
```tsx
// 示例：统一的组件样式规范
const ComponentBase = {
  // 基础样式
  base: "rounded-base border border-primary bg-secondary",

  // 尺寸变体
  sizes: {
    sm: "p-3 text-sm",
    md: "p-4 text-base",
    lg: "p-6 text-lg"
  },

  // 颜色变体
  variants: {
    primary: "bg-gradient-to-r from-blue-500 to-purple-600 text-white",
    secondary: "bg-secondary text-primary border-primary",
    accent: "bg-pink-500 text-white"
  }
};
```

### 响应式断点
```css
/* 移动端优先的响应式设计 */
--breakpoint-sm: 640px;   /* 小屏手机 */
--breakpoint-md: 768px;   /* 平板 */
--breakpoint-lg: 1024px;  /* 笔记本 */
--breakpoint-xl: 1280px;  /* 桌面 */
--breakpoint-2xl: 1536px; /* 大屏桌面 */
```

---

## 📖 使用指南

### 快速上手
1. 复制色彩系统变量到项目中
2. 应用字体系统设置
3. 实现主题切换功能
4. 按照设计原则创建组件

### 最佳实践
- 优先使用 CSS 变量而非硬编码颜色
- 保持动画效果的一致性
- 遵循无障碍访问标准
- 定期检查颜色对比度

### 质量检查
- [ ] 色彩对比度符合 WCAG AA 标准
- [ ] 支持系统级暗色模式偏好
- [ ] 动画效果支持用户减少动效偏好
- [ ] 响应式设计在各设备正常显示
- [ ] 字体加载优化和回退设置

---

**风格定位**: 渐变科技风格
**主题色彩**: 蓝紫粉渐变系统
**字体选择**: Inter 无衬线字体系
**创建时间**: 2025年8月11日
**状态**: ✅ 已确定

这套设计系统将为 PortfolioPulse 项目提供统一、现代、专业的视觉体验。
