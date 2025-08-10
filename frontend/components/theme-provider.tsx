"use client"

import { ThemeProvider as NextThemesProvider } from "next-themes"
import { type ThemeProviderProps } from "next-themes/dist/types"

export function ThemeProvider({ children, ...props }: Readonly<ThemeProviderProps>) {
  // 移除水合安全检查，因为我们已经在 HTML 级别处理了主题闪烁问题
  return (
    <NextThemesProvider
      {...props}
      // 确保主题提供者不会导致额外的重渲染
      storageKey="theme"
      enableSystem={true}
      disableTransitionOnChange={true}
    >
      {children}
    </NextThemesProvider>
  )
}
