import enTranslations from '@/locales/en.json'
import zhTranslations from '@/locales/zh.json'

export type Locale = 'en' | 'zh'

export type Translations = typeof zhTranslations

const dictionaries: Record<Locale, Translations> = {
  en: enTranslations,
  zh: zhTranslations,
}

export function getDictionary(locale: Locale): Translations {
  return dictionaries[locale] || dictionaries.zh
}

export const locales: Locale[] = ['en', 'zh']

export const localeNames: Record<Locale, string> = {
  en: 'English',
  zh: '中文',
}

export const localeFlags: Record<Locale, string> = {
  en: '🇺🇸',
  zh: '🇨🇳',
}

// 从浏览器获取首选语言
export function getPreferredLocale(): Locale {
  if (typeof window === 'undefined') return 'zh'
  
  const stored = localStorage.getItem('locale') as Locale
  if (stored && locales.includes(stored)) return stored
  
  const browserLang = navigator.language.split('-')[0]
  return locales.includes(browserLang as Locale) ? (browserLang as Locale) : 'zh'
}

// 保存语言偏好
export function saveLocalePreference(locale: Locale) {
  if (typeof window !== 'undefined') {
    localStorage.setItem('locale', locale)
  }
}
