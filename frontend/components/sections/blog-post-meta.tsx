'use client'

import { Badge } from '@/components/ui/badge'
import type { BlogPostData } from '@/lib/blog-loader'
import { CalendarIcon, TagIcon, ClockIcon } from 'lucide-react'

interface BlogPostMetaProps {
  post: BlogPostData
}

export function BlogPostMeta({ post }: BlogPostMetaProps) {
  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('zh-CN', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
      weekday: 'long'
    })
  }

  return (
    <div className="mb-8">
      {/* 文章标题 */}
      <h1 className="text-4xl font-bold mb-6 leading-tight">{post.title}</h1>

      {/* 文章摘要 */}
      {post.description && (
        <p className="text-lg text-muted-foreground mb-6 leading-relaxed">
          {post.description}
        </p>
      )}

      {/* 封面图片 */}
      {post.cover && (
        <div className="mb-8">
          <img
            src={post.cover}
            alt={post.title}
            className="w-full max-h-96 object-cover rounded-lg shadow-sm"
          />
        </div>
      )}

      {/* 元数据信息 */}
      <div className="flex flex-wrap items-center gap-6 text-sm text-muted-foreground mb-8 pb-6 border-b">
        {/* 发布时间 */}
        <div className="flex items-center space-x-2">
          <CalendarIcon className="w-4 h-4" />
          <span>{formatDate(post.date)}</span>
        </div>

        {/* 阅读时长 */}
        {post.readTime && (
          <div className="flex items-center space-x-2">
            <TagIcon className="w-4 h-4" />
            <span>{post.readTime}</span>
          </div>
        )}

        {/* 分类 */}
        {post.category && (
          <Badge variant="secondary">
            {post.category}
          </Badge>
        )}

        {/* 精选标记 */}
        {post.featured && (
          <Badge className="bg-yellow-500 hover:bg-yellow-600">
            精选文章
          </Badge>
        )}
      </div>

      {/* 标签 */}
      {post.tags && post.tags.length > 0 && (
        <div className="flex items-center space-x-2 mb-8">
          <TagIcon className="w-4 h-4 text-muted-foreground" />
          <div className="flex flex-wrap gap-2">
            {post.tags.map((tag) => (
              <Badge key={tag} variant="outline" className="text-xs">
                {tag}
              </Badge>
            ))}
          </div>
        </div>
      )}
    </div>
  )
}
