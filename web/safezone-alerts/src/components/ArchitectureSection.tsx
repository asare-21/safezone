import { Smartphone, Server, Database, Cloud, ArrowRight, ArrowDown } from "lucide-react";
import { motion } from "framer-motion";

const ArchitectureSection = () => {
  const layers = [
    {
      title: "Presentation Layer",
      icon: Smartphone,
      color: "safezone-blue",
      items: ["Flutter UI", "BLoC State Management", "Clean Architecture"],
      description: "User interface and state management",
    },
    {
      title: "Application Layer",
      icon: Server,
      color: "safezone-orange",
      items: ["Django REST API", "Business Logic", "Authentication"],
      description: "API endpoints and business rules",
    },
    {
      title: "Data Layer",
      icon: Database,
      color: "safezone-green",
      items: ["PostgreSQL + PostGIS", "Geospatial Queries", "Data Models"],
      description: "Persistent storage and queries",
    },
    {
      title: "Infrastructure",
      icon: Cloud,
      color: "primary",
      items: ["Firebase Cloud Messaging", "Location Services", "Push Notifications"],
      description: "Cloud services and integrations",
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

  return (
    <section id="architecture" className="py-20 md:py-32 relative overflow-hidden">
      {/* Background */}
      <div className="absolute inset-0 -z-10">
        <div className="absolute top-1/4 right-0 w-96 h-96 bg-primary/5 rounded-full blur-3xl" />
        <div className="absolute bottom-1/4 left-0 w-96 h-96 bg-accent/5 rounded-full blur-3xl" />
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
          <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-safezone-orange-light border border-warning/20 text-safezone-orange text-sm font-medium mb-6">
            <span>🏗️</span>
            <span>System Architecture</span>
          </div>
          <h2 className="font-display text-3xl md:text-4xl lg:text-5xl font-bold text-foreground mb-6">
            Clean &
            <span className="bg-gradient-to-r from-primary to-accent bg-clip-text text-transparent block mt-2">Scalable Architecture</span>
          </h2>
          <p className="text-lg text-muted-foreground">
            SafeZone follows clean architecture principles with clear separation of concerns, 
            making the codebase maintainable and testable.
          </p>
        </motion.div>

        {/* Architecture Diagram */}
        <div className="max-w-4xl mx-auto">
          {/* Desktop View */}
          <motion.div
            variants={containerVariants}
            initial="hidden"
            whileInView="visible"
            viewport={{ once: true, margin: "-100px" }}
            className="hidden md:block glass-card p-8"
          >
            <div className="grid grid-cols-4 gap-4">
              {layers.map((layer, index) => (
                <motion.div key={layer.title} variants={itemVariants} className="relative">
                  {/* Connection Line */}
                  {index < layers.length - 1 && (
                    <div className="absolute top-1/2 -right-2 w-4 flex items-center justify-center z-10">
                      <ArrowRight className="w-4 h-4 text-muted-foreground" />
                    </div>
                  )}
                  
                  <div className="p-4 rounded-2xl bg-secondary/50 hover:bg-secondary transition-colors h-full group">
                    {/* Icon */}
                    <div className={`w-12 h-12 rounded-xl bg-${layer.color}/10 flex items-center justify-center mb-4 group-hover:scale-110 transition-transform`}>
                      <layer.icon className={`w-6 h-6 text-${layer.color}`} />
                    </div>
                    
                    {/* Title */}
                    <h3 className="font-display font-semibold text-foreground mb-2 text-sm">
                      {layer.title}
                    </h3>
                    
                    {/* Description */}
                    <p className="text-xs text-muted-foreground mb-4">
                      {layer.description}
                    </p>
                    
                    {/* Items */}
                    <ul className="space-y-2">
                      {layer.items.map((item) => (
                        <li
                          key={item}
                          className="text-xs text-muted-foreground flex items-center gap-2"
                        >
                          <div className="w-1.5 h-1.5 rounded-full bg-primary/50" />
                          {item}
                        </li>
                      ))}
                    </ul>
                  </div>
                </motion.div>
              ))}
            </div>
          </motion.div>

          {/* Mobile View */}
          <motion.div
            variants={containerVariants}
            initial="hidden"
            whileInView="visible"
            viewport={{ once: true, margin: "-100px" }}
            className="md:hidden space-y-4"
          >
            {layers.map((layer, index) => (
              <motion.div key={layer.title} variants={itemVariants} className="relative">
                <div className="glass-card p-6">
                  <div className="flex items-start gap-4">
                    <div className={`w-12 h-12 rounded-xl bg-${layer.color}/10 flex items-center justify-center shrink-0`}>
                      <layer.icon className={`w-6 h-6 text-${layer.color}`} />
                    </div>
                    <div className="flex-1">
                      <h3 className="font-display font-semibold text-foreground mb-1">
                        {layer.title}
                      </h3>
                      <p className="text-sm text-muted-foreground mb-3">
                        {layer.description}
                      </p>
                      <div className="flex flex-wrap gap-2">
                        {layer.items.map((item) => (
                          <span
                            key={item}
                            className="px-2 py-1 rounded-md bg-secondary text-xs text-muted-foreground"
                          >
                            {item}
                          </span>
                        ))}
                      </div>
                    </div>
                  </div>
                </div>
                
                {/* Connection Arrow */}
                {index < layers.length - 1 && (
                  <div className="flex justify-center py-2">
                    <ArrowDown className="w-5 h-5 text-muted-foreground" />
                  </div>
                )}
              </motion.div>
            ))}
          </motion.div>
        </div>

        {/* Pattern Highlights */}
        <motion.div
          variants={containerVariants}
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true, margin: "-50px" }}
          className="mt-12 grid md:grid-cols-3 gap-6 max-w-4xl mx-auto"
        >
          {[
            { emoji: "🎯", title: "BLoC Pattern", desc: "Business Logic Components for predictable state management" },
            { emoji: "🔗", title: "REST API", desc: "Stateless, scalable API design with Django REST Framework" },
            { emoji: "🌍", title: "Geospatial", desc: "PostGIS integration for efficient location-based queries" },
          ].map((item) => (
            <motion.div
              key={item.title}
              variants={itemVariants}
              className="text-center p-6 rounded-2xl bg-card border border-border/50"
            >
              <div className="text-3xl mb-3">{item.emoji}</div>
              <h4 className="font-display font-semibold text-foreground mb-2">{item.title}</h4>
              <p className="text-sm text-muted-foreground">{item.desc}</p>
            </motion.div>
          ))}
        </motion.div>
      </div>
    </section>
  );
};

export default ArchitectureSection;
