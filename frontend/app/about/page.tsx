import {
  AboutContact,
  AboutExperience,
  AboutHero,
  AboutSkills,
} from "@/components/about";

export default function AboutPage() {
  return (
    <main className="pt-4">
      <AboutHero />
      <AboutSkills />
      <AboutExperience />
      <AboutContact />
    </main>
  );
}
