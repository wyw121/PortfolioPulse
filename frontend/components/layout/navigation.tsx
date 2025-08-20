"use client";

import { motion } from "framer-motion";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { useState } from "react";

interface NavItem {
  name: string;
  href: string;
}

const navItems: NavItem[] = [
  { name: "首页", href: "/" },
  { name: "项目", href: "/projects" },
  { name: "博客", href: "/blog" },
  { name: "关于", href: "/about" },
];

export const Navigation = () => {
  const pathname = usePathname();
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  // 根据当前路径决定显示的Logo - 参考Sindre Sorhus风格
  const isHomePage = pathname === "/";
  const logoContent = isHomePage ? "🔮" : "Vynix";

  return (
    <motion.nav
      className="sticky top-0 w-full z-50 backdrop-blur-md bg-white/95 dark:bg-gray-900/95 border-b border-gray-200/80 dark:border-gray-800/80 transition-all duration-150"
      initial={{ opacity: 1, y: 0 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.15 }}
    >
      <div className="max-w-6xl mx-auto px-3 md:px-4">
        <div className="flex items-center justify-between py-3">
          {/* Logo - 参考Sindre Sorhus风格 */}
          <Link href="/" className="flex items-center">
            <span
              className={`ml-2 font-extrabold transition-all duration-150 whitespace-nowrap ${
                isHomePage
                  ? "text-2xl hover:scale-110"
                  : "text-2xl bg-gradient-to-r from-blue-500 via-purple-500 to-pink-500 bg-clip-text text-transparent hover:scale-105"
              }`}
            >
              {logoContent}
            </span>
          </Link>

          {/* Desktop Navigation - Sindre风格精确间距 */}
          <nav className="hidden md:flex items-center">
            <ul className="flex md:flex-row text-gray-600 dark:text-slate-200 text-base space-x-1">
              {navItems.map((item) => {
                const isActive = pathname === item.href;
                return (
                  <li key={item.name}>
                    <Link
                      href={item.href}
                      className={`px-4 py-3 font-medium transition duration-150 ease-in-out flex items-center ${
                        isActive
                          ? "text-white bg-gradient-to-r from-blue-500 via-purple-500 to-pink-500 rounded-lg shadow-lg shadow-blue-500/25"
                          : "text-gray-700 dark:text-gray-300 hover:text-blue-500 dark:hover:text-blue-400 hover:bg-gray-100/50 dark:hover:bg-gray-800/50 rounded-lg"
                      }`}
                    >
                      {item.name}
                    </Link>
                  </li>
                );
              })}
            </ul>
          </nav>

          {/* Mobile Menu Button - Sindre风格 */}
          <button
            className="md:hidden ml-1.5 text-gray-500 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800 focus:outline-hidden focus:ring-4 focus:ring-gray-200 dark:focus:ring-gray-700 rounded-lg text-sm p-2.5 inline-flex items-center transition"
            onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
            aria-label="Toggle Menu"
          >
            <svg
              className="h-5 w-5"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              {mobileMenuOpen ? (
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M6 18L18 6M6 6l12 12"
                />
              ) : (
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M4 6h16M4 12h16M4 18h16"
                />
              )}
            </svg>
          </button>
        </div>

        {/* Mobile Navigation - Sindre风格 */}
        {mobileMenuOpen && (
          <motion.div
            className="md:hidden"
            initial={{ opacity: 0, height: 0, y: -10 }}
            animate={{ opacity: 1, height: "auto", y: 0 }}
            exit={{ opacity: 0, height: 0, y: -10 }}
            transition={{ duration: 0.3, ease: "easeOut" }}
          >
            <nav className="items-center w-full text-gray-600 dark:text-slate-200 h-screen md:h-auto">
              <ul className="flex flex-col pt-8 w-full text-xl">
                {navItems.map((item) => {
                  const isActive = pathname === item.href;
                  return (
                    <li key={item.name}>
                      <Link
                        href={item.href}
                        className={`px-4 py-3 font-medium transition duration-150 ease-in-out flex items-center ${
                          isActive
                            ? "text-white bg-gradient-to-r from-blue-500 via-purple-500 to-pink-500 rounded-lg shadow-lg shadow-blue-500/25"
                            : "text-gray-700 dark:text-gray-300 hover:text-blue-500 dark:hover:text-blue-400 hover:bg-gray-100/50 dark:hover:bg-gray-800/50 rounded-lg"
                        }`}
                        onClick={() => setMobileMenuOpen(false)}
                      >
                        {item.name}
                      </Link>
                    </li>
                  );
                })}
              </ul>
            </nav>
          </motion.div>
        )}
      </div>
    </motion.nav>
  );
};
