import { Footer } from '@/components/layout/footer'
import { Header } from '@/components/layout/header'
import { Hero } from '@/components/sections/hero'

export default function HomePage() {
  return (
    <div className="min-h-screen bg-white dark:bg-gray-900 text-gray-900 dark:text-white flex flex-col">
      {/* 背景渐变效果 - 自适应主题 */}
      <div className="fixed inset-0 -z-10 bg-gradient-to-br from-blue-50/30 to-purple-50/30 dark:from-gray-900/50 dark:to-gray-800/50" />
      <Header />
      <main className="flex-1">
        <Hero />
      </main>
      <Footer />
    </div>
  )
}
