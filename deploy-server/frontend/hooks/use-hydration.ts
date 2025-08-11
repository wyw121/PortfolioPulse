"use client"

import { useEffect, useState } from 'react'

/**
 * 用于避免水合不匹配的 Hook
 * 在服务器端渲染时返回 false，在客户端渲染时返回 true
 */
export function useIsClient() {
  const [isClient, setIsClient] = useState(false)

  useEffect(() => {
    setIsClient(true)
  }, [])

  return isClient
}

/**
 * 用于安全渲染可能导致水合问题的组件
 */
export function useHydrationSafe() {
  const isClient = useIsClient()

  return {
    isClient,
    // 当客户端准备好时才渲染
    canRender: isClient,
  }
}
