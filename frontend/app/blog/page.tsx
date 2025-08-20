import { BlogGrid } from "@/components/blog";
import { AnimatedContainer } from "@/components/ui/effects";

export default function BlogPage() {
  return (
    <main className="pt-4">
      <div className="max-w-6xl mx-auto px-6 py-12">
        <AnimatedContainer direction="up" duration={350} fastResponse={true}>
          <div className="text-center mb-12">
            <h1 className="text-4xl md:text-5xl font-bold mb-6 bg-gradient-to-r from-blue-500 via-purple-500 to-pink-500 bg-clip-text text-transparent">
              技术博客
            </h1>
            <p className="text-lg text-gray-600 dark:text-gray-300 max-w-3xl mx-auto">
              记录技术学习的点点滴滴，分享开发经验与思考，探索前沿技术趋势。
            </p>
          </div>
        </AnimatedContainer>
      </div>

      <BlogGrid />
    </main>
  );
}
