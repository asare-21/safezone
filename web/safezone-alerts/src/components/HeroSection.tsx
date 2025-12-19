import { Button } from "@/components/ui/button";
import { Bell, ArrowRight, Play } from "lucide-react";
import AppMockup from "@/components/AppMockup";
import { motion } from "framer-motion";

const HeroSection = () => {
  return (
    <section className="relative min-h-screen flex items-center pt-20 overflow-hidden">
      {/* Background Elements */}
      <div className="absolute inset-0 -z-10">
        <div className="absolute top-1/4 left-1/4 w-96 h-96 bg-primary/10 rounded-full blur-3xl animate-pulse-slow" />
        <div className="absolute bottom-1/4 right-1/4 w-80 h-80 bg-accent/10 rounded-full blur-3xl animate-pulse-slow animation-delay-500" />
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[800px] h-[800px] bg-warning/5 rounded-full blur-3xl" />
      </div>

      <div className="container mx-auto px-4 py-12 md:py-20">
        <div className="grid lg:grid-cols-2 gap-12 lg:gap-16 items-center">
          {/* Content */}
          <div className="text-center lg:text-left">
            {/* Badge */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5 }}
              className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-safezone-orange-light border border-safezone-orange/20 text-safezone-orange text-sm font-medium mb-6"
            >
              <Bell className="w-4 h-4" />
              <span>Crowdsourced Personal Safety Alerts</span>
            </motion.div>

            {/* Main Heading */}
            <motion.h1
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5, delay: 0.1 }}
              className="font-display text-4xl md:text-5xl lg:text-6xl font-bold text-foreground mb-6"
            >
              🚨 SafeZone
              <span className="block mt-2 bg-gradient-to-r from-primary to-accent bg-clip-text text-transparent">
                Stay Alert. Stay Safe.
              </span>
            </motion.h1>

            {/* Description */}
            <motion.p
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5, delay: 0.2 }}
              className="text-lg md:text-xl text-muted-foreground max-w-xl mx-auto lg:mx-0 mb-8"
            >
              Real-time safety notifications when approaching areas with recent incidents. 
              Like <span className="text-foreground font-medium">Waze for personal safety</span> — 
              community-powered alerts that keep you informed and protected.
            </motion.p>

            {/* CTAs */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5, delay: 0.3 }}
              className="flex flex-col sm:flex-row gap-4 justify-center lg:justify-start"
            >
              <Button variant="hero" size="xl" className="group" asChild>
                <a href="https://github.com/asare-21/safezone#-getting-started" target="_blank" rel="noopener noreferrer">
                  <span>Get Started</span>
                  <ArrowRight className="w-5 h-5 group-hover:translate-x-1 transition-transform" />
                </a>
              </Button>
              <Button variant="outline" size="xl" className="group" asChild>
                <a href="https://github.com/asare-21/safezone#readme" target="_blank" rel="noopener noreferrer">
                  <Play className="w-5 h-5" />
                  <span>View Documentation</span>
                </a>
              </Button>
            </motion.div>

            {/* App Store Badges */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5, delay: 0.4 }}
              className="flex items-center gap-4 justify-center lg:justify-start mt-8"
            >
              <a href="#" className="opacity-80 hover:opacity-100 transition-opacity">
                <img
                  src="https://upload.wikimedia.org/wikipedia/commons/thumb/3/3c/Download_on_the_App_Store_Badge.svg/200px-Download_on_the_App_Store_Badge.svg.png"
                  alt="Download on App Store"
                  className="h-10"
                />
              </a>
              <a href="#" className="opacity-80 hover:opacity-100 transition-opacity">
                <img
                  src="https://upload.wikimedia.org/wikipedia/commons/thumb/7/78/Google_Play_Store_badge_EN.svg/200px-Google_Play_Store_badge_EN.svg.png"
                  alt="Get it on Google Play"
                  className="h-10"
                />
              </a>
            </motion.div>

            {/* Stats */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5, delay: 0.5 }}
              className="grid grid-cols-3 gap-6 mt-12 pt-8 border-t border-border/50"
            >
              <div>
                <div className="font-display text-2xl md:text-3xl font-bold text-foreground">18+</div>
                <div className="text-sm text-muted-foreground">Incident Types</div>
              </div>
              <div>
                <div className="font-display text-2xl md:text-3xl font-bold text-foreground">Real-time</div>
                <div className="text-sm text-muted-foreground">Alerts</div>
              </div>
              <div>
                <div className="font-display text-2xl md:text-3xl font-bold text-foreground">100%</div>
                <div className="text-sm text-muted-foreground">Privacy-First</div>
              </div>
            </motion.div>
          </div>

          {/* App Mockup */}
          <motion.div
            initial={{ opacity: 0, scale: 0.9, y: 30 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            transition={{ duration: 0.7, delay: 0.2 }}
            className="relative flex justify-center lg:justify-end"
          >
            <AppMockup />
          </motion.div>
        </div>
      </div>
    </section>
  );
};

export default HeroSection;
