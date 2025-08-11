// Vynix 网站配置信息
export const siteConfig = {
  // 网站基础信息
  name: "Vynix",
  shortName: "V",
  description: "在 AI 驱动的数字世界中，通过数据与直觉的融合，达到对复杂系统或真理的动态洞察",

  // 网站详细描述
  longDescription: "Vynix 表示在 AI 驱动的数字世界中，通过数据与直觉的融合，达到对复杂系统或真理的动态洞察。它结合了'视野'（vision）、'连接'（link）和'无限'（infinity）的概念，象征 AI 时代中不断进化的智慧与可能性。",

  // 关键词
  keywords: ["AI", "vision", "nexus", "infinity", "insight", "portfolio", "projects", "showcase"],

  // 作者信息
  author: {
    name: "Vynix",
    description: "AI 时代的数字洞察者"
  },

  // URL 信息
  url: "https://vynix.com",

  // 社交媒体
  social: {
    github: "https://github.com/wyw121/PortfolioPulse",
  },

  // 品牌含义解释
  brandMeaning: {
    inspiration: {
      vy: "'Vy' 取自 'vision' 和 'vitality'，暗示 AI 的洞察力和生命力",
      nix: "'Nix' 灵感来自 'nexus'（枢纽、连接点）和 'phoenix'（凤凰，象征重生与进化）"
    },
    characteristics: "整体音节简洁，带点科技感和神秘感，适合 AI 时代的语境"
  }
} as const;

// 导出类型定义
export type SiteConfig = typeof siteConfig;
