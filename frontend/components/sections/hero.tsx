"use client"

import { Button } from '@/components/ui/button'
import { siteConfig } from '@/lib/config'
import { ExternalLink, Github } from 'lucide-react'

export function Hero() {
  return (
    <section className="relative py-24 px-4 sm:px-6 lg:px-8">
      <div className="vercel-container">
        {/* 主 Hero 区域 */}
        <div className="text-center mb-20">
          <div className="tech-card rounded-2xl p-12 mb-12 bg-white/90 dark:bg-gray-800/80 backdrop-blur-sm border border-gray-200/50 dark:border-gray-700/80">
            <h1 className="text-5xl sm:text-7xl font-bold mb-8 font-primary text-gray-900 dark:text-white">
              欢迎来到{" "}
              <span className="text-gradient">
                {siteConfig.name}
              </span>
            </h1>
            <p className="text-xl sm:text-2xl text-gray-600 dark:text-gray-300 mb-10 max-w-3xl mx-auto leading-relaxed">
              {siteConfig.description}
            </p>
            <div className="flex flex-col sm:flex-row gap-6 justify-center">
              <Button size="lg" className="gradient-border hover-lift bg-gradient-primary text-white font-medium px-8 py-4 text-lg shadow-lg hover:shadow-xl">
                <Github className="h-6 w-6 mr-3" />
                查看项目
              </Button>
              <Button 
                variant="outline" 
                size="lg" 
                className="gradient-border hover-lift border-gray-300 dark:border-gray-600 bg-white/50 dark:bg-gray-800/50 text-gray-900 dark:text-white hover:bg-gray-100/50 dark:hover:bg-gray-700 px-8 py-4 text-lg"
              >
                <ExternalLink className="h-6 w-6 mr-3" />
                在线演示
              </Button>
            </div>
          </div>
        </div>

        {/* 特性展示网格 */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          <div className="tech-card p-8 rounded-xl bg-white/80 dark:bg-gray-800/60 backdrop-blur-sm text-center border border-gray-200/30 dark:border-gray-700/50">
            <div className="h-16 w-16 mx-auto mb-6 bg-gradient-primary rounded-2xl flex items-center justify-center glow-blue">
              <Github className="h-8 w-8 text-white" />
            </div>
            <h3 className="text-xl font-semibold mb-4 text-gray-900 dark:text-white font-primary">Git 集成</h3>
            <p className="text-gray-600 dark:text-gray-300 leading-relaxed">
              实时追踪 GitHub 提交动态，展示最新的开发进展和代码统计
            </p>
          </div>

          <div className="tech-card p-8 rounded-xl bg-white/80 dark:bg-gray-800/60 backdrop-blur-sm text-center border border-gray-200/30 dark:border-gray-700/50">
            <div className="h-16 w-16 mx-auto mb-6 bg-gradient-to-r from-brand-purple to-brand-pink rounded-2xl flex items-center justify-center glow-purple">
              <ExternalLink className="h-8 w-8 text-white" />
            </div>
            <h3 className="text-xl font-semibold mb-4 text-gray-900 dark:text-white font-primary">项目展示</h3>
            <p className="text-gray-600 dark:text-gray-300 leading-relaxed">
              统一管理和展示多个项目，提供便捷的访问入口和状态监控
            </p>
          </div>

          <div className="tech-card p-8 rounded-xl bg-white/80 dark:bg-gray-800/60 backdrop-blur-sm text-center border border-gray-200/30 dark:border-gray-700/50">
            <div className="h-16 w-16 mx-auto mb-6 bg-gradient-to-r from-brand-pink to-brand-purple rounded-2xl flex items-center justify-center glow-pink">
              <div className="h-8 w-8 bg-white rounded-lg"></div>
            </div>
            <h3 className="text-xl font-semibold mb-4 text-gray-900 dark:text-white font-primary">数据可视化</h3>
            <p className="text-gray-600 dark:text-gray-300 leading-relaxed">
              直观的图表展示开发活动和项目统计信息，一目了然
            </p>
          </div>
        </div>
      </div>
    </section>
  )
}
