import { Footer } from '@/components/layout/footer'
import { Header } from '@/components/layout/header'
import { BlogList } from '@/components/sections/blog-list'
import { BlogSidebar } from '@/components/sections/blog-sidebar'
import { siteConfig } from '@/lib/config'
import type { Metadata } from 'next'
import { Suspense } from 'react'

export const metadata: Metadata = {
  title: `博客 - ${siteConfig.name}`,
  description: `${siteConfig.author.name}的个人学习记录和技术分享`,
}

export default function BlogPage() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-50 to-slate-100 dark:from-slate-900 dark:to-slate-800 flex flex-col">
      <Header />
      <main className="flex-1 pt-16">
        <div className="container max-w-7xl mx-auto px-4 py-8">
          <div className="mb-8">
            <h1 className="text-4xl font-bold mb-4">博客</h1>
            <p className="text-muted-foreground text-lg">
              分享我的学习心得、技术思考和生活感悟
            </p>
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
            <div className="lg:col-span-2">
              <Suspense fallback={<BlogListSkeleton />}>
                <BlogList />
              </Suspense>
            </div>

            <div className="lg:col-span-1">
              <Suspense fallback={<BlogSidebarSkeleton />}>
                <BlogSidebar />
              </Suspense>
            </div>
          </div>
        </div>
      </main>
      <Footer />
    </div>
  )
}

function BlogListSkeleton() {
  return (
    <div className="space-y-6">
      {[...Array(5)].map((_, i) => (
        <div key={i} className="border rounded-lg p-6 space-y-4">
          <div className="h-6 bg-muted rounded w-3/4"></div>
          <div className="h-4 bg-muted rounded w-1/4"></div>
          <div className="space-y-2">
            <div className="h-4 bg-muted rounded"></div>
            <div className="h-4 bg-muted rounded w-5/6"></div>
          </div>
        </div>
      ))}
    </div>
  )
}

function BlogSidebarSkeleton() {
  return (
    <div className="space-y-6">
      <div className="border rounded-lg p-4 space-y-4">
        <div className="h-5 bg-muted rounded w-1/2"></div>
        <div className="space-y-2">
          {[...Array(4)].map((_, i) => (
            <div key={i} className="h-4 bg-muted rounded w-3/4"></div>
          ))}
        </div>
      </div>
      <div className="border rounded-lg p-4 space-y-4">
        <div className="h-5 bg-muted rounded w-1/2"></div>
        <div className="space-y-2">
          {[...Array(3)].map((_, i) => (
            <div key={i} className="h-4 bg-muted rounded"></div>
          ))}
        </div>
      </div>
    </div>
  )
}
