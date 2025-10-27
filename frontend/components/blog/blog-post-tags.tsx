'use client'

import type { BlogPostData } from '@/lib/blog-loader'
import { useTranslation } from '@/hooks/use-translation'
import { Tag } from 'lucide-react'

interface BlogPostTagsProps {
  post: BlogPostData
}

// 分类和标签的翻译映射
const categoryTranslations: Record<string, { zh: string; en: string }> = {
  backend: { zh: '后端开发', en: 'Backend' },
  frontend: { zh: '前端开发', en: 'Frontend' },
  architecture: { zh: '系统架构', en: 'Architecture' },
  devops: { zh: '运维部署', en: 'DevOps' },
  database: { zh: '数据库', en: 'Database' },
}

export function BlogPostTags({ post }: BlogPostTagsProps) {
  const { locale } = useTranslation()
  
  // 获取分类翻译
  const categoryLabel = categoryTranslations[post.category]?.[locale] || post.category

  return (
    <div className="flex flex-wrap items-center gap-3 mt-12 pt-8 border-t border-gray-200 dark:border-gray-800">
      <Tag className="w-4 h-4 text-gray-500 dark:text-gray-400" />
      
      {/* 分类标签 */}
      <a
        href={`/blog?category=${post.category}`}
        className="inline-flex items-center px-3 py-1.5 rounded-full text-sm font-medium
          bg-gradient-to-r from-blue-500/10 via-purple-500/10 to-pink-500/10
          hover:from-blue-500/20 hover:via-purple-500/20 hover:to-pink-500/20
          text-gray-700 dark:text-gray-300
          border border-gray-200 dark:border-gray-700
          transition-all duration-300"
      >
        {categoryLabel}
      </a>
      
      {/* 自定义标签 (如果有) */}
      {post.tags && post.tags.length > 0 && post.tags.map((tag) => (
        <a
          key={tag}
          href={`/blog?tag=${tag}`}
          className="inline-flex items-center px-3 py-1.5 rounded-full text-sm font-medium
            bg-gray-100 dark:bg-gray-800
            hover:bg-gray-200 dark:hover:bg-gray-700
            text-gray-700 dark:text-gray-300
            border border-gray-200 dark:border-gray-700
            transition-all duration-300"
        >
          {tag}
        </a>
      ))}
    </div>
  )
}
