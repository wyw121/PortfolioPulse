import { ProjectGrid } from "@/components/portfolio";
import { AnimatedContainer } from "@/components/ui/effects";

export default function ProjectsPage() {
  return (
    <main className="pt-4">
      <div className="max-w-6xl mx-auto px-6 py-12">
        <AnimatedContainer direction="up" duration={600}>
          <div className="text-center mb-12">
            <h1 className="text-4xl md:text-5xl font-bold mb-6 bg-gradient-to-r from-blue-500 via-purple-500 to-pink-500 bg-clip-text text-transparent">
              我的项目
            </h1>
            <p className="text-lg text-gray-600 dark:text-gray-300 max-w-3xl mx-auto">
              这里展示了我在不同技术领域的探索和实践，从Web应用到开源工具，每个项目都代表着一次学习和成长的经历。
            </p>
          </div>
        </AnimatedContainer>
      </div>

      <ProjectGrid />
    </main>
  );
}
