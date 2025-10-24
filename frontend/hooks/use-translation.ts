"use client"

import { getDictionary, getPreferredLocale, type Locale, type Translations } from '@/lib/i18n'
import { useEffect, useState } from 'react'

export function useTranslation() {
  const [locale, setLocale] = useState<Locale>('zh')
  const [dict, setDict] = useState<Translations>(getDictionary('zh'))
  const [mounted, setMounted] = useState(false)

  useEffect(() => {
    setMounted(true)
    const preferredLocale = getPreferredLocale()
    setLocale(preferredLocale)
    setDict(getDictionary(preferredLocale))

    // 监听语言切换事件
    const handleLocaleChange = (e: CustomEvent<Locale>) => {
      setLocale(e.detail)
      setDict(getDictionary(e.detail))
    }

    window.addEventListener('localeChange', handleLocaleChange as EventListener)
    return () => {
      window.removeEventListener('localeChange', handleLocaleChange as EventListener)
    }
  }, [])

  return { locale, dict, mounted }
}
