"use client";

import { AnimatedContainer } from "@/components/ui/effects";
import { LanguageSwitcher } from "@/components/language-switcher";
import { ThemeToggle } from "@/components/theme-toggle";
import { useSiteConfig } from "@/contexts/site-config-context";
import { useTranslation } from "@/hooks/use-translation";
import Link from "next/link";

export function Header() {
  const { dict } = useTranslation();
  const config = useSiteConfig();

  return (
    <AnimatedContainer
      direction="down"
      duration={600}
      className="sticky top-0 z-50 w-full border-b border-gray-200 dark:border-gray-800 bg-white/90 dark:bg-gray-900/90 backdrop-blur-md supports-[backdrop-filter]:bg-white/60 supports-[backdrop-filter]:dark:bg-gray-900/60"
    >
      <header className="header">
        <nav className="nav">
          {/* Logo + Switches */}
          <div className="logo flex items-center">
            <Link 
              href="/" 
              className="mr-3 text-xl font-bold text-gray-900 dark:text-white hover:opacity-80 transition-opacity"
              title={config.name}
            >
              {config.name}
            </Link>
            
            {/* Logo Switches - 紧跟 Logo 右侧 */}
            <div className="logo-switches flex items-center space-x-3">
              <ThemeToggle />
              <LanguageSwitcher />
            </div>
          </div>

          {/* Navigation Menu */}
          <ul id="menu" className="hidden md:flex items-center space-x-8">
            <li>
              <Link
                href="/"
                className="text-sm font-medium text-gray-600 dark:text-gray-300 hover:text-gray-900 dark:hover:text-white transition-colors"
              >
                <span>{dict.nav.home}</span>
              </Link>
            </li>
            <li>
              <Link
                href="/projects"
                className="text-sm font-medium text-gray-600 dark:text-gray-300 hover:text-gray-900 dark:hover:text-white transition-colors"
              >
                <span>{dict.nav.projects}</span>
              </Link>
            </li>
            <li>
              <Link
                href="/blog"
                className="text-sm font-medium text-gray-600 dark:text-gray-300 hover:text-gray-900 dark:hover:text-white transition-colors"
              >
                <span>{dict.nav.blog}</span>
              </Link>
            </li>
            <li>
              <Link
                href="/about"
                className="text-sm font-medium text-gray-600 dark:text-gray-300 hover:text-gray-900 dark:hover:text-white transition-colors"
              >
                <span>{dict.nav.about}</span>
              </Link>
            </li>
          </ul>
        </nav>
      </header>
    </AnimatedContainer>
  );
}
