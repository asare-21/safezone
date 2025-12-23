import { Github, Twitter, Linkedin, Mail, Heart, Shield } from "lucide-react";
import { Button } from "@/components/ui/button";

const Footer = () => {
  const currentYear = new Date().getFullYear();

  const links = {
    project: [
      { label: "Features", href: "#features" },
      { label: "Tech Stack", href: "#tech-stack" },
      { label: "Architecture", href: "#architecture" },
      { label: "Privacy", href: "#privacy" },
    ],
    resources: [
      { label: "Documentation", href: "https://github.com/asare-21/safezone#readme" },
      { label: "Quick Start", href: "https://github.com/asare-21/safezone/blob/main/docs/QUICK_START.md" },
      { label: "Backend Integration", href: "https://github.com/asare-21/safezone/blob/main/docs/BACKEND_INTEGRATION.md" },
      { label: "Changelog", href: "https://github.com/asare-21/safezone/commits/main" },
    ],
    social: [
      { icon: Github, label: "GitHub", href: "https://github.com/asare-21/safezone" },
      { icon: Twitter, label: "Twitter", href: "https://twitter.com" },
      { icon: Linkedin, label: "LinkedIn", href: "https://linkedin.com" },
      { icon: Mail, label: "Email", href: "mailto:contact@safezone.app" },
    ],
  };

  return (
    <footer className="bg-foreground text-background py-16 relative overflow-hidden">
      {/* Background Pattern */}
      <div className="absolute inset-0 opacity-5">
        <svg className="w-full h-full" viewBox="0 0 1000 400">
          <defs>
            <pattern id="footer-grid" width="50" height="50" patternUnits="userSpaceOnUse">
              <circle cx="25" cy="25" r="1" fill="currentColor" />
            </pattern>
          </defs>
          <rect width="100%" height="100%" fill="url(#footer-grid)" />
        </svg>
      </div>

      <div className="container mx-auto px-4 relative">
        <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-12 mb-12">
          {/* Brand */}
          <div className="lg:col-span-1">
            <a href="#" className="flex items-center gap-2 mb-4">
              <div className="w-10 h-10 rounded-xl gradient-hero flex items-center justify-center">
                <Shield className="w-5 h-5 text-primary-foreground" />
              </div>
              <span className="font-display font-bold text-xl">SafeZone</span>
            </a>
            <p className="text-background/70 text-sm mb-6">
              Crowdsourced personal safety alerts. 
              Stay informed about your surroundings with real-time community reports.
            </p>
            <div className="flex gap-3">
              {links.social.map((social) => (
                <a
                  key={social.label}
                  href={social.href}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="w-10 h-10 rounded-lg bg-background/10 hover:bg-background/20 flex items-center justify-center transition-colors"
                  aria-label={social.label}
                >
                  <social.icon className="w-5 h-5" />
                </a>
              ))}
            </div>
          </div>

          {/* Project Links */}
          <div>
            <h4 className="font-display font-semibold mb-4">Project</h4>
            <ul className="space-y-3">
              {links.project.map((link) => (
                <li key={link.label}>
                  <a
                    href={link.href}
                    className="text-background/70 hover:text-background transition-colors text-sm"
                  >
                    {link.label}
                  </a>
                </li>
              ))}
            </ul>
          </div>

          {/* Resources */}
          <div>
            <h4 className="font-display font-semibold mb-4">Resources</h4>
            <ul className="space-y-3">
              {links.resources.map((link) => (
                <li key={link.label}>
                  <a
                    href={link.href}
                    className="text-background/70 hover:text-background transition-colors text-sm"
                  >
                    {link.label}
                  </a>
                </li>
              ))}
            </ul>
          </div>

          {/* CTA */}
          <div>
            <h4 className="font-display font-semibold mb-4">Get Started</h4>
            <p className="text-background/70 text-sm mb-4">
              Ready to contribute or explore the codebase?
            </p>
            <Button variant="hero" size="sm" asChild className="w-full">
              <a href="https://github.com/asare-21/safezone" target="_blank" rel="noopener noreferrer">
                <Github className="w-4 h-4" />
                Star on GitHub
              </a>
            </Button>
          </div>
        </div>

        {/* Bottom Bar */}
        <div className="pt-8 border-t border-background/10 flex flex-col md:flex-row justify-between items-center gap-4">
          <p className="text-background/50 text-sm text-center md:text-left">
            © {currentYear} SafeZone. A portfolio project built with{" "}
            <Heart className="w-4 h-4 inline text-destructive" /> for learning.
          </p>
          <p className="text-background/50 text-sm">
            Not affiliated with any law enforcement agency.
          </p>
        </div>
      </div>
    </footer>
  );
};

export default Footer;
