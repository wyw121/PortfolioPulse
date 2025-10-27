import { Navigation } from "@/components/layout";
import { ThemeProvider } from "@/components/theme-provider";
import { SiteConfigProvider } from "@/contexts/site-config-context";
import { siteConfig } from "@/lib/config";
import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";

const inter = Inter({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: {
    default: "wyw121's Portfolio",
    template: "%s | wyw121's Portfolio",
  },
  description: siteConfig.longDescription,
  keywords: siteConfig.keywords.join(", "),
  authors: [{ name: siteConfig.author.name }],
  creator: siteConfig.author.name,
  icons: {
    icon: [
      {
        url: "data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>🔮</text></svg>",
        type: "image/svg+xml",
      },
    ],
  },
  openGraph: {
    type: "website",
    locale: "zh_CN",
    url: siteConfig.url,
    title: "wyw121's Portfolio",
    description: siteConfig.longDescription,
    siteName: siteConfig.name,
  },
  twitter: {
    card: "summary_large_image",
    title: "wyw121's Portfolio",
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
        <SiteConfigProvider>
          <ThemeProvider
            attribute="class"
            defaultTheme="system"
            enableSystem
            disableTransitionOnChange
          >
            <Navigation />
            {children}
          </ThemeProvider>
        </SiteConfigProvider>
      </body>
    </html>
  );
}
