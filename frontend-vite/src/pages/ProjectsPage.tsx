import { ProjectGrid } from "../components/ProjectGrid";

export default function ProjectsPage() {
  return (
    <div className="vercel-container py-20">
      <div className="text-center mb-12">
        <h1 className="text-4xl md:text-5xl font-bold mb-4">
          <span className="text-gradient">我的项目</span>
        </h1>
        <p className="text-xl text-muted-foreground max-w-2xl mx-auto">
          探索我的技术项目和开源贡献
        </p>
      </div>

      <ProjectGrid />
    </div>
  );
}
