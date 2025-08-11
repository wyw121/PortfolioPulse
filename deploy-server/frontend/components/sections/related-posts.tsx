'use client'

import { Badge } from '@/components/ui/badge'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { BlogService } from '@/lib/blog-service'
import type { BlogPost } from '@/types/blog'
import Link from 'next/link'
import { useEffect, useState } from 'react'

interface RelatedPostsProps {
  currentSlug: string
  category?: string
}

export function RelatedPosts({ currentSlug, category }: RelatedPostsProps) {
  const [relatedPosts, setRelatedPosts] = useState<BlogPost[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadRelatedPosts()
  }, [currentSlug, category])

  const loadRelatedPosts = async () => {
    try {
      let posts: BlogPost[] = []

      // 先尝试获取同分类的文章
      if (category) {
        posts = await BlogService.getPosts({
          category: category,
          page_size: 6
        })
        // 过滤掉当前文章
        posts = posts.filter(post => post.slug !== currentSlug)
      }

      // 如果同分类文章不够，补充其他文章
      if (posts.length < 3) {
        const allPosts = await BlogService.getPosts({
          page_size: 8
        })
        const otherPosts = allPosts
          .filter(post => post.slug !== currentSlug && !posts.some(p => p.slug === post.slug))
          .slice(0, 3 - posts.length)

        posts = [...posts, ...otherPosts]
      }

      setRelatedPosts(posts.slice(0, 3))
    } catch (error) {
      console.error('获取相关文章失败:', error)
    } finally {
      setLoading(false)
    }
  }

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
          <Card key={post.id} className="hover:shadow-md transition-shadow">
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
                <span>{formatDate(post.published_at || post.created_at)}</span>
                {post.category && (
                  <Badge variant="outline" className="text-xs">
                    {post.category}
                  </Badge>
                )}
              </div>
            </CardHeader>

            {post.excerpt && (
              <CardContent>
                <CardDescription className="text-sm line-clamp-2">
                  {post.excerpt}
                </CardDescription>
              </CardContent>
            )}
          </Card>
        ))}
      </div>
    </div>
  )
}
