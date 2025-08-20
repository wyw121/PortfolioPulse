"use client";

import { AnimatedContainer } from "@/components/ui/effects";
import { siteConfig } from "@/lib/config";

export function HeroTitle() {
  return (
    <div className="text-center mb-12">
      <AnimatedContainer direction="up" duration={800}>
        <h1 className="text-5xl md:text-7xl font-bold mb-8">
          <span className="bg-gradient-to-r from-blue-500 via-purple-500 to-pink-500 bg-clip-text text-transparent glow-pulse">
            {siteConfig.name}
          </span>
        </h1>
      </AnimatedContainer>

      <AnimatedContainer direction="up" duration={800} delay={200}>
        <p className="text-xl md:text-2xl text-gray-600 dark:text-gray-300 mb-8 max-w-3xl mx-auto leading-relaxed">
          {siteConfig.description}
        </p>
      </AnimatedContainer>
    </div>
  );
}
