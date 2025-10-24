"use client"

import {
  getPreferredLocale,
  saveLocalePreference,
  type Locale,
} from "@/lib/i18n"
import { useEffect, useState } from "react"

export function LanguageSwitcher() {
  const [currentLocale, setCurrentLocale] = useState<Locale>('zh')
  const [mounted, setMounted] = useState(false)

  useEffect(() => {
    setMounted(true)
    const locale = getPreferredLocale()
    setCurrentLocale(locale)
  }, [])

  const switchLanguage = () => {
    const newLocale: Locale = currentLocale === 'zh' ? 'en' : 'zh'
    setCurrentLocale(newLocale)
    saveLocalePreference(newLocale)
    
    // 触发自定义事件通知其他组件语言已更改
    window.dispatchEvent(new CustomEvent('localeChange', { detail: newLocale }))
  }

  // 显示目标语言(不是当前语言)
  const targetLanguage = currentLocale === 'zh' ? 'En' : 'Zh'

  if (!mounted) {
    return (
      <button 
        className="text-sm cursor-pointer transition-opacity hover:opacity-70"
        disabled
      >
        En
      </button>
    )
  }

  return (
    <button
      onClick={switchLanguage}
      className="text-sm cursor-pointer transition-opacity hover:opacity-70 font-medium text-gray-700 dark:text-gray-300"
      title={currentLocale === 'zh' ? '切换到英文' : 'Switch to Chinese'}
      aria-label={currentLocale === 'zh' ? '切换到英文' : 'Switch to Chinese'}
    >
      {targetLanguage}
    </button>
  )
}
