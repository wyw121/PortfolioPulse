import { Footer } from "@/components/layout/footer";
import { OptimizedActivitySection } from "@/components/sections/optimized-activity";

export default function ActivityPage() {
  return (
    <div className="min-h-screen flex flex-col">
      <main className="flex-1 pt-4">
        <OptimizedActivitySection />
      </main>
      <Footer />
    </div>
  );
}
