'use client'

import { Badge } from '@/components/ui/badge'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import type { BlogPostMeta } from '@/lib/blog-loader'
import Link from 'next/link'
import { useEffect, useState } from 'react'

interface RelatedPostsProps {
  currentSlug: string
  category: string
}

export function RelatedPosts({ currentSlug, category }: RelatedPostsProps) {
  const [relatedPosts, setRelatedPosts] = useState<BlogPostMeta[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const loadData = async () => {
      try {
        const response = await fetch(
          `/api/blog/related?slug=${encodeURIComponent(currentSlug)}&category=${encodeURIComponent(category)}&limit=3`
        )
        if (!response.ok) throw new Error('获取相关文章失败')
        const posts = await response.json()
        setRelatedPosts(posts)
      } catch (error) {
        console.error('获取相关文章失败:', error)
      } finally {
        setLoading(false)
      }
    }
    loadData()
  }, [currentSlug, category])

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('zh-CN', {
      month: 'short',
      day: 'numeric'
    })
  }

  if (loading) {
    return (
      <div>
        <h3 className="text-xl font-bold mb-6">相关文章</h3>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          {[...Array(3)].map((_, i) => (
            <Card key={i}>
              <CardHeader>
                <div className="h-5 bg-muted rounded animate-pulse"></div>
                <div className="h-4 bg-muted rounded w-3/4 animate-pulse"></div>
              </CardHeader>
              <CardContent>
                <div className="space-y-2">
                  <div className="h-3 bg-muted rounded animate-pulse"></div>
                  <div className="h-3 bg-muted rounded w-5/6 animate-pulse"></div>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      </div>
    )
  }

  if (relatedPosts.length === 0) {
    return null
  }

  return (
    <div>
      <h3 className="text-xl font-bold mb-6">相关文章</h3>
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        {relatedPosts.map((post) => (
          <Card key={post.slug} className="hover:shadow-md transition-shadow">
            <CardHeader>
              <CardTitle className="text-base">
                <Link
                  href={`/blog/${post.slug}`}
                  className="hover:text-primary transition-colors line-clamp-2"
                >
                  {post.title}
                </Link>
              </CardTitle>
              <div className="flex items-center space-x-2 text-sm text-muted-foreground">
                <span>{formatDate(post.date)}</span>
                {post.category && (
                  <Badge variant="outline" className="text-xs">
                    {post.category}
                  </Badge>
                )}
              </div>
            </CardHeader>

            {post.description && (
              <CardContent>
                <CardDescription className="text-sm line-clamp-2">
                  {post.description}
                </CardDescription>
              </CardContent>
            )}
          </Card>
        ))}
      </div>
    </div>
  )
}
