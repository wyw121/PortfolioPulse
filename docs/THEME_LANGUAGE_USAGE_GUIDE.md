# 主题和语言切换功能 - 使用指南

> 实现时间: 2025-01-24
> 参考设计: BriceLucifer.github.io

---

## ✨ 新功能概览

### 1. **主题切换** (优化版)
- 🎨 简洁圆形按钮设计 (参考目标网站)
- 🌓 支持亮色/暗色模式
- 💾 LocalStorage 持久化
- 🔄 平滑动画过渡

### 2. **语言切换** (新功能)
- 🌍 支持中文/英文切换
- 📱 移动端友好设计
- 💾 语言偏好保存
- 🎯 下拉菜单选择

### 3. **布局优化**
- 📍 按钮位置: Logo 右侧
- 📏 分隔线设计
- 📱 响应式适配
- ✨ 统一视觉风格

---

## 📦 新增文件

### 国际化基础
```
frontend/
├── locales/
│   ├── en.json              # 英文翻译
│   └── zh.json              # 中文翻译
├── lib/
│   └── i18n.ts              # i18n 工具函数
└── hooks/
    └── use-translation.ts   # 翻译 Hook
```

### 组件文件
```
frontend/components/
├── language-switcher.tsx    # 语言切换组件
├── theme-toggle.tsx         # 主题切换组件 (优化)
└── ui/
    └── dropdown-menu.tsx    # 下拉菜单组件
```

---

## 🎯 核心特性

### 按钮设计特点

参考 BriceLucifer.github.io 的按钮风格:

1. **圆形按钮** (h-9 w-9)
2. **幽灵按钮样式** (variant="ghost")
3. **悬停效果**:
   - 背景色变化
   - 轻微缩放 (scale 1.05)
4. **点击反馈**:
   - 缩小动画 (scale 0.95)
5. **图标大小**: 1.1rem

### 移动端优化

- ✅ 最小触摸目标: 44x44px
- ✅ Logo 文字在小屏幕隐藏
- ✅ 按钮间距优化
- ✅ 响应式布局

---

## 🚀 使用方法

### 在任何组件中使用翻译

```tsx
import { useTranslation } from '@/hooks/use-translation'

export function MyComponent() {
  const { dict, locale } = useTranslation()
  
  return (
    <div>
      <h1>{dict.nav.home}</h1>
      <p>当前语言: {locale}</p>
    </div>
  )
}
```

### 添加新的翻译

1. 编辑 `locales/zh.json`:
```json
{
  "mySection": {
    "title": "我的标题",
    "description": "描述"
  }
}
```

2. 编辑 `locales/en.json`:
```json
{
  "mySection": {
    "title": "My Title",
    "description": "Description"
  }
}
```

3. 在组件中使用:
```tsx
const { dict } = useTranslation()
<h1>{dict.mySection.title}</h1>
```

---

## 🎨 样式定制

### 按钮颜色

在 `globals.css` 中已定义:

```css
.theme-toggle,
.language-switcher {
  /* 圆形按钮基础样式 */
  transition: all 0.2s ease-in-out;
}

.theme-toggle:hover,
.language-switcher:hover {
  transform: scale(1.05);
}
```

### 移动端样式

```css
@media (max-width: 768px) {
  .theme-toggle,
  .language-switcher {
    height: 44px;
    width: 44px;
  }
}
```

---

## 📊 当前支持的语言

- 🇨🇳 中文 (zh) - 默认
- 🇺🇸 English (en)

### 添加新语言

1. 创建 `locales/ja.json` (日语示例)
2. 更新 `lib/i18n.ts`:
```typescript
export type Locale = 'en' | 'zh' | 'ja'

export const localeNames: Record<Locale, string> = {
  en: 'English',
  zh: '中文',
  ja: '日本語',
}
```

---

## 🔧 配置选项

### 默认语言

在 `lib/i18n.ts` 中修改:

```typescript
export function getPreferredLocale(): Locale {
  // 修改默认语言
  return 'en' // 改为英文默认
}
```

### 语言检测优先级

1. LocalStorage 保存的语言
2. 浏览器语言偏好
3. 默认语言 (中文)

---

## ✅ 测试清单

- [x] 主题切换正常工作
- [x] 语言切换正常工作
- [x] LocalStorage 持久化
- [x] 移动端按钮可点击
- [x] 桌面端悬停效果
- [x] 导航栏文字自动更新
- [x] 无 TypeScript 错误
- [x] 无控制台警告

---

## 🎯 下一步优化建议

### 短期 (可选)

1. **添加更多语言**: 日语、韩语等
2. **语言切换动画**: 添加淡入淡出效果
3. **系统主题模式**: 添加 "跟随系统" 选项
4. **移动端菜单**: 汉堡菜单整合

### 长期 (可选)

1. **动态路由**: `/en/projects`, `/zh/projects`
2. **SEO 优化**: hreflang 标签
3. **内容翻译**: 博客文章多语言
4. **RTL 支持**: 阿拉伯语等从右到左语言

---

## 🐛 故障排查

### 问题: 语言切换后页面没有更新

**解决方案**: 确保使用 `useTranslation` Hook

```tsx
// ❌ 错误
import { getDictionary } from '@/lib/i18n'
const dict = getDictionary('zh') // 静态,不会更新

// ✅ 正确
import { useTranslation } from '@/hooks/use-translation'
const { dict } = useTranslation() // 响应式,自动更新
```

### 问题: 主题闪烁

**检查**: `app/layout.tsx` 中是否有内联脚本

### 问题: 移动端按钮太小

**检查**: CSS 中是否应用了 `min-height: 44px`

---

## 📚 相关文档

- [完整研究报告](./THEME_AND_LANGUAGE_IMPLEMENTATION_GUIDE.md)
- [Next.js i18n](https://nextjs.org/docs/app/building-your-application/routing/internationalization)
- [Radix UI Dropdown](https://www.radix-ui.com/primitives/docs/components/dropdown-menu)

---

**实现完成时间**: 2025-01-24  
**功能状态**: ✅ 生产就绪  
**技术栈**: Next.js 15 + TypeScript + Tailwind CSS + Radix UI
