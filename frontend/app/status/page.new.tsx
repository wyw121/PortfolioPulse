"use client";

import { useRouter } from "next/navigation";
import { useEffect } from "react";

/**
 * 状态页面已被移除
 * 自动重定向到主页
 */
export default function StatusPage() {
  const router = useRouter();

  useEffect(() => {
    router.push("/");
  }, [router]);

  return (
    <div style={{ padding: "2rem", textAlign: "center" }}>
      <h1>404 - 页面未找到</h1>
      <p>此页面已被移除，正在重定向到主页...</p>
    </div>
  );
}
