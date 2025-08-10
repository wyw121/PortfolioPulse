import { Footer } from '@/components/layout/footer'
import { Header } from '@/components/layout/header'
import { About } from '@/components/sections/about'
import { siteConfig } from '@/lib/config'
import type { Metadata } from 'next'

export const metadata: Metadata = {
  title: `关于 ${siteConfig.name} - ${siteConfig.description}`,
  description: siteConfig.longDescription,
}

export default function AboutPage() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-50 to-slate-100 dark:from-slate-900 dark:to-slate-800">
      <Header />
      <main className="pt-16">
        <About />
      </main>
      <Footer />
    </div>
  )
}
