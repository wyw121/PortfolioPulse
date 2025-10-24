'use client'

import { Badge } from '@/components/ui/badge'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import type { BlogPostMeta } from '@/lib/blog-loader'
import { useTranslation } from '@/hooks/use-translation'
import Link from 'next/link'
import { motion } from 'framer-motion'

interface RelatedPostsProps {
  posts: BlogPostMeta[]
}

export function RelatedPosts({ posts }: RelatedPostsProps) {
  const { dict } = useTranslation()

  if (posts.length === 0) {
    return null
  }

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('zh-CN', {
      month: 'short',
      day: 'numeric'
    })
  }

  return (
    <div>
      <h3 className="text-2xl font-bold mb-6 text-gray-900 dark:text-white">
        {dict.blog.relatedPosts || '相关文章'}
      </h3>
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        {posts.map((post, index) => (
          <motion.div
            key={post.slug}
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: index * 0.1, duration: 0.3 }}
          >
            <Link href={`/blog/${post.slug}`}>
              <Card className="h-full hover:shadow-xl transition-all duration-300 border-gray-200/50 dark:border-gray-700/50 bg-white/50 dark:bg-gray-900/50 backdrop-blur-sm group">
                <CardHeader>
                  <div className="flex items-center justify-between mb-2">
                    <Badge variant="secondary" className="text-xs">
                      {post.category}
                    </Badge>
                    <span className="text-xs text-gray-500 dark:text-gray-400">
                      {post.readTime}
                    </span>
                  </div>
                  <CardTitle className="text-base group-hover:text-blue-500 dark:group-hover:text-blue-400 transition-colors">
                    {post.title}
                  </CardTitle>
                  <CardDescription className="line-clamp-2">
                    {post.description}
                  </CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="flex items-center gap-2 text-sm text-gray-500 dark:text-gray-400">
                    <span>📅</span>
                    <time dateTime={post.date}>{formatDate(post.date)}</time>
                  </div>
                </CardContent>
              </Card>
            </Link>
          </motion.div>
        ))}
      </div>
    </div>
  )
}
