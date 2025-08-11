"use client"

import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { useCallback, useEffect, useMemo, useState } from 'react'

interface GitActivity {
  date: string
  commits: number
  additions: number
  deletions: number
}

interface RecentCommit {
  sha: string
  message: string
  author: string
  date: string
  repository: string
}

// 使用常量避免重复创建对象
const MOCK_ACTIVITIES: GitActivity[] = [
  { date: '2024-01-15', commits: 5, additions: 150, deletions: 32 },
  { date: '2024-01-14', commits: 3, additions: 89, deletions: 15 },
  { date: '2024-01-13', commits: 8, additions: 234, deletions: 67 },
  { date: '2024-01-12', commits: 2, additions: 45, deletions: 8 },
  { date: '2024-01-11', commits: 6, additions: 178, deletions: 43 },
  { date: '2024-01-10', commits: 4, additions: 112, deletions: 28 },
  { date: '2024-01-09', commits: 1, additions: 23, deletions: 5 }
]

const MOCK_COMMITS: RecentCommit[] = [
  {
    sha: 'a1b2c3d',
    message: '添加项目动态展示功能',
    author: 'Developer',
    date: '2024-01-15T10:30:00Z',
    repository: 'PortfolioPulse'
  },
  {
    sha: 'e4f5g6h',
    message: '优化数据库查询性能',
    author: 'Developer',
    date: '2024-01-15T09:15:00Z',
    repository: 'WebAPI-Framework'
  },
  {
    sha: 'i7j8k9l',
    message: '修复响应式布局问题',
    author: 'Developer',
    date: '2024-01-14T16:45:00Z',
    repository: 'PortfolioPulse'
  },
  {
    sha: 'm0n1o2p',
    message: '添加新的图表类型支持',
    author: 'Developer',
    date: '2024-01-14T14:20:00Z',
    repository: 'DataViz-Tools'
  },
  {
    sha: 'q3r4s5t',
    message: '更新API文档',
    author: 'Developer',
    date: '2024-01-13T11:30:00Z',
    repository: 'WebAPI-Framework'
  }
]

export function OptimizedActivitySection() {
  const [activities, setActivities] = useState<GitActivity[]>([])
  const [recentCommits, setRecentCommits] = useState<RecentCommit[]>([])
  const [loading, setLoading] = useState(true)

  // 使用 useCallback 避免重复渲染
  const loadData = useCallback(() => {
    // 同步加载数据，无延迟
    setActivities(MOCK_ACTIVITIES)
    setRecentCommits(MOCK_COMMITS)
    setLoading(false)
  }, [])

  useEffect(() => {
    loadData()
  }, [loadData])

  // 使用 useMemo 缓存计算结果
  const formatDate = useMemo(() => {
    return (dateString: string) => {
      return new Date(dateString).toLocaleDateString('zh-CN', {
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      })
    }
  }, [])

  const getActivityLevel = useCallback((commits: number) => {
    if (commits === 0) return 'bg-gray-100 dark:bg-gray-800'
    if (commits <= 2) return 'bg-green-200 dark:bg-green-900'
    if (commits <= 4) return 'bg-green-400 dark:bg-green-700'
    if (commits <= 6) return 'bg-green-600 dark:bg-green-500'
    return 'bg-green-800 dark:bg-green-300'
  }, [])

  // 快速渲染，无加载状态
  if (loading) {
    return (
      <section className="py-16 px-4 sm:px-6 lg:px-8">
        <div className="max-w-6xl mx-auto">
          <h2 className="text-3xl font-bold text-center mb-12">开发动态</h2>
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
            <div className="h-96 bg-muted rounded-lg animate-pulse"></div>
            <div className="h-96 bg-muted rounded-lg animate-pulse"></div>
          </div>
        </div>
      </section>
    )
  }

  return (
    <section className="py-16 px-4 sm:px-6 lg:px-8">
      <div className="max-w-6xl mx-auto">
        <div className="text-center mb-12">
          <h2 className="text-3xl font-bold mb-4">开发动态</h2>
          <p className="text-muted-foreground max-w-2xl mx-auto">
            实时追踪我的代码提交活动和项目开发进展
          </p>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
          {/* 活动热力图 */}
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                📊 提交活跃度
              </CardTitle>
              <CardDescription>
                最近一周的代码提交活动统计
              </CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {activities.map((activity) => (
                  <div key={activity.date} className="flex items-center justify-between">
                    <div className="flex items-center gap-3">
                      <div
                        className={`w-4 h-4 rounded-sm ${getActivityLevel(activity.commits)}`}
                        title={`${activity.commits} commits`}
                      />
                      <span className="text-sm font-medium">
                        {formatDate(activity.date)}
                      </span>
                    </div>
                    <div className="flex items-center gap-4 text-xs text-muted-foreground">
                      <span>{activity.commits} commits</span>
                      <span className="text-green-600">+{activity.additions}</span>
                      <span className="text-red-600">-{activity.deletions}</span>
                    </div>
                  </div>
                ))}
              </div>

              <div className="mt-6 pt-4 border-t">
                <div className="flex items-center justify-between text-sm">
                  <span className="text-muted-foreground">活跃度等级</span>
                  <div className="flex items-center gap-1">
                    <div className="w-3 h-3 rounded-sm bg-gray-100 dark:bg-gray-800"/>
                    <span className="text-xs mx-1">少</span>
                    <div className="w-3 h-3 rounded-sm bg-green-200 dark:bg-green-900"/>
                    <div className="w-3 h-3 rounded-sm bg-green-400 dark:bg-green-700"/>
                    <div className="w-3 h-3 rounded-sm bg-green-600 dark:bg-green-500"/>
                    <div className="w-3 h-3 rounded-sm bg-green-800 dark:bg-green-300"/>
                    <span className="text-xs mx-1">多</span>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* 最近提交 */}
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                🚀 最近提交
              </CardTitle>
              <CardDescription>
                最新的代码更改和项目进展
              </CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {recentCommits.map((commit) => (
                  <div key={commit.sha} className="flex items-start gap-3 p-3 rounded-lg bg-muted/50">
                    <div className="w-2 h-2 rounded-full bg-green-500 mt-2 shrink-0"/>
                    <div className="flex-1 min-w-0">
                      <p className="font-medium text-sm leading-relaxed">
                        {commit.message}
                      </p>
                      <div className="flex items-center gap-3 mt-1 text-xs text-muted-foreground">
                        <span>{commit.repository}</span>
                        <span>•</span>
                        <span>{formatDate(commit.date)}</span>
                        <span>•</span>
                        <code className="font-mono">{commit.sha}</code>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    </section>
  )
}
