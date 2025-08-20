"use client";

import { usePathname } from "next/navigation";
import { ReactNode } from "react";

interface HomeLayoutProps {
  readonly children: ReactNode;
}

export function HomeLayout({ children }: HomeLayoutProps) {
  const pathname = usePathname();
  const isHomePage = pathname === "/";

  if (isHomePage) {
    // 主页使用特殊布局：完全填充视口，确保内容居中
    return <main className="h-screen flex flex-col">{children}</main>;
  }

  // 其他页面使用标准布局
  return <main className="min-h-screen">{children}</main>;
}
