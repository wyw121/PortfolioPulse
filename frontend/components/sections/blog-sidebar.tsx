'use client'

import { useEffect, useState } from 'react'
import Link from 'next/link'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { BlogPost, BlogCategory } from '@/types/blog'
import { BlogService } from '@/lib/blog-service'

export function BlogSidebar() {
  const [categories, setCategories] = useState<BlogCategory[]>([])
  const [featuredPosts, setFeaturedPosts] = useState<BlogPost[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadSidebarData()
  }, [])

  const loadSidebarData = async () => {
    try {
      const [categoriesData, featuredData] = await Promise.all([
        BlogService.getCategories(),
        BlogService.getFeaturedPosts()
      ])
      
      setCategories(categoriesData)
      setFeaturedPosts(featuredData)
    } catch (error) {
      console.error('加载侧边栏数据失败:', error)
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
    return <BlogSidebarSkeleton />
  }

  return (
    <div className="space-y-6">
      {/* 分类列表 */}
      <Card>
        <CardHeader>
          <CardTitle className="text-lg">分类</CardTitle>
        </CardHeader>
        <CardContent className="space-y-2">
          {categories.map((category) => (
            <Link
              key={category.id}
              href={`/blog?category=${category.slug}`}
              className="flex items-center justify-between p-2 rounded hover:bg-muted transition-colors"
            >
              <div className="flex items-center space-x-2">
                <div 
                  className="w-3 h-3 rounded-full"
                  style={{ backgroundColor: category.color }}
                />
                <span className="text-sm">{category.name}</span>
              </div>
              <Badge variant="secondary" className="text-xs">
                {category.post_count}
              </Badge>
            </Link>
          ))}
        </CardContent>
      </Card>

      {/* 精选文章 */}
      {featuredPosts.length > 0 && (
        <Card>
          <CardHeader>
            <CardTitle className="text-lg">精选文章</CardTitle>
          </CardHeader>
          <CardContent className="space-y-3">
            {featuredPosts.map((post) => (
              <div key={post.id} className="border-b border-border last:border-0 pb-3 last:pb-0">
                <Link
                  href={`/blog/${post.slug}`}
                  className="block hover:text-primary transition-colors"
                >
                  <h4 className="text-sm font-medium mb-1 line-clamp-2">
                    {post.title}
                  </h4>
                  <p className="text-xs text-muted-foreground">
                    {formatDate(post.published_at || post.created_at)}
                  </p>
                </Link>
              </div>
            ))}
          </CardContent>
        </Card>
      )}

      {/* 标签云 */}
      <Card>
        <CardHeader>
          <CardTitle className="text-lg">热门标签</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="flex flex-wrap gap-2">
            {/* 这里可以从API获取热门标签，暂时使用静态数据 */}
            {['金融', 'React', 'TypeScript', 'Rust', 'Next.js', 'Web开发', '学习笔记', '投资理财'].map((tag) => (
              <Link
                key={tag}
                href={`/blog?search=${encodeURIComponent(tag)}`}
              >
                <Badge variant="outline" className="text-xs hover:bg-primary hover:text-primary-foreground transition-colors">
                  {tag}
                </Badge>
              </Link>
            ))}
          </div>
        </CardContent>
      </Card>

      {/* 最近更新 */}
      <Card>
        <CardHeader>
          <CardTitle className="text-lg">统计信息</CardTitle>
        </CardHeader>
        <CardContent className="space-y-2">
          <div className="flex justify-between text-sm">
            <span className="text-muted-foreground">总文章数</span>
            <span className="font-medium">
              {categories.reduce((sum, cat) => sum + cat.post_count, 0)}
            </span>
          </div>
          <div className="flex justify-between text-sm">
            <span className="text-muted-foreground">分类数</span>
            <span className="font-medium">{categories.length}</span>
          </div>
          <div className="flex justify-between text-sm">
            <span className="text-muted-foreground">精选文章</span>
            <span className="font-medium">{featuredPosts.length}</span>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}

function BlogSidebarSkeleton() {
  return (
    <div className="space-y-6">
      <Card>
        <CardHeader>
          <div className="h-5 bg-muted rounded w-1/3 animate-pulse"></div>
        </CardHeader>
        <CardContent className="space-y-2">
          {[...Array(4)].map((_, i) => (
            <div key={i} className="flex items-center justify-between p-2">
              <div className="flex items-center space-x-2">
                <div className="w-3 h-3 bg-muted rounded-full animate-pulse"></div>
                <div className="h-4 bg-muted rounded w-16 animate-pulse"></div>
              </div>
              <div className="h-4 bg-muted rounded w-6 animate-pulse"></div>
            </div>
          ))}
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <div className="h-5 bg-muted rounded w-1/2 animate-pulse"></div>
        </CardHeader>
        <CardContent className="space-y-3">
          {[...Array(3)].map((_, i) => (
            <div key={i} className="space-y-2">
              <div className="h-4 bg-muted rounded animate-pulse"></div>
              <div className="h-3 bg-muted rounded w-20 animate-pulse"></div>
            </div>
          ))}
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <div className="h-5 bg-muted rounded w-1/3 animate-pulse"></div>
        </CardHeader>
        <CardContent>
          <div className="flex flex-wrap gap-2">
            {[...Array(6)].map((_, i) => (
              <div key={i} className="h-6 bg-muted rounded w-12 animate-pulse"></div>
            ))}
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
