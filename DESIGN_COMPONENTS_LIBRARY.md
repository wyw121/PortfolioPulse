# 设计组件库与风格指南

## 概述

本文档收集了业内顶尖科技公司的设计组件和创意，为 PortfolioPulse 项目提供设计参考和实现指导。

---

## 一、Hero Section 设计模式

### 1. OpenAI 风格 - 极简文字驱动
```tsx
const OpenAIHero = () => (
  <section className="min-h-screen flex items-center justify-center bg-black text-white">
    <div className="max-w-4xl mx-auto text-center px-6">
      <h1 className="text-6xl md:text-8xl font-bold mb-6 bg-gradient-to-r from-white to-gray-400 bg-clip-text text-transparent">
        GPT-5 简介
      </h1>
      <p className="text-xl md:text-2xl text-gray-300 mb-8 max-w-3xl mx-auto leading-relaxed">
        我们迄今最聪明、最快速、最实用的模型，内置推理能力，让专家级智能触手可及。
      </p>
      <button className="bg-white text-black px-8 py-4 rounded-lg font-medium hover:bg-gray-100 transition-colors">
        了解更多
      </button>
    </div>
  </section>
);
```

### 2. Stripe 风格 - 功能导向
```tsx
const StripeHero = () => (
  <section className="bg-gradient-to-br from-purple-900 via-blue-900 to-indigo-900 text-white">
    <div className="max-w-6xl mx-auto px-6 py-20">
      <div className="grid md:grid-cols-2 gap-12 items-center">
        <div>
          <h1 className="text-5xl font-bold mb-6">
            金融新基建，<br />增长强引擎
          </h1>
          <p className="text-xl text-blue-100 mb-8">
            加入数以百万计公司的行列，使用 Stripe 接受线上和线下付款，嵌入金融服务
          </p>
          <div className="flex gap-4">
            <button className="bg-white text-purple-900 px-6 py-3 rounded-md font-medium">
              立即开始
            </button>
            <button className="border border-white text-white px-6 py-3 rounded-md font-medium">
              联系销售
            </button>
          </div>
        </div>
        <div className="bg-white/10 backdrop-blur-sm rounded-2xl p-6">
          {/* 仪表盘模拟 */}
          <div className="text-sm text-blue-100 mb-4">今天净收入额</div>
          <div className="text-3xl font-bold mb-6">$3,528,198.72</div>
          <div className="space-y-3">
            <div className="h-2 bg-blue-500 rounded-full"></div>
            <div className="h-2 bg-green-500 rounded-full w-3/4"></div>
            <div className="h-2 bg-yellow-500 rounded-full w-1/2"></div>
          </div>
        </div>
      </div>
    </div>
  </section>
);
```

### 3. Linear 风格 - 产品展示
```tsx
const LinearHero = () => (
  <section className="bg-black text-white">
    <div className="max-w-6xl mx-auto px-6 py-20">
      <div className="text-center mb-16">
        <h1 className="text-6xl font-bold mb-6 leading-tight">
          Linear is a purpose-built tool<br />
          for planning and building products
        </h1>
        <p className="text-xl text-gray-400 mb-8 max-w-3xl mx-auto">
          Meet the system for modern software development. Streamline issues, projects, and product roadmaps.
        </p>
        <button className="bg-blue-600 text-white px-8 py-4 rounded-lg font-medium hover:bg-blue-700 transition-colors">
          Start building
        </button>
      </div>

      {/* 产品截图 */}
      <div className="relative">
        <div className="bg-gradient-to-r from-blue-500/20 to-purple-500/20 rounded-2xl p-1">
          <div className="bg-gray-900 rounded-xl p-6">
            <div className="flex items-center gap-2 mb-4">
              <div className="w-3 h-3 bg-red-500 rounded-full"></div>
              <div className="w-3 h-3 bg-yellow-500 rounded-full"></div>
              <div className="w-3 h-3 bg-green-500 rounded-full"></div>
            </div>
            <div className="space-y-2">
              <div className="h-4 bg-gray-700 rounded w-3/4"></div>
              <div className="h-4 bg-gray-700 rounded w-1/2"></div>
              <div className="h-4 bg-gray-700 rounded w-5/6"></div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>
);
```

---

## 二、卡片设计模式

### 1. 项目卡片 - Figma 风格
```tsx
const ProjectCard = ({ project }) => (
  <motion.div
    className="bg-white rounded-2xl shadow-lg hover:shadow-xl transition-all duration-300 overflow-hidden group"
    whileHover={{ y: -8 }}
  >
    <div className="relative">
      <img
        src={project.image}
        alt={project.title}
        className="w-full h-48 object-cover group-hover:scale-105 transition-transform duration-500"
      />
      <div className="absolute top-4 right-4">
        <div className="bg-white/90 backdrop-blur-sm px-3 py-1 rounded-full text-sm font-medium">
          {project.status}
        </div>
      </div>
    </div>

    <div className="p-6">
      <div className="flex items-start justify-between mb-3">
        <h3 className="text-xl font-bold text-gray-900">{project.title}</h3>
        <ExternalLinkIcon className="w-5 h-5 text-gray-400 group-hover:text-blue-600 transition-colors" />
      </div>

      <p className="text-gray-600 text-sm mb-4 line-clamp-2">
        {project.description}
      </p>

      <div className="flex flex-wrap gap-2 mb-4">
        {project.tags.map(tag => (
          <span key={tag} className="bg-blue-50 text-blue-600 px-2 py-1 rounded-md text-xs font-medium">
            {tag}
          </span>
        ))}
      </div>

      <div className="flex items-center justify-between text-sm text-gray-500">
        <div className="flex items-center gap-2">
          <GitCommitIcon className="w-4 h-4" />
          <span>{project.commits} commits</span>
        </div>
        <span>{project.lastUpdate}</span>
      </div>
    </div>
  </motion.div>
);
```

### 2. 统计卡片 - Vercel 风格
```tsx
const StatCard = ({ title, value, change, icon: Icon }) => (
  <div className="bg-black text-white rounded-xl p-6 border border-gray-800 hover:border-gray-600 transition-all duration-200">
    <div className="flex items-center justify-between mb-4">
      <div className="p-2 bg-gray-800 rounded-lg">
        <Icon className="w-5 h-5 text-gray-300" />
      </div>
      {change && (
        <div className={`text-xs px-2 py-1 rounded-full ${
          change > 0 ? 'bg-green-500/20 text-green-400' : 'bg-red-500/20 text-red-400'
        }`}>
          {change > 0 ? '+' : ''}{change}%
        </div>
      )}
    </div>

    <div className="space-y-1">
      <h3 className="text-2xl font-bold">{value}</h3>
      <p className="text-gray-400 text-sm">{title}</p>
    </div>
  </div>
);
```

### 3. 博客卡片 - Tailwind CSS 风格
```tsx
const BlogCard = ({ post }) => (
  <article className="bg-white rounded-2xl shadow-md hover:shadow-lg transition-shadow duration-300 overflow-hidden">
    <div className="aspect-video bg-gradient-to-br from-blue-400 to-purple-600 p-6 flex items-center justify-center">
      <h2 className="text-2xl font-bold text-white text-center">{post.title}</h2>
    </div>

    <div className="p-6">
      <div className="flex items-center gap-3 mb-4">
        <img
          src={post.author.avatar}
          alt={post.author.name}
          className="w-8 h-8 rounded-full"
        />
        <div className="text-sm">
          <div className="font-medium text-gray-900">{post.author.name}</div>
          <div className="text-gray-500">{post.date}</div>
        </div>
      </div>

      <p className="text-gray-600 text-sm leading-relaxed mb-4">
        {post.excerpt}
      </p>

      <div className="flex items-center justify-between">
        <div className="flex gap-2">
          {post.categories.map(category => (
            <span key={category} className="bg-gray-100 text-gray-700 px-2 py-1 rounded-md text-xs">
              {category}
            </span>
          ))}
        </div>
        <div className="text-sm text-gray-500">{post.readTime} min read</div>
      </div>
    </div>
  </article>
);
```

---

## 三、导航设计模式

### 1. Anthropic 风格 - 极简导航
```tsx
const AnthropicNavigation = () => (
  <header className="bg-white border-b border-gray-200 sticky top-0 z-50 backdrop-blur-sm bg-white/95">
    <nav className="max-w-6xl mx-auto px-6 py-4">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-8">
          <Link href="/" className="text-2xl font-bold text-gray-900">
            Anthropic
          </Link>
          <div className="hidden md:flex items-center gap-6">
            <Link href="/research" className="text-gray-600 hover:text-gray-900 transition-colors">
              Research
            </Link>
            <Link href="/safety" className="text-gray-600 hover:text-gray-900 transition-colors">
              Safety
            </Link>
            <Link href="/company" className="text-gray-600 hover:text-gray-900 transition-colors">
              Company
            </Link>
          </div>
        </div>

        <div className="flex items-center gap-4">
          <button className="bg-black text-white px-4 py-2 rounded-lg font-medium hover:bg-gray-800 transition-colors">
            Talk to Claude
          </button>
        </div>
      </div>
    </nav>
  </header>
);
```

### 2. Linear 风格 - 带搜索的导航
```tsx
const LinearNavigation = () => (
  <header className="bg-black text-white border-b border-gray-800">
    <nav className="max-w-7xl mx-auto px-6 py-4">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-8">
          <Link href="/" className="flex items-center gap-2">
            <LinearIcon className="w-8 h-8" />
            <span className="text-xl font-bold">Linear</span>
          </Link>

          <div className="hidden lg:flex items-center gap-6">
            <DropdownMenu label="Product">
              <DropdownItem href="/features">Features</DropdownItem>
              <DropdownItem href="/method">Method</DropdownItem>
              <DropdownItem href="/customers">Customers</DropdownItem>
            </DropdownMenu>
            <Link href="/pricing" className="text-gray-300 hover:text-white transition-colors">
              Pricing
            </Link>
            <Link href="/company" className="text-gray-300 hover:text-white transition-colors">
              Company
            </Link>
          </div>
        </div>

        <div className="flex items-center gap-4">
          <div className="relative hidden md:block">
            <SearchIcon className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-gray-400" />
            <input
              type="text"
              placeholder="Search..."
              className="bg-gray-800 text-white pl-10 pr-4 py-2 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-600"
            />
          </div>
          <button className="bg-blue-600 text-white px-4 py-2 rounded-lg font-medium hover:bg-blue-700 transition-colors">
            Start building
          </button>
        </div>
      </div>
    </nav>
  </header>
);
```

---

## 四、交互动效设计

### 1. 悬停动效
```css
/* Figma 风格的卡片悬停 */
.figma-card {
  @apply transition-all duration-300 transform;
}

.figma-card:hover {
  @apply -translate-y-2 shadow-2xl;
}

/* Stripe 风格的按钮悬停 */
.stripe-button {
  @apply relative overflow-hidden transition-all duration-200;
}

.stripe-button:hover::before {
  @apply absolute inset-0 bg-gradient-to-r from-purple-600 to-blue-600 opacity-10;
  content: '';
}

/* Linear 风格的输入框聚焦 */
.linear-input:focus {
  @apply ring-2 ring-blue-500 ring-opacity-50 border-blue-500;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}
```

### 2. 页面过渡动效
```tsx
// Framer Motion 页面过渡
const PageTransition = ({ children }) => (
  <motion.div
    initial={{ opacity: 0, y: 20 }}
    animate={{ opacity: 1, y: 0 }}
    exit={{ opacity: 0, y: -20 }}
    transition={{
      duration: 0.3,
      ease: [0.25, 0.46, 0.45, 0.94]
    }}
  >
    {children}
  </motion.div>
);

// 滚动触发动画
const ScrollAnimation = ({ children }) => {
  const [ref, inView] = useInView({
    triggerOnce: true,
    threshold: 0.1,
  });

  return (
    <motion.div
      ref={ref}
      initial={{ opacity: 0, y: 50 }}
      animate={inView ? { opacity: 1, y: 0 } : { opacity: 0, y: 50 }}
      transition={{ duration: 0.6, ease: "easeOut" }}
    >
      {children}
    </motion.div>
  );
};
```

---

## 五、色彩系统设计

### 1. 深色主题配色
```css
:root {
  /* OpenAI 风格 */
  --openai-bg: #0a0a0a;
  --openai-surface: #1a1a1a;
  --openai-primary: #10a37f;
  --openai-text: #ffffff;
  --openai-text-muted: #a3a3a3;

  /* Vercel 风格 */
  --vercel-bg: #000000;
  --vercel-surface: #111111;
  --vercel-primary: #0070f3;
  --vercel-text: #ffffff;
  --vercel-text-muted: #888888;

  /* Linear 风格 */
  --linear-bg: #0c0c0c;
  --linear-surface: #181818;
  --linear-primary: #5e6ad2;
  --linear-text: #ffffff;
  --linear-text-muted: #94a3b8;
}
```

### 2. 渐变色系统
```css
/* 现代渐变背景 */
.gradient-bg-1 {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.gradient-bg-2 {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
}

.gradient-bg-3 {
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
}

/* 文字渐变 */
.gradient-text {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}
```

---

## 六、响应式设计模式

### 1. 容器查询
```css
/* Linear 风格的容器查询 */
.project-grid {
  container-type: inline-size;
  display: grid;
  gap: 1rem;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
}

@container (min-width: 768px) {
  .project-card {
    display: grid;
    grid-template-columns: 200px 1fr;
    gap: 1rem;
  }
}
```

### 2. 流体字体大小
```css
/* Tailwind 风格的流体字体 */
.fluid-text {
  font-size: clamp(1.5rem, 4vw, 3rem);
  line-height: clamp(1.2, 1.5, 1.4);
}
```

---

## 七、为 PortfolioPulse 的建议

### 推荐组件组合
1. **Hero Section**: Linear + Stripe 混合风格
2. **项目卡片**: Figma 风格的悬停效果
3. **导航**: Anthropic 简洁风格
4. **统计面板**: Vercel 深色风格
5. **颜色系统**: OpenAI 绿色主题

### 实施优先级
1. 建立基础色彩系统
2. 实现核心组件（按钮、卡片、输入框）
3. 添加动画效果
4. 优化响应式布局
5. 完善交互细节

这些设计模式和组件可以直接应用到 PortfolioPulse 项目中，通过组合和定制来创建独特而专业的用户界面。
