import { Bell, MapPin, Shield, Users, Phone, AlertTriangle, Smartphone, Server, Layers, Lock, Github, ExternalLink } from "lucide-react";
import { Button } from "@/components/ui/button";
import HeroSection from "@/components/HeroSection";
import FeaturesSection from "@/components/FeaturesSection";
import TechStackSection from "@/components/TechStackSection";
import ArchitectureSection from "@/components/ArchitectureSection";
import PortfolioSection from "@/components/PortfolioSection";
import PrivacySection from "@/components/PrivacySection";
import Footer from "@/components/Footer";
import Navigation from "@/components/Navigation";

const Index = () => {
  return (
    <div className="min-h-screen bg-background">
      <Navigation />
      <main>
        <HeroSection />
        <FeaturesSection />
        <TechStackSection />
        <ArchitectureSection />
        <PortfolioSection />
        <PrivacySection />
      </main>
      <Footer />
    </div>
  );
};

export default Index;
