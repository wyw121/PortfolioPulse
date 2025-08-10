"use client"

import { ThemeToggle } from '@/components/theme-toggle'
import { siteConfig } from '@/lib/config'

export function Header() {
  return (
    <header className="sticky top-0 z-50 w-full border-b bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60">
      <div className="container flex h-16 items-center justify-between">
        <div className="flex items-center space-x-4">
          <a href="/" className="flex items-center space-x-2">
            <div className="h-8 w-8 bg-gradient-to-r from-purple-600 to-blue-600 rounded-lg flex items-center justify-center">
              <span className="text-white font-bold text-sm">{siteConfig.shortName}</span>
            </div>
            <span className="font-bold text-xl">{siteConfig.name}</span>
          </a>
        </div>

        <nav className="flex items-center space-x-6">
          <a href="/projects" className="text-sm font-medium hover:text-primary transition-colors">
            项目
          </a>
          <a href="/blog" className="text-sm font-medium hover:text-primary transition-colors">
            博客
          </a>
          <a href="/activity" className="text-sm font-medium hover:text-primary transition-colors">
            动态
          </a>
          <a href="/about" className="text-sm font-medium hover:text-primary transition-colors">
            关于
          </a>
        </nav>

        <div className="flex items-center space-x-4">
          <ThemeToggle />
        </div>
      </div>
    </header>
  )
}
