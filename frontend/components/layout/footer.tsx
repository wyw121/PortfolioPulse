import { siteConfig } from '@/lib/config'

export function Footer() {
  const currentYear = new Date().getFullYear()

  return (
    <footer className="border-t bg-background">
      <div className="container py-8">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          <div>
            <div className="flex items-center space-x-2 mb-4">
              <div className="h-6 w-6 bg-gradient-to-r from-purple-600 to-blue-600 rounded flex items-center justify-center">
                <span className="text-white font-bold text-xs">{siteConfig.shortName}</span>
              </div>
              <span className="font-semibold">{siteConfig.name}</span>
            </div>
            <p className="text-sm text-muted-foreground">
              {siteConfig.description}
            </p>
          </div>

          <div>
            <h3 className="font-semibold mb-3">快速导航</h3>
            <ul className="space-y-2 text-sm">
              <li>
                <a href="#projects" className="text-muted-foreground hover:text-primary transition-colors">
                  项目展示
                </a>
              </li>
              <li>
                <a href="#activity" className="text-muted-foreground hover:text-primary transition-colors">
                  开发动态
                </a>
              </li>
              <li>
                <a href="/about" className="text-muted-foreground hover:text-primary transition-colors">
                  关于 {siteConfig.name}
                </a>
              </li>
            </ul>
          </div>

          <div>
            <h3 className="font-semibold mb-3">技术栈</h3>
            <ul className="space-y-2 text-sm text-muted-foreground">
              <li>Next.js 15</li>
              <li>TypeScript</li>
              <li>Tailwind CSS</li>
              <li>Rust Backend</li>
            </ul>
          </div>
        </div>

        <div className="border-t mt-8 pt-8 flex flex-col sm:flex-row justify-between items-center">
          <p className="text-sm text-muted-foreground">
            © {currentYear} {siteConfig.name}. 保留所有权利。
          </p>
          <p className="text-sm text-muted-foreground">
            基于 sindresorhus.com 设计理念
          </p>
        </div>
      </div>
    </footer>
  )
}
