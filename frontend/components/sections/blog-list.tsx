'use client'

import { useEffect, useState } from 'react'
import Link from 'next/link'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { CalendarIcon, EyeIcon, TagIcon } from 'lucide-react'
import { BlogPost } from '@/types/blog'
import { BlogService } from '@/lib/blog-service'

export function BlogList() {
  const [posts, setPosts] = useState<BlogPost[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [currentPage, setCurrentPage] = useState(1)
  const [hasMore, setHasMore] = useState(true)

  useEffect(() => {
    loadPosts()
  }, [currentPage])

  const loadPosts = async () => {
    try {
      setLoading(true)
      const newPosts = await BlogService.getPosts({
        page: currentPage,
        page_size: 10
      })
      
      if (currentPage === 1) {
        setPosts(newPosts)
      } else {
        setPosts(prev => [...prev, ...newPosts])
      }
      
      setHasMore(newPosts.length === 10)
    } catch (err) {
      setError(err instanceof Error ? err.message : '获取文章失败')
    } finally {
      setLoading(false)
    }
  }

  const loadMore = () => {
    setCurrentPage(prev => prev + 1)
  }

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('zh-CN', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    })
  }

  if (loading && currentPage === 1) {
    return <BlogListSkeleton />
  }

  if (error) {
    return (
      <div className="text-center py-8">
        <p className="text-muted-foreground">加载失败: {error}</p>
        <button 
          onClick={() => window.location.reload()} 
          className="mt-4 px-4 py-2 bg-primary text-primary-foreground rounded hover:bg-primary/90"
        >
          重试
        </button>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {posts.map((post) => (
        <Card key={post.id} className="hover:shadow-lg transition-shadow">
          <CardHeader>
            <div className="flex items-start justify-between">
              <div className="space-y-2">
                <CardTitle className="text-xl">
                  <Link 
                    href={`/blog/${post.slug}`}
                    className="hover:text-primary transition-colors"
                  >
                    {post.title}
                  </Link>
                </CardTitle>
                <div className="flex items-center space-x-4 text-sm text-muted-foreground">
                  <div className="flex items-center space-x-1">
                    <CalendarIcon className="w-4 h-4" />
                    <span>{formatDate(post.published_at || post.created_at)}</span>
                  </div>
                  <div className="flex items-center space-x-1">
                    <EyeIcon className="w-4 h-4" />
                    <span>{post.view_count} 浏览</span>
                  </div>
                  {post.category && (
                    <Badge variant="secondary" className="text-xs">
                      {post.category}
                    </Badge>
                  )}
                  {post.is_featured && (
                    <Badge className="text-xs bg-yellow-500 hover:bg-yellow-600">
                      精选
                    </Badge>
                  )}
                </div>
              </div>
            </div>
          </CardHeader>
          
          <CardContent>
            {post.excerpt && (
              <CardDescription className="text-base mb-4 line-clamp-3">
                {post.excerpt}
              </CardDescription>
            )}
            
            {post.tags.length > 0 && (
              <div className="flex items-center space-x-2">
                <TagIcon className="w-4 h-4 text-muted-foreground" />
                <div className="flex flex-wrap gap-1">
                  {post.tags.slice(0, 3).map((tag) => (
                    <Badge key={tag} variant="outline" className="text-xs">
                      {tag}
                    </Badge>
                  ))}
                  {post.tags.length > 3 && (
                    <Badge variant="outline" className="text-xs">
                      +{post.tags.length - 3}
                    </Badge>
                  )}
                </div>
              </div>
            )}
          </CardContent>
        </Card>
      ))}

      {hasMore && (
        <div className="text-center pt-6">
          <button
            onClick={loadMore}
            disabled={loading}
            className="px-6 py-2 bg-primary text-primary-foreground rounded hover:bg-primary/90 disabled:opacity-50"
          >
            {loading ? '加载中...' : '加载更多'}
          </button>
        </div>
      )}

      {!hasMore && posts.length > 0 && (
        <div className="text-center py-8 text-muted-foreground">
          没有更多文章了
        </div>
      )}
    </div>
  )
}

function BlogListSkeleton() {
  return (
    <div className="space-y-6">
      {[...Array(5)].map((_, i) => (
        <Card key={i}>
          <CardHeader className="space-y-4">
            <div className="h-6 bg-muted rounded w-3/4 animate-pulse"></div>
            <div className="flex space-x-4">
              <div className="h-4 bg-muted rounded w-20 animate-pulse"></div>
              <div className="h-4 bg-muted rounded w-16 animate-pulse"></div>
              <div className="h-4 bg-muted rounded w-12 animate-pulse"></div>
            </div>
          </CardHeader>
          <CardContent className="space-y-2">
            <div className="h-4 bg-muted rounded animate-pulse"></div>
            <div className="h-4 bg-muted rounded w-5/6 animate-pulse"></div>
            <div className="h-4 bg-muted rounded w-4/6 animate-pulse"></div>
          </CardContent>
        </Card>
      ))}
    </div>
  )
}
