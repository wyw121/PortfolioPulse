"use client";

import { AnimatedContainer } from "@/components/ui/effects";
import { useTranslation } from "@/hooks/use-translation";

export function BlogPageHeader() {
  const { dict } = useTranslation();

  return (
    <div className="max-w-6xl mx-auto px-6 py-12">
      <AnimatedContainer direction="up" duration={350} fastResponse={true}>
        <div className="text-center mb-12">
          <h1 className="text-4xl md:text-5xl font-bold mb-6 bg-gradient-to-r from-blue-500 via-purple-500 to-pink-500 bg-clip-text text-transparent">
            {dict.blog.title}
          </h1>
          <p className="text-lg text-gray-600 dark:text-gray-300 max-w-3xl mx-auto">
            {dict.blog.subtitle}
          </p>
        </div>
      </AnimatedContainer>
    </div>
  );
}
