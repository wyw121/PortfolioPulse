export default function BlogPage() {
  return (
    <div className="vercel-container py-20">
      <div className="text-center mb-12">
        <h1 className="text-4xl md:text-5xl font-bold mb-4">
          <span className="text-gradient">技术博客</span>
        </h1>
        <p className="text-xl text-muted-foreground max-w-2xl mx-auto">
          分享我的技术见解和开发经验
        </p>
      </div>

      <div className="max-w-4xl mx-auto">
        <div className="space-y-8">
          {/* 博客文章列表 */}
          {Array.from({ length: 5 }, (_, i) => (
            <article key={i} className="tech-card p-6 rounded-lg">
              <div className="flex flex-col md:flex-row gap-6">
                <div className="md:w-1/3">
                  <div className="w-full h-32 bg-muted rounded-lg"></div>
                </div>
                <div className="md:w-2/3">
                  <h2 className="text-xl font-semibold mb-2 hover:text-primary transition-colors">
                    如何使用 Rust 构建高性能 Web 服务
                  </h2>
                  <p className="text-muted-foreground mb-4">
                    在这篇文章中，我将分享使用 Rust 和 Axum 框架构建现代化 Web
                    服务的经验， 包括性能优化、错误处理和最佳实践...
                  </p>
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-4">
                      <span className="text-sm text-muted-foreground">
                        2024年8月{20 + i}日
                      </span>
                      <div className="flex gap-2">
                        <span className="px-2 py-1 bg-blue-500/10 text-blue-500 rounded text-xs">
                          Rust
                        </span>
                        <span className="px-2 py-1 bg-purple-500/10 text-purple-500 rounded text-xs">
                          Web开发
                        </span>
                      </div>
                    </div>
                    <button className="text-primary hover:text-primary/80 font-medium">
                      阅读更多 →
                    </button>
                  </div>
                </div>
              </div>
            </article>
          ))}
        </div>

        {/* 分页 */}
        <div className="flex justify-center mt-12">
          <div className="flex gap-2">
            <button className="px-4 py-2 border border-border rounded-lg hover-lift">
              上一页
            </button>
            <button className="px-4 py-2 bg-primary text-primary-foreground rounded-lg">
              1
            </button>
            <button className="px-4 py-2 border border-border rounded-lg hover-lift">
              2
            </button>
            <button className="px-4 py-2 border border-border rounded-lg hover-lift">
              3
            </button>
            <button className="px-4 py-2 border border-border rounded-lg hover-lift">
              下一页
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
