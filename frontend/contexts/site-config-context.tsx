"use client";

import { siteConfig } from "@/lib/config";
import { createContext, useContext, type ReactNode } from "react";

/**
 * 站点配置类型
 */
export type SiteConfig = typeof siteConfig;

/**
 * 站点配置上下文
 */
const SiteConfigContext = createContext<SiteConfig>(siteConfig);

/**
 * 站点配置 Provider 组件
 */
export function SiteConfigProvider({ children }: { children: ReactNode }) {
  return (
    <SiteConfigContext.Provider value={siteConfig}>
      {children}
    </SiteConfigContext.Provider>
  );
}

/**
 * 使用站点配置的 Hook
 * @returns 站点配置对象
 * @example
 * ```tsx
 * const config = useSiteConfig();
 * console.log(config.name); // "PortfolioPulse"
 * ```
 */
export function useSiteConfig(): SiteConfig {
  const context = useContext(SiteConfigContext);
  
  if (!context) {
    throw new Error("useSiteConfig must be used within SiteConfigProvider");
  }
  
  return context;
}
