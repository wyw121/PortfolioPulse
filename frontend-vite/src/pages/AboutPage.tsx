export default function AboutPage() {
  return (
    <div className="vercel-container py-20">
      <div className="max-w-4xl mx-auto">
        <div className="text-center mb-12">
          <h1 className="text-4xl md:text-5xl font-bold mb-4">
            <span className="text-gradient">关于我</span>
          </h1>
          <p className="text-xl text-muted-foreground">
            热爱技术，追求卓越的全栈开发者
          </p>
        </div>

        <div className="space-y-12">
          {/* 个人简介 */}
          <section className="tech-card p-8 rounded-lg">
            <h2 className="text-2xl font-semibold mb-4">个人简介</h2>
            <p className="text-muted-foreground leading-relaxed">
              我是一名充满激情的全栈开发者，专注于构建现代化的Web应用程序。
              我热衷于探索新技术，追求代码的优雅和用户体验的极致。
              在技术选型上，我偏爱Rust、TypeScript、React等现代化技术栈。
            </p>
          </section>

          {/* 技能栈 */}
          <section className="tech-card p-8 rounded-lg">
            <h2 className="text-2xl font-semibold mb-6">技能栈</h2>
            <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
              <div>
                <h3 className="font-semibold mb-3 text-blue-500">前端开发</h3>
                <div className="space-y-2">
                  {[
                    "React",
                    "TypeScript",
                    "Next.js",
                    "Tailwind CSS",
                    "Vite",
                  ].map((skill) => (
                    <div key={skill} className="flex items-center">
                      <div className="w-2 h-2 bg-blue-500 rounded-full mr-2" />
                      <span className="text-sm">{skill}</span>
                    </div>
                  ))}
                </div>
              </div>

              <div>
                <h3 className="font-semibold mb-3 text-purple-500">后端开发</h3>
                <div className="space-y-2">
                  {["Rust", "Axum", "Node.js", "MySQL", "API设计"].map(
                    (skill) => (
                      <div key={skill} className="flex items-center">
                        <div className="w-2 h-2 bg-purple-500 rounded-full mr-2" />
                        <span className="text-sm">{skill}</span>
                      </div>
                    )
                  )}
                </div>
              </div>

              <div>
                <h3 className="font-semibold mb-3 text-pink-500">工具和平台</h3>
                <div className="space-y-2">
                  {["Git", "Docker", "VS Code", "Linux", "GitHub Actions"].map(
                    (skill) => (
                      <div key={skill} className="flex items-center">
                        <div className="w-2 h-2 bg-pink-500 rounded-full mr-2" />
                        <span className="text-sm">{skill}</span>
                      </div>
                    )
                  )}
                </div>
              </div>
            </div>
          </section>

          {/* 联系方式 */}
          <section className="tech-card p-8 rounded-lg">
            <h2 className="text-2xl font-semibold mb-4">联系方式</h2>
            <p className="text-muted-foreground mb-4">
              欢迎与我交流技术话题或项目合作
            </p>
            <div className="flex flex-wrap gap-4">
              <a
                href="/contact"
                className="px-6 py-2 bg-gradient-primary text-white rounded-lg hover-lift"
              >
                发送消息
              </a>
              <a
                href="#"
                className="px-6 py-2 border border-border rounded-lg hover-lift"
              >
                GitHub
              </a>
            </div>
          </section>
        </div>
      </div>
    </div>
  );
}
