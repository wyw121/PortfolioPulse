"use client"

import { Button } from '@/components/ui/button'
import { siteConfig } from '@/lib/config'
import { ExternalLink, Github } from 'lucide-react'

export function Hero() {
  return (
    <section className="relative py-20 px-4 sm:px-6 lg:px-8">
      <div className="max-w-4xl mx-auto text-center">
        <div className="hero-gradient rounded-2xl p-1 mb-8">
          <div className="bg-background rounded-xl p-8">
            <h1 className="text-4xl sm:text-6xl font-bold text-foreground mb-6">
              欢迎来到{" "}
              <span className="bg-gradient-to-r from-purple-600 to-blue-600 bg-clip-text text-transparent">
                {siteConfig.name}
              </span>
            </h1>
            <p className="text-xl text-muted-foreground mb-8 max-w-2xl mx-auto">
              {siteConfig.description}
            </p>
            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <Button size="lg" className="gap-2">
                <Github className="h-5 w-5" />
                查看项目
              </Button>
              <Button variant="outline" size="lg" className="gap-2">
                <ExternalLink className="h-5 w-5" />
                在线演示
              </Button>
            </div>
          </div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-8 mt-16">
          <div className="p-6 rounded-lg bg-card">
            <div className="h-12 w-12 mx-auto mb-4 bg-blue-100 dark:bg-blue-900 rounded-lg flex items-center justify-center">
              <Github className="h-6 w-6 text-blue-600 dark:text-blue-400" />
            </div>
            <h3 className="text-lg font-semibold mb-2">Git 集成</h3>
            <p className="text-muted-foreground">
              实时追踪 GitHub 提交动态，展示最新的开发进展
            </p>
          </div>

          <div className="p-6 rounded-lg bg-card">
            <div className="h-12 w-12 mx-auto mb-4 bg-green-100 dark:bg-green-900 rounded-lg flex items-center justify-center">
              <ExternalLink className="h-6 w-6 text-green-600 dark:text-green-400" />
            </div>
            <h3 className="text-lg font-semibold mb-2">项目展示</h3>
            <p className="text-muted-foreground">
              统一管理和展示多个项目，提供便捷的访问入口
            </p>
          </div>

          <div className="p-6 rounded-lg bg-card">
            <div className="h-12 w-12 mx-auto mb-4 bg-purple-100 dark:bg-purple-900 rounded-lg flex items-center justify-center">
              <div className="h-6 w-6 bg-purple-600 dark:bg-purple-400 rounded"></div>
            </div>
            <h3 className="text-lg font-semibold mb-2">数据可视化</h3>
            <p className="text-muted-foreground">
              直观的图表展示开发活动和项目统计信息
            </p>
          </div>
        </div>
      </div>
    </section>
  )
}
