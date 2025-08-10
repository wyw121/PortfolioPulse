"use client"

import { useEffect, useState } from 'react'

interface ClientLayoutProps {
  children: React.ReactNode
  className?: string
}

export function ClientLayout({ children, className }: ClientLayoutProps) {
  const [mounted, setMounted] = useState(false)

  useEffect(() => {
    setMounted(true)
  }, [])

  // 在服务器端渲染时，不应用可能冲突的类名
  if (!mounted) {
    return <div className={className}>{children}</div>
  }

  // 客户端渲染时，可以安全地应用所有类名
  return <div className={className}>{children}</div>
}
