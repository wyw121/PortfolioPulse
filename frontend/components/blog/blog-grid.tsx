"use client";

import { AnimatedContainer } from "@/components/ui/effects";
import { motion } from "framer-motion";
import Link from "next/link";

// 博客文章类型定义
interface BlogPost {
  id: string;
  title: string;
  excerpt: string;
  date: string;
  category: string;
  tags: string[];
  readTime: string;
  featured: boolean;
}

// 模拟博客数据
const blogPosts = [
  {
    id: "1",
    title: "Next.js 15 新特性深度解析",
    excerpt:
      "探索Next.js 15带来的革命性变化，包括新的App Router、Server Components等核心功能的深度分析。",
    date: "2025-01-15",
    category: "前端开发",
    tags: ["Next.js", "React", "TypeScript"],
    readTime: "8分钟阅读",
    featured: true,
  },
  {
    id: "2",
    title: "Rust异步编程实战指南",
    excerpt: "从tokio到async/await，全面掌握Rust异步编程的核心概念和最佳实践。",
    date: "2025-01-10",
    category: "后端开发",
    tags: ["Rust", "异步编程", "Tokio"],
    readTime: "12分钟阅读",
    featured: true,
  },
  {
    id: "3",
    title: "现代前端架构设计思考",
    excerpt: "从单体应用到微前端，探讨现代前端架构的演进路径和设计原则。",
    date: "2025-01-05",
    category: "架构设计",
    tags: ["架构", "微前端", "设计模式"],
    readTime: "10分钟阅读",
    featured: false,
  },
  {
    id: "4",
    title: "TypeScript高级类型系统深入",
    excerpt: "深入理解TypeScript的高级类型系统，提升代码质量和开发效率。",
    date: "2024-12-28",
    category: "编程语言",
    tags: ["TypeScript", "类型系统", "编程技巧"],
    readTime: "15分钟阅读",
    featured: false,
  },
  {
    id: "5",
    title: "性能优化实践：从理论到实战",
    excerpt: "结合实际项目经验，分享Web应用性能优化的策略和技巧。",
    date: "2024-12-20",
    category: "性能优化",
    tags: ["性能优化", "Web性能", "最佳实践"],
    readTime: "18分钟阅读",
    featured: false,
  },
  {
    id: "6",
    title: "开源项目贡献指南",
    excerpt: "如何参与开源项目，从提交PR到成为维护者的完整路径。",
    date: "2024-12-15",
    category: "开源文化",
    tags: ["开源", "GitHub", "社区贡献"],
    readTime: "6分钟阅读",
    featured: false,
  },
];

// 分类统计
const categories = [
  "全部",
  "前端开发",
  "后端开发",
  "架构设计",
  "编程语言",
  "性能优化",
  "开源文化",
];

export function BlogGrid() {
  return (
    <div className="max-w-6xl mx-auto px-6 pb-20">
      {/* 特色文章 */}
      <AnimatedContainer direction="up" duration={600} delay={200}>
        <div className="mb-16">
          <h2 className="text-2xl font-bold mb-8 text-gray-900 dark:text-white">
            特色文章
          </h2>
          <div className="grid md:grid-cols-2 gap-8">
            {blogPosts
              .filter((post) => post.featured)
              .map((post, index) => (
                <motion.div
                  key={post.id}
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: index * 0.1 }}
                >
                  <FeaturedBlogCard post={post} />
                </motion.div>
              ))}
          </div>
        </div>
      </AnimatedContainer>

      {/* 分类过滤 */}
      <AnimatedContainer direction="up" duration={600} delay={400}>
        <div className="mb-8">
          <div className="flex flex-wrap gap-3 justify-center">
            {categories.map((category) => (
              <button
                key={category}
                className="px-4 py-2 rounded-full text-sm font-medium transition-all duration-200
                         bg-gray-100 hover:bg-gray-200 dark:bg-gray-800 dark:hover:bg-gray-700
                         text-gray-700 dark:text-gray-300"
              >
                {category}
              </button>
            ))}
          </div>
        </div>
      </AnimatedContainer>

      {/* 全部文章 */}
      <AnimatedContainer direction="up" duration={600} delay={600}>
        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
          {blogPosts.map((post, index) => (
            <motion.div
              key={post.id}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.8 + index * 0.1 }}
            >
              <BlogCard post={post} />
            </motion.div>
          ))}
        </div>
      </AnimatedContainer>
    </div>
  );
}

function FeaturedBlogCard({ post }: { post: BlogPost }) {
  return (
    <Link href={`/blog/${post.id}`}>
      <div className="group cursor-pointer">
        <div className="relative overflow-hidden rounded-2xl bg-gradient-to-br from-blue-50 to-purple-50 dark:from-gray-800 dark:to-gray-900 p-8 h-full">
          {/* 背景装饰 */}
          <div className="absolute inset-0 bg-gradient-to-br from-blue-500/10 to-purple-500/10 group-hover:from-blue-500/20 group-hover:to-purple-500/20 transition-all duration-300" />

          <div className="relative z-10">
            <div className="flex items-center justify-between mb-4">
              <span className="px-3 py-1 rounded-full text-xs font-medium bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-300">
                {post.category}
              </span>
              <span className="text-sm text-gray-500 dark:text-gray-400">
                {post.readTime}
              </span>
            </div>

            <h3 className="text-xl font-bold mb-3 group-hover:text-blue-600 dark:group-hover:text-blue-400 transition-colors duration-200">
              {post.title}
            </h3>

            <p className="text-gray-600 dark:text-gray-300 mb-4 line-clamp-3">
              {post.excerpt}
            </p>

            <div className="flex items-center justify-between">
              <time className="text-sm text-gray-500 dark:text-gray-400">
                {post.date}
              </time>
              <div className="flex flex-wrap gap-2">
                {post.tags.slice(0, 2).map((tag: string) => (
                  <span
                    key={tag}
                    className="px-2 py-1 rounded text-xs bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300"
                  >
                    {tag}
                  </span>
                ))}
              </div>
            </div>
          </div>
        </div>
      </div>
    </Link>
  );
}

function BlogCard({ post }: { post: BlogPost }) {
  return (
    <Link href={`/blog/${post.id}`}>
      <div className="group cursor-pointer">
        <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm hover:shadow-lg transition-all duration-300 p-6 h-full border border-gray-200 dark:border-gray-700 group-hover:border-blue-300 dark:group-hover:border-blue-600">
          <div className="flex items-center justify-between mb-3">
            <span className="px-3 py-1 rounded-full text-xs font-medium bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300">
              {post.category}
            </span>
            <span className="text-sm text-gray-500 dark:text-gray-400">
              {post.readTime}
            </span>
          </div>

          <h3 className="text-lg font-semibold mb-2 group-hover:text-blue-600 dark:group-hover:text-blue-400 transition-colors duration-200">
            {post.title}
          </h3>

          <p className="text-gray-600 dark:text-gray-300 mb-4 line-clamp-3 text-sm">
            {post.excerpt}
          </p>

          <div className="flex items-center justify-between">
            <time className="text-sm text-gray-500 dark:text-gray-400">
              {post.date}
            </time>
            <div className="flex flex-wrap gap-1">
              {post.tags.slice(0, 2).map((tag: string) => (
                <span
                  key={tag}
                  className="px-2 py-1 rounded text-xs bg-gray-100 dark:bg-gray-600 text-gray-600 dark:text-gray-300"
                >
                  {tag}
                </span>
              ))}
            </div>
          </div>
        </div>
      </div>
    </Link>
  );
}
