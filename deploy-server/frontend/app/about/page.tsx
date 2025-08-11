import {
  AboutContact,
  AboutExperience,
  AboutHero,
  AboutSkills,
} from "@/components/about";
import { Navigation } from "@/components/layout";

export default function AboutPage() {
  return (
    <div className="min-h-screen bg-white dark:bg-gray-900">
      {/* 背景渐变效果 */}
      <div className="fixed inset-0 -z-10 bg-gradient-to-br from-blue-50/30 via-purple-50/20 to-pink-50/30 dark:from-gray-900/90 dark:via-gray-800/80 dark:to-gray-900/90" />

      <Navigation />

      <main className="pt-20">
        <AboutHero />
        <AboutSkills />
        <AboutExperience />
        <AboutContact />
      </main>
    </div>
  );
}
