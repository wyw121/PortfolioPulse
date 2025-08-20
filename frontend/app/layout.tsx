import { Navigation } from "@/components/layout";
import { PerformanceMonitor } from "@/components/performance-monitor";
import { ThemeProvider } from "@/components/theme-provider";
import { siteConfig } from "@/lib/config";
import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";

const inter = Inter({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: `${siteConfig.name} - ${siteConfig.description}`,
  description: siteConfig.longDescription,
  keywords: siteConfig.keywords.join(", "),
  authors: [{ name: siteConfig.author.name }],
  creator: siteConfig.author.name,
  openGraph: {
    type: "website",
    locale: "zh_CN",
    url: siteConfig.url,
    title: `${siteConfig.name} - ${siteConfig.description}`,
    description: siteConfig.longDescription,
    siteName: siteConfig.name,
  },
  twitter: {
    card: "summary_large_image",
    title: `${siteConfig.name} - ${siteConfig.description}`,
    description: siteConfig.longDescription,
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="zh" suppressHydrationWarning>
      <head>
        <script
          dangerouslySetInnerHTML={{
            __html: `
              (function() {
                function setTheme() {
                  try {
                    const theme = localStorage.getItem('theme') || 'system';
                    const systemDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
                    const prefersDark = theme === 'dark' || (theme === 'system' && systemDark);

                    const root = document.documentElement;
                    if (prefersDark) {
                      root.classList.add('dark');
                      root.style.colorScheme = 'dark';
                    } else {
                      root.classList.remove('dark');
                      root.style.colorScheme = 'light';
                    }
                  } catch (e) {
                    // 如果出现错误，回退到系统偏好
                    const systemDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
                    if (systemDark) {
                      document.documentElement.classList.add('dark');
                    }
                  }
                }

                // 立即设置主题
                setTheme();

                // 监听系统主题变化
                const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)');
                mediaQuery.addListener(function() {
                  const theme = localStorage.getItem('theme') || 'system';
                  if (theme === 'system') {
                    setTheme();
                  }
                });

                // 页面加载完成后启用过渡效果
                function enableTransitions() {
                  document.documentElement.classList.add('transitions-enabled');
                }

                if (document.readyState === 'loading') {
                  window.addEventListener('DOMContentLoaded', function() {
                    setTimeout(enableTransitions, 50);
                  });
                } else {
                  setTimeout(enableTransitions, 50);
                }
              })();
            `,
          }}
        />
      </head>
      <body className={inter.className} suppressHydrationWarning>
        <ThemeProvider
          attribute="class"
          defaultTheme="system"
          enableSystem
          disableTransitionOnChange
        >
          {/* 固定的全局背景渐变 */}
          <div className="fixed inset-0 -z-20 bg-gradient-to-br from-blue-50/30 via-purple-50/20 to-pink-50/30 dark:from-gray-900/90 dark:via-gray-800/80 dark:to-gray-900/90" />

          <Navigation />
          <div className="pt-16 min-h-screen bg-white/50 dark:bg-gray-900/50">
            {children}
          </div>
          <PerformanceMonitor />
        </ThemeProvider>
      </body>
    </html>
  );
}
