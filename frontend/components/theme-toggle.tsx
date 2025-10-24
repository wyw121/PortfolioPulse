"use client"

import { Moon, Sun } from "lucide-react"
import { useTheme } from "next-themes"
import { useEffect, useState } from "react"

export function ThemeToggle() {
  const { theme, setTheme } = useTheme()
  const [mounted, setMounted] = useState(false)

  useEffect(() => {
    setMounted(true)
  }, [])

  if (!mounted) {
    return (
      <button 
        className="h-[24px] w-[24px] flex items-center justify-center"
        disabled
        aria-label="切换主题"
      >
        <Sun className="h-[18px] w-[18px]" />
      </button>
    )
  }

  return (
    <button
      id="theme-toggle"
      className="h-[24px] w-[24px] flex items-center justify-center cursor-pointer transition-opacity hover:opacity-70"
      onClick={() => setTheme(theme === "light" ? "dark" : "light")}
      aria-label="切换主题"
      title="切换主题"
    >
      <Moon 
        id="moon"
        className="h-[18px] w-[18px] transition-all duration-300 dark:rotate-0 dark:scale-100 rotate-90 scale-0" 
        strokeWidth={2}
      />
      <Sun 
        id="sun"
        className="absolute h-[18px] w-[18px] transition-all duration-300 dark:rotate-90 dark:scale-0 rotate-0 scale-100" 
        strokeWidth={2}
      />
    </button>
  )
}
