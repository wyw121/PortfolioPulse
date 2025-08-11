"use client"

import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { useEffect, useState } from 'react'

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

export function ActivitySection() {
  const [activities, setActivities] = useState<GitActivity[]>([])
  const [recentCommits, setRecentCommits] = useState<RecentCommit[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    // 模拟数据，实际应从后端API获取
    const mockActivities: GitActivity[] = [
      { date: '2024-01-15', commits: 5, additions: 150, deletions: 32 },
      { date: '2024-01-14', commits: 3, additions: 89, deletions: 15 },
      { date: '2024-01-13', commits: 8, additions: 234, deletions: 67 },
      { date: '2024-01-12', commits: 2, additions: 45, deletions: 8 },
      { date: '2024-01-11', commits: 6, additions: 178, deletions: 43 },
      { date: '2024-01-10', commits: 4, additions: 112, deletions: 28 },
      { date: '2024-01-09', commits: 1, additions: 23, deletions: 5 }
    ]

    const mockCommits: RecentCommit[] = [
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

    // 移除人为延迟，直接设置数据
    setActivities(mockActivities)
    setRecentCommits(mockCommits)
    setLoading(false)
  }, [])

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('zh-CN', {
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    })
  }

  const getActivityLevel = (commits: number) => {
    if (commits === 0) return 'bg-gray-100 dark:bg-gray-800'
    if (commits <= 2) return 'bg-green-200 dark:bg-green-900'
    if (commits <= 4) return 'bg-green-400 dark:bg-green-700'
    if (commits <= 6) return 'bg-green-600 dark:bg-green-500'
    return 'bg-green-800 dark:bg-green-300'
  }

  if (loading) {
    return (
      <section className="py-16 px-4 sm:px-6 lg:px-8 bg-muted/50">
        <div className="max-w-6xl mx-auto">
          <h2 className="text-3xl font-bold text-center mb-12">开发动态</h2>
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
            <div className="h-64 bg-card rounded-lg animate-pulse"></div>
            <div className="h-64 bg-card rounded-lg animate-pulse"></div>
          </div>
        </div>
      </section>
    )
  }

  return (
    <section className="py-16 px-4 sm:px-6 lg:px-8 bg-muted/50">
      <div className="max-w-6xl mx-auto">
        <h2 className="text-3xl font-bold text-center mb-12">开发动态</h2>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
          {/* 活动热力图 */}
          <Card>
            <CardHeader>
              <CardTitle>提交活动</CardTitle>
              <CardDescription>过去一周的提交统计</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-7 gap-2">
                {activities.map((activity) => (
                  <div key={activity.date} className="text-center">
                    <div className="text-xs text-muted-foreground mb-2">
                      {new Date(activity.date).toLocaleDateString('zh-CN', { weekday: 'short' })}
                    </div>
                    <div
                      className={`w-8 h-8 rounded ${getActivityLevel(activity.commits)} flex items-center justify-center text-xs font-semibold`}
                      title={`${activity.date}: ${activity.commits} commits`}
                    >
                      {activity.commits}
                    </div>
                  </div>
                ))}
              </div>

              <div className="mt-6 space-y-2">
                <div className="flex justify-between text-sm">
                  <span className="text-muted-foreground">本周总计</span>
                  <span className="font-semibold">
                    {activities.reduce((sum, activity) => sum + activity.commits, 0)} 次提交
                  </span>
                </div>
                <div className="flex justify-between text-sm">
                  <span className="text-muted-foreground">代码变更</span>
                  <span className="text-green-600">
                    +{activities.reduce((sum, activity) => sum + activity.additions, 0)}{' '}
                    <span className="text-red-600">
                      -{activities.reduce((sum, activity) => sum + activity.deletions, 0)}
                    </span>
                  </span>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* 最近提交 */}
          <Card>
            <CardHeader>
              <CardTitle>最近提交</CardTitle>
              <CardDescription>最新的开发活动记录</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {recentCommits.map((commit) => (
                  <div key={commit.sha} className="border-l-2 border-muted pl-4">
                    <div className="flex items-start justify-between">
                      <div className="flex-1">
                        <p className="text-sm font-medium">{commit.message}</p>
                        <div className="flex items-center gap-2 mt-1 text-xs text-muted-foreground">
                          <span className="px-2 py-1 bg-muted rounded text-xs">
                            {commit.repository}
                          </span>
                          <span>{commit.sha}</span>
                        </div>
                      </div>
                      <div className="text-xs text-muted-foreground text-right">
                        <div>{formatDate(commit.date)}</div>
                        <div>{commit.author}</div>
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
