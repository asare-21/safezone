import { motion } from "framer-motion";

const techStack = {
  frontend: {
    title: "Mobile Frontend",
    emoji: "📱",
    color: "safezone-blue",
    technologies: [
      { name: "Flutter", version: "3.8.0+", icon: "🎯" },
      { name: "Dart", version: "3.0+", icon: "💎" },
      { name: "flutter_bloc", version: "State Management", icon: "🔄" },
      { name: "Firebase", version: "Push Notifications", icon: "🔔" },
      { name: "geolocator", version: "Location Services", icon: "📍" },
      { name: "flutter_map", version: "Maps Integration", icon: "🗺️" },
    ],
  },
  backend: {
    title: "Backend API",
    emoji: "⚙️",
    color: "safezone-green",
    technologies: [
      { name: "Django", version: "4.2.23", icon: "🐍" },
      { name: "Django REST Framework", version: "API Design", icon: "🔗" },
      { name: "PostgreSQL", version: "Database", icon: "🗄️" },
      { name: "PostGIS", version: "Geospatial Queries", icon: "🌍" },
      { name: "Redis", version: "Caching", icon: "⚡" },
      { name: "JWT", version: "Authentication", icon: "🔐" },
    ],
  },
};

const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.15,
    },
  },
};

const cardVariants = {
  hidden: { opacity: 0, y: 40 },
  visible: {
    opacity: 1,
    y: 0,
    transition: { duration: 0.6 },
  },
};

const TechStackSection = () => {
  return (
    <section id="tech-stack" className="py-20 md:py-32 bg-secondary/30 relative overflow-hidden">
      {/* Background Pattern */}
      <div className="absolute inset-0 -z-10 opacity-50">
        <svg className="w-full h-full" viewBox="0 0 1000 1000">
          <defs>
            <pattern id="tech-grid" width="100" height="100" patternUnits="userSpaceOnUse">
              <circle cx="50" cy="50" r="1" fill="currentColor" className="text-primary/20" />
            </pattern>
          </defs>
          <rect width="100%" height="100%" fill="url(#tech-grid)" />
        </svg>
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
          <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-safezone-green-light border border-accent/20 text-accent text-sm font-medium mb-6">
            <span>🛠️</span>
            <span>Technology Stack</span>
          </div>
          <h2 className="font-display text-3xl md:text-4xl lg:text-5xl font-bold text-foreground mb-6">
            Built with
            <span className="bg-gradient-to-r from-primary to-accent bg-clip-text text-transparent block mt-2">Modern Technologies</span>
          </h2>
          <p className="text-lg text-muted-foreground">
            SafeZone leverages industry-standard tools and frameworks to deliver 
            a robust, scalable, and maintainable application.
          </p>
        </motion.div>

        {/* Tech Stack Cards */}
        <motion.div
          variants={containerVariants}
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true, margin: "-100px" }}
          className="grid md:grid-cols-2 gap-8 max-w-5xl mx-auto"
        >
          {Object.entries(techStack).map(([key, stack]) => (
            <motion.div
              key={key}
              variants={cardVariants}
              className="glass-card p-8 hover:shadow-lg transition-all duration-300"
            >
              {/* Header */}
              <div className="flex items-center gap-4 mb-6 pb-6 border-b border-border/50">
                <div className="w-14 h-14 rounded-2xl bg-primary/10 flex items-center justify-center">
                  <span className="text-3xl">{stack.emoji}</span>
                </div>
                <div>
                  <h3 className="font-display text-xl font-semibold text-foreground">
                    {stack.title}
                  </h3>
                  <p className="text-sm text-muted-foreground">
                    {key === "frontend" ? "Cross-platform mobile app" : "RESTful API service"}
                  </p>
                </div>
              </div>

              {/* Technologies */}
              <div className="grid grid-cols-2 gap-4">
                {stack.technologies.map((tech) => (
                  <motion.div
                    key={tech.name}
                    whileHover={{ scale: 1.02 }}
                    className="flex items-center gap-3 p-3 rounded-xl bg-secondary/50 hover:bg-secondary transition-colors group"
                  >
                    <span className="text-xl group-hover:scale-110 transition-transform">
                      {tech.icon}
                    </span>
                    <div className="flex-1 min-w-0">
                      <div className="font-medium text-foreground text-sm truncate">
                        {tech.name}
                      </div>
                      <div className="text-xs text-muted-foreground truncate">
                        {tech.version}
                      </div>
                    </div>
                  </motion.div>
                ))}
              </div>
            </motion.div>
          ))}
        </motion.div>

        {/* Additional Badges */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: "-50px" }}
          transition={{ duration: 0.5, delay: 0.3 }}
          className="mt-12 flex flex-wrap justify-center gap-3"
        >
          {["Clean Architecture", "BLoC Pattern", "REST API", "JWT Auth", "Geospatial", "Real-time"].map((badge, index) => (
            <motion.span
              key={badge}
              initial={{ opacity: 0, scale: 0.8 }}
              whileInView={{ opacity: 1, scale: 1 }}
              viewport={{ once: true }}
              transition={{ duration: 0.3, delay: index * 0.05 }}
              className="px-4 py-2 rounded-full bg-card border border-border text-sm font-medium text-muted-foreground hover:text-foreground hover:border-primary/50 transition-colors"
            >
              {badge}
            </motion.span>
          ))}
        </motion.div>
      </div>
    </section>
  );
};

export default TechStackSection;
