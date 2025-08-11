"use client"

import { ThemeProvider as NextThemesProvider } from "next-themes"
import { type ThemeProviderProps } from "next-themes/dist/types"

export function ThemeProvider({ children, ...props }: Readonly<ThemeProviderProps>) {
  return (
    <NextThemesProvider
      {...props}
      // 确保主题提供者不会导致额外的重渲染
      storageKey="theme"
      enableSystem={true}
      disableTransitionOnChange={false}
      defaultTheme="system"
    >
      {children}
    </NextThemesProvider>
  )
}
