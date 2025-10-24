'use client'

import type { BlogPostData } from '@/lib/blog-loader'
import { useTranslation } from '@/hooks/use-translation'
import { Calendar, Clock, FileText } from 'lucide-react'

interface BlogPostMetaProps {
  post: BlogPostData
}

// 计算阅读时间 (假设平均阅读速度: 中文300字/分钟, 英文200词/分钟)
function calculateReadingTime(content: string): number {
  const chineseChars = (content.match(/[\u4e00-\u9fa5]/g) || []).length
  const englishWords = content.split(/\s+/).filter(w => /[a-zA-Z]/.test(w)).length
  
  const chineseTime = chineseChars / 300
  const englishTime = englishWords / 200
  
  return Math.ceil(chineseTime + englishTime) || 1
}

// 计算字数
function countWords(content: string): number {
  const chineseChars = (content.match(/[\u4e00-\u9fa5]/g) || []).length
  const englishWords = content.split(/\s+/).filter(w => /[a-zA-Z]/.test(w)).length
  return chineseChars + englishWords
}

export function BlogPostMeta({ post }: BlogPostMetaProps) {
  const { locale } = useTranslation()
  
  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString(locale === 'zh' ? 'zh-CN' : 'en-US', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    })
  }

  const readingTime = calculateReadingTime(post.htmlContent)
  const wordCount = countWords(post.htmlContent)

  return (
    <header className="mb-12">
      {/* 标题 - 保持渐变科技风格 */}
      <h1 className="text-4xl md:text-5xl font-bold mb-6 leading-tight tracking-tight
        bg-gradient-to-r from-blue-600 via-purple-600 to-pink-600 bg-clip-text text-transparent">
        {post.title}
      </h1>

      {/* 元数据行 - PaperMod风格: 日期、阅读时间、字数统计在一行 */}
      <div className="flex flex-wrap items-center gap-4 text-sm text-gray-600 dark:text-gray-400 mb-6">
        {/* 发布日期 */}
        <div className="flex items-center gap-1.5">
          <Calendar className="w-4 h-4" />
          <time dateTime={post.date}>
            {formatDate(post.date)}
          </time>
        </div>
        
        {/* 阅读时间 */}
        <div className="flex items-center gap-1.5">
          <Clock className="w-4 h-4" />
          <span>{readingTime} min read</span>
        </div>
        
        {/* 字数统计 */}
        <div className="flex items-center gap-1.5">
          <FileText className="w-4 h-4" />
          <span>{wordCount.toLocaleString()} {locale === 'zh' ? '字' : 'words'}</span>
        </div>
      </div>

      {/* 副标题/描述 */}
      {post.description && (
        <p className="text-lg text-gray-600 dark:text-gray-400 leading-relaxed">
          {post.description}
        </p>
      )}
    </header>
  )
}
