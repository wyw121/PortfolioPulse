/**
 * 全局动画配置文件 - PortfolioPulse
 * 统一管理动画时长、延迟和缓动函数，确保整体动效一致性
 */

// 动画时长配置（毫秒）
export const ANIMATION_DURATIONS = {
  // 基础动画时长
  fast: 250, // 快速响应
  normal: 350, // 标准动画
  slow: 500, // 慢速动画

  // 特定场景
  hover: 200, // 悬停效果
  page: 400, // 页面切换
  modal: 300, // 弹窗动画
  loading: 600, // 加载动画
} as const;

// 延迟配置（毫秒）
export const ANIMATION_DELAYS = {
  none: 0,
  short: 50,
  normal: 100,
  medium: 150,
  long: 200,

  // 交错动画间隔
  stagger: 60, // 列表项交错间隔
  staggerSmall: 40, // 小间隔交错
  staggerLarge: 80, // 大间隔交错
} as const;

// 缓动函数
export const ANIMATION_EASINGS = {
  // 标准缓动
  ease: [0.25, 0.1, 0.25, 1] as const,
  easeIn: [0.4, 0, 1, 1] as const,
  easeOut: [0, 0, 0.2, 1] as const,
  easeInOut: [0.4, 0, 0.2, 1] as const,

  // 专用缓动
  spring: [0.25, 0.46, 0.45, 0.94] as const,
  bounce: [0.68, -0.55, 0.265, 1.55] as const,

  // 快速响应专用
  fastResponse: [0.25, 0.1, 0.25, 1] as const,
  smoothEntry: [0.4, 0, 0.2, 1] as const,
} as const;

// 移动距离配置（像素）
export const ANIMATION_OFFSETS = {
  small: 15, // 小幅移动
  normal: 20, // 标准移动
  large: 30, // 大幅移动

  // 快速响应模式
  fastSmall: 10,
  fastNormal: 15,
  fastLarge: 20,
} as const;

// 视口边距配置
export const VIEWPORT_MARGINS = {
  default: "-80px",
  fast: "-50px",
  early: "-120px",
  late: "-20px",
} as const;

// 预设配置组合
export const ANIMATION_PRESETS = {
  // 快速响应预设
  fastResponse: {
    duration: ANIMATION_DURATIONS.normal,
    easing: ANIMATION_EASINGS.fastResponse,
    offset: ANIMATION_OFFSETS.fastNormal,
    viewportMargin: VIEWPORT_MARGINS.fast,
  },

  // 标准预设
  standard: {
    duration: ANIMATION_DURATIONS.normal,
    easing: ANIMATION_EASINGS.ease,
    offset: ANIMATION_OFFSETS.normal,
    viewportMargin: VIEWPORT_MARGINS.default,
  },

  // 平滑入场预设
  smoothEntry: {
    duration: ANIMATION_DURATIONS.slow,
    easing: ANIMATION_EASINGS.smoothEntry,
    offset: ANIMATION_OFFSETS.large,
    viewportMargin: VIEWPORT_MARGINS.default,
  },

  // 悬停效果预设
  hover: {
    duration: ANIMATION_DURATIONS.hover,
    easing: ANIMATION_EASINGS.easeOut,
  },
} as const;

// 导出类型定义
export type AnimationDuration = keyof typeof ANIMATION_DURATIONS;
export type AnimationDelay = keyof typeof ANIMATION_DELAYS;
export type AnimationEasing = keyof typeof ANIMATION_EASINGS;
export type AnimationOffset = keyof typeof ANIMATION_OFFSETS;
export type ViewportMargin = keyof typeof VIEWPORT_MARGINS;
export type AnimationPreset = keyof typeof ANIMATION_PRESETS;
