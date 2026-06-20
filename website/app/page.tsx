import dynamic from "next/dynamic";
import AmbientCanvas from "@/components/AmbientCanvas";
import Hero from "@/components/Hero";
import Nav from "@/components/Nav";
import SmoothScroll from "@/components/SmoothScroll";

const ScrollStory = dynamic(() => import("@/components/ScrollStory"));
const Showcase = dynamic(() => import("@/components/Showcase"));
const PerformanceSection = dynamic(() => import("@/components/PerformanceSection"));
const FeatureGrid = dynamic(() => import("@/components/FeatureGrid"));
const InteractiveExperience = dynamic(() => import("@/components/InteractiveExperience"));
const TechnologyOrbit = dynamic(() => import("@/components/TechnologyOrbit"));
const FinalCTA = dynamic(() => import("@/components/FinalCTA"));
const Footer = dynamic(() => import("@/components/Footer"));

export default function Home() {
  return (
    <SmoothScroll>
      <div className="site-shell">
        <AmbientCanvas />
        <Nav />
        <main id="main-content">
          <Hero />
          <ScrollStory />
          <Showcase />
          <PerformanceSection />
          <FeatureGrid />
          <InteractiveExperience />
          <TechnologyOrbit />
          <FinalCTA />
        </main>
        <Footer />
      </div>
    </SmoothScroll>
  );
}
