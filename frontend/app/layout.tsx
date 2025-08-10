import { ThemeProvider } from '@/components/theme-provider'
import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: 'PortfolioPulse - 个人项目动态展示平台',
  description: '现代化的个人项目展示和动态追踪平台，集成多个个人项目到统一的主页中',
  keywords: 'portfolio, projects, git, github, development, showcase',
  authors: [{ name: 'PortfolioPulse' }],
  creator: 'PortfolioPulse',
  openGraph: {
    type: 'website',
    locale: 'zh_CN',
    url: 'https://your-domain.com',
    title: 'PortfolioPulse - 个人项目动态展示平台',
    description: '现代化的个人项目展示和动态追踪平台',
    siteName: 'PortfolioPulse',
  },
  twitter: {
    card: 'summary_large_image',
    title: 'PortfolioPulse - 个人项目动态展示平台',
    description: '现代化的个人项目展示和动态追踪平台',
  },
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="zh" suppressHydrationWarning>
      <body className={inter.className}>
        <ThemeProvider
          attribute="class"
          defaultTheme="system"
          enableSystem
          disableTransitionOnChange
        >
          {children}
        </ThemeProvider>
      </body>
    </html>
  )
}
