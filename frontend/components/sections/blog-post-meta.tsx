'use client'

import { Badge } from '@/components/ui/badge'
import { CalendarIcon, EyeIcon, TagIcon, UserIcon } from 'lucide-react'
import type { BlogPost } from '@/types/blog'

interface BlogPostMetaProps {
  post: BlogPost
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

  const formatTime = (dateString: string) => {
    return new Date(dateString).toLocaleTimeString('zh-CN', {
      hour: '2-digit',
      minute: '2-digit'
    })
  }

  return (
    <div className="mb-8">
      {/* 文章标题 */}
      <h1 className="text-4xl font-bold mb-6 leading-tight">{post.title}</h1>
      
      {/* 文章摘要 */}
      {post.excerpt && (
        <p className="text-lg text-muted-foreground mb-6 leading-relaxed">
          {post.excerpt}
        </p>
      )}

      {/* 封面图片 */}
      {post.cover_image && (
        <div className="mb-8">
          <img
            src={post.cover_image}
            alt={post.title}
            className="w-full max-h-96 object-cover rounded-lg shadow-sm"
          />
        </div>
      )}

      {/* 元数据信息 */}
      <div className="flex flex-wrap items-center gap-6 text-sm text-muted-foreground mb-8 pb-6 border-b">
        {/* 作者 */}
        <div className="flex items-center space-x-2">
          <UserIcon className="w-4 h-4" />
          <span>PortfolioPulse</span>
        </div>

        {/* 发布时间 */}
        <div className="flex items-center space-x-2">
          <CalendarIcon className="w-4 h-4" />
          <span>
            {formatDate(post.published_at || post.created_at)}
            {' '}
            {formatTime(post.published_at || post.created_at)}
          </span>
        </div>

        {/* 浏览量 */}
        <div className="flex items-center space-x-2">
          <EyeIcon className="w-4 h-4" />
          <span>{post.view_count} 次浏览</span>
        </div>

        {/* 分类 */}
        {post.category && (
          <Badge variant="secondary">
            {post.category}
          </Badge>
        )}

        {/* 精选标记 */}
        {post.is_featured && (
          <Badge className="bg-yellow-500 hover:bg-yellow-600">
            精选文章
          </Badge>
        )}
      </div>

      {/* 标签 */}
      {post.tags.length > 0 && (
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

      {/* 更新时间提示 */}
      {post.updated_at !== post.created_at && (
        <div className="text-xs text-muted-foreground mb-8">
          最后更新于 {formatDate(post.updated_at)} {formatTime(post.updated_at)}
        </div>
      )}
    </div>
  )
}
