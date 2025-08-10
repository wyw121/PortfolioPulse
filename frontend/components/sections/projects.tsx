"use client"

import { useState, useEffect } from 'react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { ExternalLink, Github, Star, GitFork } from 'lucide-react'

interface Project {
  id: number
  name: string
  description: string
  html_url: string
  homepage?: string
  language: string
  stargazers_count: number
  forks_count: number
  updated_at: string
  topics: string[]
}

export function ProjectsSection() {
  const [projects, setProjects] = useState<Project[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    // 模拟数据，实际应从后端API获取
    const mockProjects: Project[] = [
      {
        id: 1,
        name: "PortfolioPulse",
        description: "现代化的个人项目展示和动态追踪平台",
        html_url: "https://github.com/user/PortfolioPulse",
        homepage: "https://portfoliopulse.dev",
        language: "TypeScript",
        stargazers_count: 42,
        forks_count: 8,
        updated_at: "2024-01-15T10:30:00Z",
        topics: ["nextjs", "react", "typescript", "portfolio"]
      },
      {
        id: 2,
        name: "WebAPI-Framework",
        description: "基于 Rust 的高性能 Web API 框架",
        html_url: "https://github.com/user/webapi-framework",
        language: "Rust",
        stargazers_count: 128,
        forks_count: 23,
        updated_at: "2024-01-10T14:20:00Z",
        topics: ["rust", "webapi", "performance", "framework"]
      },
      {
        id: 3,
        name: "DataViz-Tools",
        description: "交互式数据可视化工具集",
        html_url: "https://github.com/user/dataviz-tools",
        homepage: "https://dataviz-tools.demo.com",
        language: "Python",
        stargazers_count: 67,
        forks_count: 15,
        updated_at: "2024-01-08T09:15:00Z",
        topics: ["python", "visualization", "data-analysis", "charts"]
      }
    ]

    setTimeout(() => {
      setProjects(mockProjects)
      setLoading(false)
    }, 1000)
  }, [])

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('zh-CN', {
      year: 'numeric',
      month: 'short',
      day: 'numeric'
    })
  }

  const getLanguageColor = (language: string) => {
    const colors: Record<string, string> = {
      'TypeScript': 'bg-blue-500',
      'JavaScript': 'bg-yellow-500',
      'Python': 'bg-green-500',
      'Rust': 'bg-red-500',
      'Go': 'bg-cyan-500',
      'Java': 'bg-orange-500'
    }
    return colors[language] || 'bg-gray-500'
  }

  if (loading) {
    return (
      <section className="py-16 px-4 sm:px-6 lg:px-8">
        <div className="max-w-6xl mx-auto">
          <h2 className="text-3xl font-bold text-center mb-12">项目展示</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {[1, 2, 3].map((i) => (
              <div key={i} className="h-64 bg-muted rounded-lg animate-pulse"></div>
            ))}
          </div>
        </div>
      </section>
    )
  }

  if (error) {
    return (
      <section className="py-16 px-4 sm:px-6 lg:px-8">
        <div className="max-w-6xl mx-auto text-center">
          <h2 className="text-3xl font-bold mb-8">项目展示</h2>
          <p className="text-red-500">{error}</p>
        </div>
      </section>
    )
  }

  return (
    <section className="py-16 px-4 sm:px-6 lg:px-8">
      <div className="max-w-6xl mx-auto">
        <h2 className="text-3xl font-bold text-center mb-12">项目展示</h2>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {projects.map((project) => (
            <Card key={project.id} className="project-card-hover">
              <CardHeader>
                <div className="flex items-center justify-between">
                  <CardTitle className="text-lg">{project.name}</CardTitle>
                  <div className="flex items-center gap-2">
                    <div className={`w-3 h-3 rounded-full ${getLanguageColor(project.language)}`}></div>
                    <span className="text-sm text-muted-foreground">{project.language}</span>
                  </div>
                </div>
                <CardDescription className="line-clamp-2">
                  {project.description}
                </CardDescription>
              </CardHeader>

              <CardContent>
                <div className="flex items-center gap-4 mb-4 text-sm text-muted-foreground">
                  <div className="flex items-center gap-1">
                    <Star className="h-4 w-4" />
                    {project.stargazers_count}
                  </div>
                  <div className="flex items-center gap-1">
                    <GitFork className="h-4 w-4" />
                    {project.forks_count}
                  </div>
                </div>

                <div className="flex flex-wrap gap-2 mb-4">
                  {project.topics.slice(0, 3).map((topic) => (
                    <span
                      key={topic}
                      className="px-2 py-1 text-xs bg-secondary text-secondary-foreground rounded"
                    >
                      {topic}
                    </span>
                  ))}
                </div>

                <div className="flex gap-2">
                  <Button variant="outline" size="sm" asChild>
                    <a href={project.html_url} target="_blank" rel="noopener noreferrer">
                      <Github className="h-4 w-4 mr-1" />
                      代码
                    </a>
                  </Button>
                  {project.homepage && (
                    <Button variant="outline" size="sm" asChild>
                      <a href={project.homepage} target="_blank" rel="noopener noreferrer">
                        <ExternalLink className="h-4 w-4 mr-1" />
                        演示
                      </a>
                    </Button>
                  )}
                </div>

                <div className="mt-4 text-xs text-muted-foreground">
                  更新于 {formatDate(project.updated_at)}
                </div>
              </CardContent>
            </Card>
          ))}
        </div>

        <div className="text-center mt-12">
          <Button variant="outline" size="lg">
            <Github className="h-5 w-5 mr-2" />
            查看更多项目
          </Button>
        </div>
      </div>
    </section>
  )
}
