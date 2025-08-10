import { Footer } from '@/components/layout/footer'
import { Header } from '@/components/layout/header'
import { ActivitySection } from '@/components/sections/activity'

export default function ActivityPage() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-50 to-slate-100 dark:from-slate-900 dark:to-slate-800">
      <Header />
      <main>
        <ActivitySection />
      </main>
      <Footer />
    </div>
  )
}
