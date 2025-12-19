import { Shield, Lock, Eye, Users, AlertTriangle } from "lucide-react";
import { motion } from "framer-motion";

const principles = [
  {
    icon: Shield,
    title: "Privacy-First Design",
    description: "All personal data is encrypted and user location is never stored permanently. You control your data.",
  },
  {
    icon: Lock,
    title: "Anonymous Reporting",
    description: "Report incidents without revealing your identity. Optional anonymity protects reporters.",
  },
  {
    icon: Eye,
    title: "Transparent Operations",
    description: "Open-source codebase allows community review. No hidden data collection or tracking.",
  },
  {
    icon: Users,
    title: "Community-Driven",
    description: "Built by and for the community. All features prioritize user safety over metrics.",
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

const PrivacySection = () => {
  return (
    <section id="privacy" className="py-20 md:py-32 relative overflow-hidden">
      {/* Background */}
      <div className="absolute inset-0 -z-10">
        <div className="absolute top-0 left-0 w-full h-full bg-gradient-to-b from-safezone-green-light/30 to-transparent" />
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
            <span>🔒</span>
            <span>Privacy & Ethics</span>
          </div>
          <h2 className="font-display text-3xl md:text-4xl lg:text-5xl font-bold text-foreground mb-6">
            Built on Trust &
            <span className="bg-gradient-to-r from-primary to-accent bg-clip-text text-transparent block mt-2">Transparency</span>
          </h2>
          <p className="text-lg text-muted-foreground">
            SafeZone is committed to ethical development practices. Your privacy and 
            safety are our top priorities — not an afterthought.
          </p>
        </motion.div>

        {/* Principles Grid */}
        <motion.div
          variants={containerVariants}
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true, margin: "-100px" }}
          className="grid md:grid-cols-2 lg:grid-cols-4 gap-6 mb-16"
        >
          {principles.map((principle) => (
            <motion.div
              key={principle.title}
              variants={itemVariants}
              whileHover={{ y: -5 }}
              className="glass-card p-6 text-center hover:shadow-lg transition-all duration-300 group"
            >
              <div className="w-14 h-14 mx-auto rounded-2xl bg-accent/10 flex items-center justify-center mb-4 group-hover:scale-110 transition-transform">
                <principle.icon className="w-7 h-7 text-accent" />
              </div>
              <h3 className="font-display font-semibold text-foreground mb-2">
                {principle.title}
              </h3>
              <p className="text-sm text-muted-foreground">
                {principle.description}
              </p>
            </motion.div>
          ))}
        </motion.div>

        {/* Disclaimer Card */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: "-50px" }}
          transition={{ duration: 0.6 }}
          className="max-w-3xl mx-auto"
        >
          <div className="glass-card p-8 border-l-4 border-warning">
            <div className="flex items-start gap-4">
              <div className="w-12 h-12 rounded-xl bg-warning/10 flex items-center justify-center shrink-0">
                <AlertTriangle className="w-6 h-6 text-warning" />
              </div>
              <div>
                <h3 className="font-display text-lg font-semibold text-foreground mb-2">
                  Important Disclaimer
                </h3>
                <p className="text-muted-foreground mb-4">
                  SafeZone is an <strong className="text-foreground">independent community project</strong> and is 
                  <strong className="text-foreground"> not affiliated with</strong> any law enforcement agency, 
                  government body, or official safety organization.
                </p>
                <ul className="space-y-2 text-sm text-muted-foreground">
                  <li className="flex items-center gap-2">
                    <div className="w-1.5 h-1.5 rounded-full bg-warning" />
                    Community-reported data may not reflect official crime statistics
                  </li>
                  <li className="flex items-center gap-2">
                    <div className="w-1.5 h-1.5 rounded-full bg-warning" />
                    Always contact official emergency services (911) in emergencies
                  </li>
                  <li className="flex items-center gap-2">
                    <div className="w-1.5 h-1.5 rounded-full bg-warning" />
                    This app supplements, not replaces, official safety resources
                  </li>
                </ul>
              </div>
            </div>
          </div>
        </motion.div>
      </div>
    </section>
  );
};

export default PrivacySection;
