export default function ContactPage() {
  return (
    <div className="vercel-container py-20">
      <div className="max-w-2xl mx-auto">
        <div className="text-center mb-12">
          <h1 className="text-4xl md:text-5xl font-bold mb-4">
            <span className="text-gradient">联系我</span>
          </h1>
          <p className="text-xl text-muted-foreground">
            有项目想法或技术问题？让我们聊聊！
          </p>
        </div>

        <div className="tech-card p-8 rounded-lg">
          <form className="space-y-6">
            <div>
              <label htmlFor="name" className="block text-sm font-medium mb-2">
                姓名
              </label>
              <input
                type="text"
                id="name"
                className="w-full px-4 py-2 border border-border rounded-lg bg-background focus:ring-2 focus:ring-primary focus:border-transparent transition-colors"
                placeholder="请输入您的姓名"
              />
            </div>

            <div>
              <label htmlFor="email" className="block text-sm font-medium mb-2">
                邮箱
              </label>
              <input
                type="email"
                id="email"
                className="w-full px-4 py-2 border border-border rounded-lg bg-background focus:ring-2 focus:ring-primary focus:border-transparent transition-colors"
                placeholder="your@email.com"
              />
            </div>

            <div>
              <label
                htmlFor="subject"
                className="block text-sm font-medium mb-2"
              >
                主题
              </label>
              <input
                type="text"
                id="subject"
                className="w-full px-4 py-2 border border-border rounded-lg bg-background focus:ring-2 focus:ring-primary focus:border-transparent transition-colors"
                placeholder="请输入邮件主题"
              />
            </div>

            <div>
              <label
                htmlFor="message"
                className="block text-sm font-medium mb-2"
              >
                消息
              </label>
              <textarea
                id="message"
                rows={6}
                className="w-full px-4 py-2 border border-border rounded-lg bg-background focus:ring-2 focus:ring-primary focus:border-transparent transition-colors resize-none"
                placeholder="请输入您的消息内容..."
              ></textarea>
            </div>

            <button
              type="submit"
              className="w-full px-6 py-3 bg-gradient-primary text-white rounded-lg font-medium hover-lift"
            >
              发送消息
            </button>
          </form>
        </div>

        {/* 其他联系方式 */}
        <div className="mt-12">
          <div className="text-center mb-6">
            <h2 className="text-xl font-semibold mb-2">其他联系方式</h2>
            <p className="text-muted-foreground">或通过以下方式与我联系</p>
          </div>

          <div className="grid md:grid-cols-3 gap-4">
            <a
              href="#"
              className="tech-card p-4 rounded-lg text-center hover-lift"
            >
              <div className="w-12 h-12 bg-blue-500/10 rounded-lg flex items-center justify-center mx-auto mb-2">
                <span className="text-blue-500 font-semibold">@</span>
              </div>
              <h3 className="font-medium">邮箱</h3>
              <p className="text-sm text-muted-foreground">your@email.com</p>
            </a>

            <a
              href="#"
              className="tech-card p-4 rounded-lg text-center hover-lift"
            >
              <div className="w-12 h-12 bg-purple-500/10 rounded-lg flex items-center justify-center mx-auto mb-2">
                <span className="text-purple-500 font-semibold">GitHub</span>
              </div>
              <h3 className="font-medium">GitHub</h3>
              <p className="text-sm text-muted-foreground">@yourusername</p>
            </a>

            <a
              href="#"
              className="tech-card p-4 rounded-lg text-center hover-lift"
            >
              <div className="w-12 h-12 bg-pink-500/10 rounded-lg flex items-center justify-center mx-auto mb-2">
                <span className="text-pink-500 font-semibold">微信</span>
              </div>
              <h3 className="font-medium">微信</h3>
              <p className="text-sm text-muted-foreground">your_wechat</p>
            </a>
          </div>
        </div>
      </div>
    </div>
  );
}
