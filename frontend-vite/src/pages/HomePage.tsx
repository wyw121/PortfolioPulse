export default function HomePage() {
  return (
    <div className="homepage-container">
      {/* Hero Section */}
      <section className="vercel-container py-20 lg:py-32">
        <div className="text-center max-w-4xl mx-auto">
          <h1 className="text-4xl md:text-6xl lg:text-7xl font-bold mb-6">
            <span className="text-gradient">PortfolioPulse</span>
          </h1>
          <p className="text-xl md:text-2xl text-muted-foreground mb-8 max-w-2xl mx-auto">
            现代化的个人项目展示和动态追踪平台
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <button className="px-8 py-3 bg-gradient-primary text-white rounded-lg font-medium hover-lift">
              查看项目
            </button>
            <button className="px-8 py-3 border border-border rounded-lg font-medium hover-lift">
              了解更多
            </button>
          </div>
        </div>
      </section>

      {/* 项目预览 */}
      <section className="vercel-container py-20">
        <div className="text-center mb-12">
          <h2 className="text-3xl md:text-4xl font-bold mb-4">精选项目</h2>
          <p className="text-muted-foreground max-w-2xl mx-auto">
            展示我最新的开发项目和技术探索
          </p>
        </div>

        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
          {/* 项目卡片占位符 */}
          {[1, 2, 3].map((i) => (
            <div key={i} className="tech-card p-6 rounded-lg">
              <div className="w-full h-48 bg-muted rounded-lg mb-4"></div>
              <h3 className="text-xl font-semibold mb-2">项目 {i}</h3>
              <p className="text-muted-foreground mb-4">项目描述...</p>
              <div className="flex flex-wrap gap-2">
                <span className="px-3 py-1 bg-primary/10 text-primary rounded-full text-sm">
                  React
                </span>
                <span className="px-3 py-1 bg-primary/10 text-primary rounded-full text-sm">
                  TypeScript
                </span>
              </div>
            </div>
          ))}
        </div>
      </section>
    </div>
  );
}
