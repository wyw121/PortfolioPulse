import LayoutTester from '@/components/layout-tester';
import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: '布局模式测试 - PortfolioPulse',
  description: '测试不同的布局模式，选择最适合的设计方案',
};

export default function LayoutTestPage() {
  return <LayoutTester />;
}
