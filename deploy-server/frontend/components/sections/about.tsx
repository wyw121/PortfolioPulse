"use client"

import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { siteConfig } from '@/lib/config'
import { useEffect, useState } from 'react'

export function About() {
  const [showSecretText, setShowSecretText] = useState(false)
  const [fadeIn, setFadeIn] = useState(false)

  // 5秒后自动切换到秘密文字
  useEffect(() => {
    const timer = setTimeout(() => {
      setShowSecretText(true)
      setFadeIn(true)
    }, 5000)

    return () => clearTimeout(timer)
  }, [])

  const handleTextClick = () => {
    setShowSecretText(prev => !prev)
    if (!showSecretText) {
      setFadeIn(true)
    }
  }
  return (
    <section className="py-20 px-4 sm:px-6 lg:px-8">
      <div className="max-w-4xl mx-auto">
        <div className="text-center mb-12">
          <h1 className="text-4xl sm:text-5xl font-bold text-foreground mb-6">
            关于 {siteConfig.name}
          </h1>
          <p
            className={`text-xl max-w-3xl mx-auto cursor-pointer transition-all duration-700 ${
              showSecretText
                ? `bg-gradient-to-r from-red-500 via-purple-600 to-pink-600 bg-clip-text text-transparent font-semibold ${fadeIn ? 'opacity-100 scale-100' : 'opacity-0 scale-95'}`
                : 'text-muted-foreground hover:text-foreground opacity-100 scale-100'
            }`}
            onClick={handleTextClick}
            title="点击切换内容"
          >
            {showSecretText
              ? "好吧，其实这就是我跟AI聊天随便找来的一个比较酷的名字哈哈，只是读着顺口罢了"
              : siteConfig.description
            }
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <div className="h-8 w-8 bg-gradient-to-r from-purple-600 to-blue-600 rounded-lg flex items-center justify-center">
                  <span className="text-white font-bold text-sm">{siteConfig.shortName}</span>
                </div>
                品牌含义
              </CardTitle>
              <CardDescription>
                {siteConfig.longDescription}
              </CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                <div>
                  <h4 className="font-semibold text-sm uppercase tracking-wide text-purple-600 dark:text-purple-400 mb-2">
                    Vy 的含义
                  </h4>
                  <p className="text-sm text-muted-foreground">
                    {siteConfig.brandMeaning.inspiration.vy}
                  </p>
                </div>
                <div>
                  <h4 className="font-semibold text-sm uppercase tracking-wide text-blue-600 dark:text-blue-400 mb-2">
                    Nix 的含义
                  </h4>
                  <p className="text-sm text-muted-foreground">
                    {siteConfig.brandMeaning.inspiration.nix}
                  </p>
                </div>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>设计理念</CardTitle>
              <CardDescription>
                AI 时代的数字洞察平台
              </CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                <div>
                  <h4 className="font-semibold mb-2">核心特征</h4>
                  <p className="text-sm text-muted-foreground">
                    {siteConfig.brandMeaning.characteristics}
                  </p>
                </div>
                <div>
                  <h4 className="font-semibold mb-2">象征意义</h4>
                  <ul className="text-sm text-muted-foreground space-y-1">
                    <li>• <strong>视野 (Vision):</strong> 洞察复杂系统的能力</li>
                    <li>• <strong>连接 (Link):</strong> 数据与直觉的融合</li>
                    <li>• <strong>无限 (Infinity):</strong> 不断进化的智慧</li>
                  </ul>
                </div>
                <div>
                  <h4 className="font-semibold mb-2">AI 时代愿景</h4>
                  <p className="text-sm text-muted-foreground">
                    在人工智能驱动的未来中，{siteConfig.name} 代表着人机协作的智慧结晶，
                    通过技术与洞察的完美结合，探索数字世界的无限可能。
                  </p>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    </section>
  )
}
