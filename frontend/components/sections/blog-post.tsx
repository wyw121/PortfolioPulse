'use client'

import type { BlogPostData } from '@/lib/blog-loader'
import { useEffect, useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { List } from 'lucide-react'

interface BlogPostComponentProps {
  post: BlogPostData
}

interface TocItem {
  id: string
  text: string
  level: number
}

export function BlogPost({ post }: BlogPostComponentProps) {
  const [toc, setToc] = useState<TocItem[]>([])
  const [activeId, setActiveId] = useState<string>('')
  const [showToc, setShowToc] = useState(false)

  useEffect(() => {
    // 提取文章目录
    const headings = Array.from(
      document.querySelectorAll('article h2, article h3')
    )
    
    const tocItems: TocItem[] = headings.map((heading) => ({
      id: heading.id || heading.textContent?.toLowerCase().replace(/\s+/g, '-') || '',
      text: heading.textContent || '',
      level: parseInt(heading.tagName[1])
    }))
    
    // 为标题添加ID (如果没有)
    headings.forEach((heading, index) => {
      if (!heading.id) {
        heading.id = tocItems[index].id
      }
    })
    
    setToc(tocItems)

    // 监听滚动,高亮当前标题
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            setActiveId(entry.target.id)
          }
        })
      },
      { rootMargin: '-100px 0px -66% 0px' }
    )

    headings.forEach((heading) => observer.observe(heading))
    return () => observer.disconnect()
  }, [post.htmlContent])

  return (
    <div className="relative">
      {/* 目录切换按钮 - 移动端 */}
      {toc.length > 0 && (
        <button
          onClick={() => setShowToc(!showToc)}
          className="lg:hidden fixed bottom-6 right-6 z-50 p-3 rounded-full
            bg-gradient-to-r from-blue-600 via-purple-600 to-pink-600
            text-white shadow-lg hover:shadow-xl
            transition-all duration-300"
          aria-label="Toggle Table of Contents"
        >
          <List className="w-5 h-5" />
        </button>
      )}

      <div className="flex gap-8">
        {/* 文章内容 */}
        <article className="flex-1 min-w-0">
          <div className="prose prose-lg prose-gray dark:prose-invert max-w-none
            prose-headings:font-bold prose-headings:tracking-tight
            prose-h2:text-3xl prose-h2:mt-12 prose-h2:mb-4 prose-h2:scroll-mt-24
            prose-h3:text-2xl prose-h3:mt-8 prose-h3:mb-3 prose-h3:scroll-mt-24
            prose-p:leading-8 prose-p:mb-6 prose-p:text-gray-700 dark:prose-p:text-gray-300
            prose-a:text-blue-600 dark:prose-a:text-blue-400 prose-a:no-underline hover:prose-a:underline
            prose-code:bg-gray-100 dark:prose-code:bg-gray-800 prose-code:px-1.5 prose-code:py-0.5 prose-code:rounded prose-code:text-sm
            prose-pre:bg-gray-100 dark:prose-pre:bg-gray-900 prose-pre:border prose-pre:border-gray-200 dark:prose-pre:border-gray-800 prose-pre:rounded-lg
            prose-blockquote:border-l-4 prose-blockquote:border-purple-500 prose-blockquote:pl-6 prose-blockquote:italic prose-blockquote:text-gray-700 dark:prose-blockquote:text-gray-300
            prose-img:rounded-lg prose-img:my-8 prose-img:shadow-lg
            prose-ul:my-6 prose-ol:my-6
            prose-li:my-2
            prose-strong:text-gray-900 dark:prose-strong:text-gray-100
            prose-em:text-gray-700 dark:prose-em:text-gray-300
          ">
            <div dangerouslySetInnerHTML={{ __html: post.htmlContent }} />
          </div>
        </article>

        {/* 目录导航 - 桌面端侧边栏 */}
        {toc.length > 0 && (
          <>
            {/* 桌面端 - 固定侧边栏 */}
            <aside className="hidden lg:block w-64 shrink-0">
              <nav className="sticky top-24 max-h-[calc(100vh-8rem)] overflow-y-auto">
                <h3 className="text-sm font-semibold text-gray-900 dark:text-gray-100 mb-4 flex items-center gap-2">
                  <List className="w-4 h-4" />
                  目录
                </h3>
                <ul className="space-y-2 text-sm border-l-2 border-gray-200 dark:border-gray-800">
                  {toc.map((item) => (
                    <li key={item.id} style={{ paddingLeft: `${(item.level - 2) * 1}rem` }}>
                      <a
                        href={`#${item.id}`}
                        className={`block py-1 px-3 -ml-[2px] border-l-2 transition-all duration-200
                          ${activeId === item.id
                            ? 'border-purple-600 text-purple-600 dark:text-purple-400 font-medium'
                            : 'border-transparent text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-gray-200'
                          }`}
                        onClick={(e) => {
                          e.preventDefault()
                          document.getElementById(item.id)?.scrollIntoView({
                            behavior: 'smooth',
                            block: 'start'
                          })
                        }}
                      >
                        {item.text}
                      </a>
                    </li>
                  ))}
                </ul>
              </nav>
            </aside>

            {/* 移动端 - 弹出式目录 */}
            <AnimatePresence>
              {showToc && (
                <>
                  {/* 背景遮罩 */}
                  <motion.div
                    initial={{ opacity: 0 }}
                    animate={{ opacity: 1 }}
                    exit={{ opacity: 0 }}
                    onClick={() => setShowToc(false)}
                    className="lg:hidden fixed inset-0 bg-black/50 z-40 backdrop-blur-sm"
                  />
                  
                  {/* 目录面板 */}
                  <motion.div
                    initial={{ x: '100%' }}
                    animate={{ x: 0 }}
                    exit={{ x: '100%' }}
                    transition={{ type: 'spring', damping: 25, stiffness: 200 }}
                    className="lg:hidden fixed right-0 top-0 bottom-0 w-80 bg-white dark:bg-gray-900 z-50 shadow-2xl overflow-y-auto"
                  >
                    <div className="p-6">
                      <div className="flex items-center justify-between mb-6">
                        <h3 className="text-lg font-semibold text-gray-900 dark:text-gray-100 flex items-center gap-2">
                          <List className="w-5 h-5" />
                          目录
                        </h3>
                        <button
                          onClick={() => setShowToc(false)}
                          className="text-gray-500 hover:text-gray-700 dark:hover:text-gray-300"
                        >
                          ✕
                        </button>
                      </div>
                      <ul className="space-y-2 text-sm">
                        {toc.map((item) => (
                          <li key={item.id} style={{ paddingLeft: `${(item.level - 2) * 1}rem` }}>
                            <a
                              href={`#${item.id}`}
                              className={`block py-2 px-3 rounded-lg transition-all duration-200
                                ${activeId === item.id
                                  ? 'bg-gradient-to-r from-blue-500/10 via-purple-500/10 to-pink-500/10 text-purple-600 dark:text-purple-400 font-medium'
                                  : 'text-gray-600 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800'
                                }`}
                              onClick={(e) => {
                                e.preventDefault()
                                document.getElementById(item.id)?.scrollIntoView({
                                  behavior: 'smooth',
                                  block: 'start'
                                })
                                setShowToc(false)
                              }}
                            >
                              {item.text}
                            </a>
                          </li>
                        ))}
                      </ul>
                    </div>
                  </motion.div>
                </>
              )}
            </AnimatePresence>
          </>
        )}
      </div>
    </div>
  )
}
