"use client";

import { AnimatedContainer } from "@/components/ui/effects";
import { motion } from "framer-motion";
import Link from "next/link";
import type { BlogPostMeta } from "@/lib/blog-loader";
import { useEffect, useState } from "react";

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
  const [posts, setPosts] = useState<BlogPostMeta[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedCategory, setSelectedCategory] = useState("全部");

  useEffect(() => {
    fetch("/api/blog/posts")
      .then((res) => res.json())
      .then((data: BlogPostMeta[]) => {
        setPosts(data);
        setLoading(false);
      })
      .catch((error) => {
        console.error("获取博客文章失败:", error);
        setLoading(false);
      });
  }, []);

  const filteredPosts = posts.filter(
    (post) => selectedCategory === "全部" || post.category === selectedCategory
  );

  const featuredPosts = filteredPosts.filter((post) => post.featured);

  if (loading) {
    return (
      <div className="max-w-6xl mx-auto px-6 pb-20">
        <div className="text-center text-gray-600 dark:text-gray-400">
          加载中...
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-6xl mx-auto px-6 pb-20">
      {featuredPosts.length > 0 && (
        <AnimatedContainer
          direction="up"
          duration={350}
          delay={100}
          fastResponse={true}
        >
          <div className="mb-16">
            <h2 className="text-2xl font-bold mb-8 text-gray-900 dark:text-white">
              特色文章
            </h2>
            <div className="grid md:grid-cols-2 gap-8">
              {featuredPosts.map((post, index) => (
                <motion.div
                  key={post.slug}
                  initial={{ opacity: 0, y: 15 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{
                    delay: 0.2 + index * 0.08,
                    duration: 0.4,
                  }}
                >
                  <FeaturedBlogCard post={post} />
                </motion.div>
              ))}
            </div>
          </div>
        </AnimatedContainer>
      )}

      <AnimatedContainer
        direction="up"
        duration={350}
        delay={200}
        fastResponse={true}
      >
        <div className="mb-8">
          <div className="flex flex-wrap gap-3 justify-center">
            {categories.map((category) => (
              <button
                key={category}
                onClick={() => setSelectedCategory(category)}
                className={`px-4 py-2 rounded-full text-sm font-medium transition-all duration-200 ${
                  selectedCategory === category
                    ? "bg-blue-500 text-white"
                    : "bg-gray-100 hover:bg-gray-200 dark:bg-gray-800 dark:hover:bg-gray-700 text-gray-700 dark:text-gray-300"
                }`}
              >
                {category}
              </button>
            ))}
          </div>
        </div>
      </AnimatedContainer>

      <AnimatedContainer
        direction="up"
        duration={350}
        delay={300}
        fastResponse={true}
      >
        {filteredPosts.length === 0 ? (
          <div className="text-center text-gray-600 dark:text-gray-400 py-12">
            暂无文章
          </div>
        ) : (
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
            {filteredPosts.map((post, index) => (
              <motion.div
                key={post.slug}
                initial={{ opacity: 0, y: 15 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{
                  delay: 0.4 + index * 0.06,
                  duration: 0.35,
                }}
              >
                <BlogCard post={post} />
              </motion.div>
            ))}
          </div>
        )}
      </AnimatedContainer>
    </div>
  );
}

function FeaturedBlogCard({ post }: { post: BlogPostMeta }) {
  return (
    <Link href={`/blog/${post.slug}`}>
      <div className="group cursor-pointer">
        <div className="relative overflow-hidden rounded-2xl bg-gradient-to-br from-blue-50 to-purple-50 dark:from-gray-800 dark:to-gray-900 p-8 h-full">
          <div className="absolute inset-0 bg-gradient-to-br from-blue-500/10 to-purple-500/10 group-hover:from-blue-500/20 group-hover:to-purple-500/20 transition-all duration-300" />
          <div className="relative z-10">
            <div className="flex items-center justify-between mb-4">
              <span className="px-3 py-1 rounded-full text-xs font-medium bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-300">
                {post.category}
              </span>
              <span className="text-sm text-gray-500 dark:text-gray-400">{post.readTime}</span>
            </div>
            <h3 className="text-xl font-bold mb-3 group-hover:text-blue-600 dark:group-hover:text-blue-400 transition-colors duration-200">
              {post.title}
            </h3>
            <p className="text-gray-600 dark:text-gray-300 mb-4 line-clamp-3">{post.description}</p>
            <div className="flex items-center justify-between">
              <time className="text-sm text-gray-500 dark:text-gray-400">{post.date}</time>
              <div className="flex flex-wrap gap-2">
                {post.tags?.slice(0, 2).map((tag: string) => (
                  <span key={tag} className="px-2 py-1 rounded text-xs bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300">{tag}</span>
                ))}
              </div>
            </div>
          </div>
        </div>
      </div>
    </Link>
  );
}

function BlogCard({ post }: { post: BlogPostMeta }) {
  return (
    <Link href={`/blog/${post.slug}`}>
      <div className="group cursor-pointer">
        <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm hover:shadow-lg transition-all duration-300 p-6 h-full border border-gray-200 dark:border-gray-700 group-hover:border-blue-300 dark:group-hover:border-blue-600">
          <div className="flex items-center justify-between mb-3">
            <span className="px-3 py-1 rounded-full text-xs font-medium bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300">
              {post.category}
            </span>
            <span className="text-sm text-gray-500 dark:text-gray-400">{post.readTime}</span>
          </div>
          <h3 className="text-lg font-semibold mb-2 group-hover:text-blue-600 dark:group-hover:text-blue-400 transition-colors duration-200">
            {post.title}
          </h3>
          <p className="text-gray-600 dark:text-gray-300 mb-4 line-clamp-3 text-sm">{post.description}</p>
          <div className="flex items-center justify-between">
            <time className="text-sm text-gray-500 dark:text-gray-400">{post.date}</time>
            <div className="flex flex-wrap gap-1">
              {post.tags?.slice(0, 2).map((tag: string) => (
                <span key={tag} className="px-2 py-1 rounded text-xs bg-gray-100 dark:bg-gray-600 text-gray-600 dark:text-gray-300">{tag}</span>
              ))}
            </div>
          </div>
        </div>
      </div>
    </Link>
  );
}
