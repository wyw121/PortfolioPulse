import { ReactNode, useEffect } from "react";
import Navigation from "./Navigation";

interface LayoutProps {
  children: ReactNode;
}

export default function Layout({ children }: LayoutProps) {
  useEffect(() => {
    // 启用过渡效果
    document.body.classList.add("transitions-enabled");
  }, []);

  return (
    <div className="min-h-screen bg-background text-foreground">
      <Navigation />
      <main className="pt-16">{children}</main>
    </div>
  );
}
