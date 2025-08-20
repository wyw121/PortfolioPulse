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
  { name: "项目", href: "/projects" },
  { name: "博客", href: "/blog" },
  { name: "关于", href: "/about" },
];

export const Navigation = () => {
  const pathname = usePathname();
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  // 根据当前路径决定显示的Logo - 模仿Sindre Sorhus风格
  const currentPath = pathname.slice(1).replace(/\.\w+$/, ''); // Remove the first `/` and file extension.
  const logoContent = currentPath === '' ? "🦄" : "Vynix";

  return (
    <motion.header
      className="sticky top-0 z-40 flex-none mx-auto w-full bg-white md:bg-white/90 dark:bg-gray-950 dark:md:bg-gray-950/90 md:backdrop-blur-md border-b dark:border-b-0"
      initial={{ opacity: 0, y: -50 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.3 }}
    >
      <div className="py-3 px-3 mx-auto w-full md:flex md:justify-between max-w-6xl md:px-4">
        {/* Logo和移动端菜单按钮 */}
        <div className="flex justify-between">
          <Link href="/" className="flex items-center">
            <span className="self-center ml-2 text-2xl font-extrabold text-gray-900 whitespace-nowrap dark:text-white">
              {logoContent}
            </span>
          </Link>
          
          {/* 移动端菜单按钮 */}
          <div className="flex items-center md:hidden">
            <button
              type="button"
              className="ml-1.5 text-gray-500 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800 focus:outline-none focus:ring-4 focus:ring-gray-200 dark:focus:ring-gray-700 rounded-lg text-sm p-2.5 inline-flex items-center transition"
              aria-label="Toggle Menu"
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
            >
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
              </svg>
            </button>
          </div>
        </div>

        {/* 桌面导航 */}
        <nav
          className="items-center w-full md:w-auto hidden md:flex text-gray-600 dark:text-gray-200 h-screen md:h-auto"
          aria-label="Main navigation"
        >
          <ul className="flex flex-col pt-8 md:pt-0 md:flex-row md:self-center w-full md:w-auto text-xl md:text-base">
            {navItems.map((item) => {
              const currentPath = pathname.slice(1).replace(/\.\w+$/, '');
              const isActive = currentPath.startsWith(item.href.replace(/^\//, ''));
              const activeClass = 'underline underline-offset-[7px] decoration-[3px] decoration-blue-500';
              const linkClass = `${isActive ? activeClass : ''} font-medium hover:text-gray-900 dark:hover:text-white px-4 py-3 flex items-center transition duration-150 ease-in-out`;
              
              return (
                <li key={item.name}>
                  <Link
                    href={item.href}
                    className={linkClass}
                  >
                    {item.name}
                  </Link>
                </li>
              );
            })}
          </ul>
        </nav>
      </div>

      {/* 移动端导航菜单 */}
      {mobileMenuOpen && (
        <motion.div
          className="md:hidden"
          initial={{ opacity: 0, height: 0 }}
          animate={{ opacity: 1, height: "auto" }}
          exit={{ opacity: 0, height: 0 }}
          transition={{ duration: 0.3 }}
        >
          <nav className="items-center w-full text-gray-600 dark:text-gray-200">
            <ul className="flex flex-col pt-8 w-full text-xl">
              {navItems.map((item) => {
                const currentPath = pathname.slice(1).replace(/\.\w+$/, '');
                const isActive = currentPath.startsWith(item.href.replace(/^\//, ''));
                const activeClass = 'underline underline-offset-[7px] decoration-[3px] decoration-blue-500';
                const linkClass = `${isActive ? activeClass : ''} font-medium hover:text-gray-900 dark:hover:text-white px-4 py-3 flex items-center transition duration-150 ease-in-out block`;
                
                return (
                  <li key={item.name}>
                    <Link
                      href={item.href}
                      className={linkClass}
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
    </motion.header>
  );
};
