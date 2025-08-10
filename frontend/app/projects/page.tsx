import { Footer } from '@/components/layout/footer'
import { Header } from '@/components/layout/header'
import { ProjectsSection } from '@/components/sections/projects'

export default function ProjectsPage() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-50 to-slate-100 dark:from-slate-900 dark:to-slate-800 flex flex-col">
      <Header />
      <main className="flex-1">
        <ProjectsSection />
      </main>
      <Footer />
    </div>
  )
}
