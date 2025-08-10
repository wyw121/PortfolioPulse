"use client"

import * as React from "react"
import { ThemeProvider as NextThemesProvider } from "next-themes"
import { type ThemeProviderProps } from "next-themes/dist/types"
import { useHydrationSafe } from "@/hooks/use-hydration"

export function ThemeProvider({ children, ...props }: ThemeProviderProps) {
  const { canRender } = useHydrationSafe()

  if (!canRender) {
    // 在服务器端和初始客户端渲染时，返回没有主题提供者的版本
    return <>{children}</>
  }

  return <NextThemesProvider {...props}>{children}</NextThemesProvider>
}
