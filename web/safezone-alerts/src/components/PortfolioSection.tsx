import { Button } from "@/components/ui/button";
import { Github, ExternalLink, Code, Smartphone, Globe, Layers, Zap, Shield } from "lucide-react";
import { motion } from "framer-motion";

const skills = [
  { icon: Smartphone, label: "Mobile Development", detail: "Flutter & Dart" },
  { icon: Globe, label: "Geospatial Systems", detail: "Maps & Location" },
  { icon: Zap, label: "Real-time Systems", detail: "Push Notifications" },
  { icon: Layers, label: "RESTful APIs", detail: "Django Backend" },
  { icon: Shield, label: "Ethical Development", detail: "Privacy-First" },
  { icon: Code, label: "Clean Architecture", detail: "BLoC Pattern" },
];

const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.08,
    },
  },
};

const itemVariants = {
  hidden: { opacity: 0, y: 20 },
  visible: {
    opacity: 1,
    y: 0,
    transition: { duration: 0.4 },
  },
};

const PortfolioSection = () => {
  return (
    <section id="portfolio" className="py-20 md:py-32 bg-secondary/30 relative overflow-hidden">
      {/* Background */}
      <div className="absolute inset-0 -z-10 opacity-50">
        <svg className="w-full h-full" viewBox="0 0 1000 1000">
          <defs>
            <linearGradient id="portfolio-grad" x1="0%" y1="0%" x2="100%" y2="100%">
              <stop offset="0%" stopColor="hsl(var(--primary))" stopOpacity="0.1" />
              <stop offset="100%" stopColor="hsl(var(--accent))" stopOpacity="0.1" />
            </linearGradient>
          </defs>
          <rect width="100%" height="100%" fill="url(#portfolio-grad)" />
        </svg>
      </div>

      <div className="container mx-auto px-4">
        <div className="grid lg:grid-cols-2 gap-12 lg:gap-16 items-center">
          {/* Content */}
          <motion.div
            initial={{ opacity: 0, x: -30 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true, margin: "-100px" }}
            transition={{ duration: 0.6 }}
          >
            <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-primary/10 border border-primary/20 text-primary text-sm font-medium mb-6">
              <span>💼</span>
              <span>Portfolio Project</span>
            </div>

            <h2 className="font-display text-3xl md:text-4xl lg:text-5xl font-bold text-foreground mb-6">
              A Showcase of
              <span className="bg-gradient-to-r from-primary to-accent bg-clip-text text-transparent block mt-2">Full-Stack Skills</span>
            </h2>

            <p className="text-lg text-muted-foreground mb-8">
              SafeZone is a comprehensive portfolio project demonstrating proficiency in 
              mobile development, backend engineering, and real-time geospatial systems. 
              Built with production-ready code quality and architecture.
            </p>

            {/* Skills Grid */}
            <motion.div
              variants={containerVariants}
              initial="hidden"
              whileInView="visible"
              viewport={{ once: true, margin: "-50px" }}
              className="grid grid-cols-2 sm:grid-cols-3 gap-4 mb-8"
            >
              {skills.map((skill) => (
                <motion.div
                  key={skill.label}
                  variants={itemVariants}
                  whileHover={{ scale: 1.03 }}
                  className="p-4 rounded-xl bg-card border border-border/50 hover:border-primary/30 hover:shadow-md transition-all group"
                >
                  <skill.icon className="w-6 h-6 text-primary mb-2 group-hover:scale-110 transition-transform" />
                  <div className="font-medium text-foreground text-sm">{skill.label}</div>
                  <div className="text-xs text-muted-foreground">{skill.detail}</div>
                </motion.div>
              ))}
            </motion.div>

            {/* CTAs */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.5, delay: 0.3 }}
              className="flex flex-wrap gap-4"
            >
              <Button variant="hero" size="lg" asChild>
                <a href="https://github.com" target="_blank" rel="noopener noreferrer">
                  <Github className="w-5 h-5" />
                  View on GitHub
                </a>
              </Button>
              <Button variant="outline" size="lg" asChild>
                <a href="#" target="_blank" rel="noopener noreferrer">
                  <ExternalLink className="w-5 h-5" />
                  Live Documentation
                </a>
              </Button>
            </motion.div>
          </motion.div>

          {/* Visual Card */}
          <motion.div
            initial={{ opacity: 0, x: 30 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true, margin: "-100px" }}
            transition={{ duration: 0.6, delay: 0.2 }}
            className="relative"
          >
            <div className="absolute -inset-4 bg-gradient-to-r from-primary/10 to-accent/10 rounded-3xl blur-2xl" />
            
            <div className="relative glass-card p-8 overflow-hidden">
              {/* Code Preview Header */}
              <div className="flex items-center gap-2 mb-6 pb-4 border-b border-border/50">
                <div className="w-3 h-3 rounded-full bg-destructive" />
                <div className="w-3 h-3 rounded-full bg-warning" />
                <div className="w-3 h-3 rounded-full bg-accent" />
                <span className="ml-4 text-sm text-muted-foreground font-mono">safezone_bloc.dart</span>
              </div>

              {/* Code Preview */}
              <pre className="text-sm font-mono overflow-x-auto">
                <code className="text-muted-foreground">
                  <span className="text-primary">class</span>{" "}
                  <span className="text-accent">IncidentBloc</span>{" "}
                  <span className="text-primary">extends</span>{" "}
                  <span className="text-accent">Bloc</span>
                  {"<IncidentEvent, IncidentState> {\n"}
                  {"  "}
                  <span className="text-primary">final</span> IncidentRepository _repo;{"\n\n"}
                  {"  "}
                  <span className="text-accent">IncidentBloc</span>
                  {"(this._repo) : super(Initial()) {\n"}
                  {"    "}on{"<"}
                  <span className="text-warning">LoadNearbyIncidents</span>
                  {">("}
                  <span className="text-muted-foreground/60">_onLoad</span>
                  {");\n"}
                  {"    "}on{"<"}
                  <span className="text-warning">ReportIncident</span>
                  {">("}
                  <span className="text-muted-foreground/60">_onReport</span>
                  {");\n"}
                  {"  }\n\n"}
                  {"  "}
                  <span className="text-primary">Future</span>
                  {"<void> _onLoad(\n"}
                  {"    "}
                  <span className="text-warning">LoadNearbyIncidents</span> event,{"\n"}
                  {"    "}
                  <span className="text-accent">Emitter</span>
                  {"<IncidentState> emit,\n"}
                  {"  ) async {\n"}
                  {"    "}emit(
                  <span className="text-accent">Loading</span>());{"\n"}
                  {"    "}
                  <span className="text-primary">final</span> incidents ={"\n"}
                  {"      "}
                  <span className="text-primary">await</span> _repo.getNearby(event.location);{"\n"}
                  {"    "}emit(
                  <span className="text-accent">Loaded</span>(incidents));{"\n"}
                  {"  }\n"}
                  {"}"}
                </code>
              </pre>

              {/* Floating Badge */}
              <motion.div
                initial={{ opacity: 0, scale: 0.8 }}
                whileInView={{ opacity: 1, scale: 1 }}
                viewport={{ once: true }}
                transition={{ duration: 0.4, delay: 0.5 }}
                className="absolute -bottom-4 -right-4 glass-card px-4 py-2 shadow-lg"
              >
                <div className="flex items-center gap-2">
                  <div className="w-2 h-2 rounded-full bg-accent animate-pulse" />
                  <span className="text-sm font-medium text-foreground">Production Ready</span>
                </div>
              </motion.div>
            </div>
          </motion.div>
        </div>
      </div>
    </section>
  );
};

export default PortfolioSection;
