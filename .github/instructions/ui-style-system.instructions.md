---
applyTo: "frontend/**/*,components/**/*,app/**/*,styles/**/*"
---

# UI 风格系统指引 - 渐变科技风格

## 设计风格定位

**选定风格**: 渐变科技风格（Gradient Tech）
**参考标杆**: Vercel、Stripe
**布局模式**: Vercel 风格 - 大屏中心式布局
**适用场景**: 个人技术项目展示平台、开发者作品集

## 核心色彩系统

### 品牌主色调

```css
/* 蓝紫粉渐变主题 */
--primary-gradient: linear-gradient(
  135deg,
  #3b82f6 0%,
  #8b5cf6 50%,
  #ec4899 100%
);
--primary-blue: #3b82f6; /* 主蓝色 */
--primary-purple: #8b5cf6; /* 主紫色 */
--primary-pink: #ec4899; /* 主粉色 */
```

### 暗色模式配色（主要）

```css
:root[data-theme="dark"] {
  /* 背景色系 */
  --bg-primary: #0f0f0f; /* 主背景 - 极深灰 */
  --bg-secondary: #1e1e1e; /* 卡片背景 - 深灰 */
  --bg-tertiary: #2a2a2a; /* 悬停背景 - 中灰 */

  /* 文字色系 */
  --text-primary: #ffffff; /* 主文字 - 纯白 */
  --text-secondary: #a3a3a3; /* 辅助文字 - 中灰 */
  --text-muted: #6b7280; /* 弱化文字 - 浅灰 */
}
```

## 交互效果规范

### 核心交互特色（已确定）

#### 1. 渐变边框效果 ⭐

```css
.gradient-border:hover::before {
  content: "";
  position: absolute;
  inset: 0;
  padding: 1px;
  background: linear-gradient(135deg, #3b82f6 0%, #8b5cf6 50%, #ec4899 100%);
  border-radius: inherit;
  mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
  mask-composite: xor;
}
```

#### 2. 标准悬停效果

- `translateY(-4px)` 标准提升
- 300ms 过渡动画
- 发光阴影效果

## 字体系统

### 主字体

```css
--font-primary: "Inter", -apple-system, BlinkMacSystemFont, "Segoe UI", "Roboto",
  sans-serif;
--font-mono: "JetBrains Mono", "Fira Code", monospace;
```

### 字体大小

```css
--text-xs: 0.75rem; /* 12px */
--text-sm: 0.875rem; /* 14px */
--text-base: 1rem; /* 16px */
--text-lg: 1.125rem; /* 18px */
--text-xl: 1.25rem; /* 20px */
```

## 组件设计原则

1. **科技感优先**: 使用渐变色彩营造未来感
2. **功能导向**: 信息层级清晰明确
3. **视觉一致性**: 统一的色彩语言和间距节奏
4. **性能友好**: 合理使用动画效果

## 布局特色

- **极简主义设计**: 大量留白空间，内容居中对齐
- **全屏 Hero Section**: 突出个人品牌和核心信息
- **卡片式展示**: 项目以 3 列网格形式展示
- **响应式设计**: 完美适配各种屏幕尺寸

## 个人品牌元素

### Hero Section 内容策略

- **个人品牌 Slogan**: 渐变背景方块 + "V" 字母标识
- **技术栈定位**: 全栈开发者，专注现代 Web 应用和服务器部署
- **主要行动按钮**: "查看项目" / "联系我"

### 导航结构

- **主导航**: 首页 / 项目 / 博客 / 关于 / 联系
- **位置**: 顶部居中对齐
- **样式**: 透明背景 + 渐变科技感效果

使用这些设计规范时，请确保：

- 优先使用 CSS 变量而非硬编码颜色
- 保持动画效果的一致性 (300ms)
- 遵循无障碍访问标准
- 色彩对比度符合 WCAG AA 标准
