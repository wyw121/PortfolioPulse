"use client";

import { ProjectGrid } from "@/components/portfolio";
import { AnimatedContainer } from "@/components/ui/effects";
import { useTranslation } from "@/hooks/use-translation";

export default function ProjectsPage() {
  const { dict } = useTranslation();

  return (
    <div className="min-h-screen bg-bg-primary dark:bg-gray-900">
      {/* 背景渐变效果 */
      <div className="fixed inset-0 -z-10 bg-gradient-to-br from-blue-50/30 via-purple-50/20 to-pink-50/30 dark:from-gray-900/90 dark:via-gray-800/80 dark:to-gray-900/90" />

      <main className="pt-24">
        <div className="max-w-6xl mx-auto px-6 py-12">
          <AnimatedContainer direction="up" duration={600}>
            <div className="text-center mb-12">
              <h1 className="text-4xl md:text-5xl font-bold mb-6 bg-gradient-to-r from-blue-500 via-purple-500 to-pink-500 bg-clip-text text-transparent leading-tight pb-2">
                {dict.projects.title}
              </h1>
              <p className="text-lg text-gray-600 dark:text-gray-300 max-w-3xl mx-auto">
                {dict.projects.subtitle}
              </p>
            </div>
          </AnimatedContainer>
        </div>

        <ProjectGrid />
      </main>
    </div>
  );
}
