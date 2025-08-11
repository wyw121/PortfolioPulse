"use client"

import { useEffect, useState } from 'react'

interface PerformanceMetrics {
  pageLoad: number
  domContentLoaded: number
  firstContentfulPaint?: number
  largestContentfulPaint?: number
}

export function PerformanceMonitor() {
  const [metrics, setMetrics] = useState<PerformanceMetrics | null>(null)
  const [showMetrics, setShowMetrics] = useState(false)

  useEffect(() => {
    const updateLCP = (lcpTime: number) => {
      setMetrics(prev => prev ? { ...prev, largestContentfulPaint: lcpTime } : null)
    }

    const measurePerformance = () => {
      const navigation = performance.getEntriesByType('navigation')[0] as PerformanceNavigationTiming
      const paint = performance.getEntriesByType('paint')

      const newMetrics: PerformanceMetrics = {
        pageLoad: navigation.loadEventEnd - navigation.fetchStart,
        domContentLoaded: navigation.domContentLoadedEventEnd - navigation.fetchStart,
      }

      // 获取 FCP
      const fcp = paint.find(entry => entry.name === 'first-contentful-paint')
      if (fcp) {
        newMetrics.firstContentfulPaint = fcp.startTime
      }

      // LCP 需要使用 PerformanceObserver，简化嵌套
      if ('PerformanceObserver' in window) {
        const observer = new PerformanceObserver((list) => {
          const entries = list.getEntries()
          const lastEntry = entries[entries.length - 1]
          if (lastEntry) {
            updateLCP(lastEntry.startTime)
          }
        })
        observer.observe({ entryTypes: ['largest-contentful-paint'] })
      }

      setMetrics(newMetrics)
    }

    if (document.readyState === 'complete') {
      measurePerformance()
    } else {
      window.addEventListener('load', measurePerformance)
      return () => window.removeEventListener('load', measurePerformance)
    }
  }, [])

  if (!metrics) return null

  const formatTime = (time: number) => `${Math.round(time)}ms`

  const getPerformanceRating = (time: number, thresholds: [number, number]) => {
    if (time < thresholds[0]) return 'text-green-600'
    if (time < thresholds[1]) return 'text-yellow-600'
    return 'text-red-600'
  }

  return (
    <>
      {/* 性能指示器按钮 */}
      <button
        onClick={() => setShowMetrics(!showMetrics)}
        className="fixed bottom-4 right-4 z-50 bg-blue-500 text-white p-2 rounded-full shadow-lg hover:bg-blue-600 transition-colors"
        title="查看页面性能指标"
      >
        📊
      </button>

      {/* 性能面板 */}
      {showMetrics && (
        <div className="fixed bottom-16 right-4 z-50 bg-white dark:bg-gray-800 p-4 rounded-lg shadow-xl border w-80">
          <h3 className="font-semibold text-sm mb-3 flex items-center justify-between">
            页面性能指标
            <button
              onClick={() => setShowMetrics(false)}
              className="text-gray-500 hover:text-gray-700"
            >
              ✕
            </button>
          </h3>

          <div className="space-y-2 text-xs">
            <div className="flex justify-between">
              <span>页面加载完成:</span>
              <span className={getPerformanceRating(metrics.pageLoad, [1000, 3000])}>
                {formatTime(metrics.pageLoad)}
              </span>
            </div>

            <div className="flex justify-between">
              <span>DOM 内容加载:</span>
              <span className={getPerformanceRating(metrics.domContentLoaded, [800, 1600])}>
                {formatTime(metrics.domContentLoaded)}
              </span>
            </div>

            {metrics.firstContentfulPaint && (
              <div className="flex justify-between">
                <span>首次内容绘制:</span>
                <span className={getPerformanceRating(metrics.firstContentfulPaint, [1800, 3000])}>
                  {formatTime(metrics.firstContentfulPaint)}
                </span>
              </div>
            )}

            {metrics.largestContentfulPaint && (
              <div className="flex justify-between">
                <span>最大内容绘制:</span>
                <span className={getPerformanceRating(metrics.largestContentfulPaint, [2500, 4000])}>
                  {formatTime(metrics.largestContentfulPaint)}
                </span>
              </div>
            )}
          </div>

          <div className="mt-3 pt-2 border-t text-xs text-gray-500">
            <div>绿色 = 优秀, 黄色 = 需要改进, 红色 = 较差</div>
          </div>
        </div>
      )}
    </>
  )
}
