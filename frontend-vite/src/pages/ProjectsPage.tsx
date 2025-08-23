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

      <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
        {/* 项目列表占位符 */}
        {Array.from({ length: 6 }, (_, i) => (
          <div key={i} className="tech-card p-6 rounded-lg">
            <div className="w-full h-48 bg-muted rounded-lg mb-4"></div>
            <h3 className="text-xl font-semibold mb-2">项目 {i + 1}</h3>
            <p className="text-muted-foreground mb-4">
              这是一个令人兴奋的项目，展示了现代Web开发的最佳实践...
            </p>
            <div className="flex flex-wrap gap-2 mb-4">
              <span className="px-3 py-1 bg-blue-500/10 text-blue-500 rounded-full text-sm">
                React
              </span>
              <span className="px-3 py-1 bg-purple-500/10 text-purple-500 rounded-full text-sm">
                TypeScript
              </span>
              <span className="px-3 py-1 bg-pink-500/10 text-pink-500 rounded-full text-sm">
                Tailwind
              </span>
            </div>
            <div className="flex justify-between items-center">
              <span className="text-sm text-muted-foreground">2024年8月</span>
              <button className="text-primary hover:text-primary/80 font-medium">
                查看详情 →
              </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
