import { Bell, MapPin, Shield, Users, Phone, Tag, CheckCircle } from "lucide-react";
import { motion } from "framer-motion";

const features = [
  {
    icon: Bell,
    title: "Real-Time Safety Alerts",
    description: "Receive instant proximity-based notifications when you're approaching areas with recent incidents.",
    color: "safezone-orange",
    emoji: "🔔",
  },
  {
    icon: MapPin,
    title: "Interactive Safety Map",
    description: "View color-coded incident markers on an intuitive map interface showing incident density and recency.",
    color: "safezone-blue",
    emoji: "🗺️",
  },
  {
    icon: Tag,
    title: "18 Incident Categories",
    description: "Comprehensive categorization including theft, assault, harassment, vandalism, and more for accurate reporting.",
    color: "safezone-green",
    emoji: "🏷️",
  },
  {
    icon: Users,
    title: "Community Validation",
    description: "Reports are validated through community votes and AI moderation ensuring data accuracy and reliability.",
    color: "primary",
    emoji: "👥",
  },
  {
    icon: Shield,
    title: "Anonymous Reporting",
    description: "Report incidents anonymously with location privacy controls to protect your identity while helping others.",
    color: "accent",
    emoji: "🛡️",
  },
  {
    icon: Phone,
    title: "Emergency Quick Access",
    description: "One-tap access to emergency services with automatic location sharing for rapid response.",
    color: "safezone-red",
    emoji: "📞",
  },
];

const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.1,
    },
  },
};

const itemVariants = {
  hidden: { opacity: 0, y: 30 },
  visible: {
    opacity: 1,
    y: 0,
    transition: { duration: 0.5 },
  },
};

const FeaturesSection = () => {
  return (
    <section id="features" className="py-20 md:py-32 relative overflow-hidden">
      {/* Background Pattern */}
      <div className="absolute inset-0 -z-10">
        <div className="absolute top-0 left-1/4 w-64 h-64 bg-primary/5 rounded-full blur-3xl" />
        <div className="absolute bottom-0 right-1/4 w-64 h-64 bg-accent/5 rounded-full blur-3xl" />
      </div>

      <div className="container mx-auto px-4">
        {/* Section Header */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: "-100px" }}
          transition={{ duration: 0.6 }}
          className="text-center max-w-3xl mx-auto mb-16"
        >
          <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-safezone-blue-light border border-primary/20 text-primary text-sm font-medium mb-6">
            <span>✨</span>
            <span>Key Features</span>
          </div>
          <h2 className="font-display text-3xl md:text-4xl lg:text-5xl font-bold text-foreground mb-6">
            Everything You Need to
            <span className="bg-gradient-to-r from-primary to-accent bg-clip-text text-transparent block mt-2">Stay Safe</span>
          </h2>
          <p className="text-lg text-muted-foreground">
            SafeZone combines real-time alerts, community reporting, and smart technology 
            to keep you informed about your surroundings.
          </p>
        </motion.div>

        {/* Features Grid */}
        <motion.div
          variants={containerVariants}
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true, margin: "-100px" }}
          className="grid md:grid-cols-2 lg:grid-cols-3 gap-6 lg:gap-8"
        >
          {features.map((feature) => (
            <motion.div
              key={feature.title}
              variants={itemVariants}
              className="group glass-card p-6 hover:shadow-lg transition-all duration-300 hover:-translate-y-1"
            >
              {/* Icon */}
              <div className={`w-14 h-14 rounded-2xl bg-${feature.color}/10 flex items-center justify-center mb-5 group-hover:scale-110 transition-transform duration-300`}>
                <span className="text-2xl">{feature.emoji}</span>
              </div>

              {/* Content */}
              <h3 className="font-display text-xl font-semibold text-foreground mb-3 flex items-center gap-2">
                {feature.title}
              </h3>
              <p className="text-muted-foreground leading-relaxed">
                {feature.description}
              </p>

              {/* Hover indicator */}
              <div className="mt-4 flex items-center gap-2 text-primary opacity-0 group-hover:opacity-100 transition-opacity">
                <CheckCircle className="w-4 h-4" />
                <span className="text-sm font-medium">Learn more</span>
              </div>
            </motion.div>
          ))}
        </motion.div>
      </div>
    </section>
  );
};

export default FeaturesSection;
