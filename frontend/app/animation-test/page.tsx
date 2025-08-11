import { AnimatedContainer } from "@/components/animations/animated-container";

export default function AnimationTestPage() {
  return (
    <div className="min-h-screen bg-white dark:bg-gray-900 text-gray-900 dark:text-white flex flex-col">
      <div className="py-16 px-4">
        <div className="max-w-4xl mx-auto space-y-16">
          <AnimatedContainer direction="fade" duration={1000}>
            <h1 className="text-4xl font-bold text-center mb-8">
              动画测试页面
            </h1>
          </AnimatedContainer>

          <AnimatedContainer direction="up" duration={800} delay={200}>
            <div className="tech-card p-8 rounded-xl bg-white/80 dark:bg-gray-800/60 backdrop-blur-sm">
              <h2 className="text-2xl font-semibold mb-4">从下向上淡入</h2>
              <p className="text-gray-600 dark:text-gray-300">
                这个卡片使用了从下向上的淡入动画效果，延迟 200ms
              </p>
            </div>
          </AnimatedContainer>

          <AnimatedContainer direction="left" duration={800} delay={400}>
            <div className="tech-card p-8 rounded-xl bg-white/80 dark:bg-gray-800/60 backdrop-blur-sm">
              <h2 className="text-2xl font-semibold mb-4">从左向右淡入</h2>
              <p className="text-gray-600 dark:text-gray-300">
                这个卡片使用了从左向右的淡入动画效果，延迟 400ms
              </p>
            </div>
          </AnimatedContainer>

          <AnimatedContainer direction="right" duration={800} delay={600}>
            <div className="tech-card p-8 rounded-xl bg-white/80 dark:bg-gray-800/60 backdrop-blur-sm">
              <h2 className="text-2xl font-semibold mb-4">从右向左淡入</h2>
              <p className="text-gray-600 dark:text-gray-300">
                这个卡片使用了从右向左的淡入动画效果，延迟 600ms
              </p>
            </div>
          </AnimatedContainer>

          {/* 悬停效果测试 */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {[1, 2, 3].map((index) => (
              <AnimatedContainer
                key={index}
                direction="up"
                duration={600}
                delay={800 + index * 100}
              >
                <div className="tech-card p-6 rounded-lg bg-white/80 dark:bg-gray-800/60 backdrop-blur-sm text-center">
                  <div className="h-12 w-12 mx-auto mb-4 bg-gradient-primary rounded-lg flex items-center justify-center">
                    <span className="text-white font-bold">{index}</span>
                  </div>
                  <h3 className="text-lg font-semibold mb-2">
                    悬停测试 {index}
                  </h3>
                  <p className="text-gray-600 dark:text-gray-300 text-sm">
                    悬停查看缓慢发光和提升效果
                  </p>
                </div>
              </AnimatedContainer>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
