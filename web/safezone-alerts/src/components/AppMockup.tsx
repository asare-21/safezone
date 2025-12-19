import { MapPin, Bell, AlertTriangle, Shield, Navigation, Phone } from "lucide-react";

const AppMockup = () => {
  const mockIncidents = [
    { type: "Theft", time: "2 min ago", color: "bg-safezone-orange" },
    { type: "Suspicious Activity", time: "15 min ago", color: "bg-safezone-blue" },
    { type: "Harassment", time: "1 hr ago", color: "bg-safezone-red" },
  ];

  return (
    <div className="relative">
      {/* Glow Effect */}
      <div className="absolute -inset-4 bg-gradient-to-r from-primary/20 to-accent/20 rounded-[3rem] blur-2xl opacity-60" />
      
      {/* Phone Frame */}
      <div className="relative bg-foreground rounded-[3rem] p-3 shadow-2xl">
        <div className="w-[280px] md:w-[320px] h-[580px] md:h-[640px] bg-background rounded-[2.5rem] overflow-hidden relative">
          {/* Status Bar */}
          <div className="absolute top-0 left-0 right-0 h-12 bg-background/80 backdrop-blur-sm z-20 flex items-center justify-between px-6">
            <span className="text-xs font-medium text-foreground">9:41</span>
            <div className="absolute left-1/2 -translate-x-1/2 w-24 h-6 bg-foreground rounded-full" />
            <div className="flex items-center gap-1">
              <div className="w-4 h-2 bg-accent rounded-sm" />
            </div>
          </div>

          {/* Map Background */}
          <div className="absolute inset-0 bg-safezone-blue-light">
            <svg className="w-full h-full opacity-30" viewBox="0 0 400 800">
              {/* Grid Pattern */}
              <defs>
                <pattern id="grid" width="40" height="40" patternUnits="userSpaceOnUse">
                  <path d="M 40 0 L 0 0 0 40" fill="none" stroke="currentColor" strokeWidth="0.5" className="text-primary/30" />
                </pattern>
              </defs>
              <rect width="100%" height="100%" fill="url(#grid)" />
              
              {/* Simulated Roads */}
              <path d="M 0 200 Q 200 180 400 220" stroke="currentColor" strokeWidth="8" fill="none" className="text-muted" />
              <path d="M 150 0 Q 170 400 120 800" stroke="currentColor" strokeWidth="6" fill="none" className="text-muted" />
              <path d="M 280 0 Q 260 400 300 800" stroke="currentColor" strokeWidth="4" fill="none" className="text-muted" />
              <path d="M 0 500 Q 200 480 400 520" stroke="currentColor" strokeWidth="6" fill="none" className="text-muted" />
            </svg>
          </div>

          {/* Incident Markers */}
          <div className="absolute top-32 left-16 animate-pulse">
            <div className="w-8 h-8 bg-safezone-orange rounded-full flex items-center justify-center shadow-lg">
              <AlertTriangle className="w-4 h-4 text-safezone-orange-light" />
            </div>
            <div className="absolute -bottom-1 left-1/2 -translate-x-1/2 w-0 h-0 border-l-4 border-r-4 border-t-8 border-l-transparent border-r-transparent border-t-safezone-orange" />
          </div>

          <div className="absolute top-56 right-12 animate-pulse animation-delay-200">
            <div className="w-8 h-8 bg-safezone-red rounded-full flex items-center justify-center shadow-lg">
              <AlertTriangle className="w-4 h-4 text-safezone-red-light" />
            </div>
            <div className="absolute -bottom-1 left-1/2 -translate-x-1/2 w-0 h-0 border-l-4 border-r-4 border-t-8 border-l-transparent border-r-transparent border-t-safezone-red" />
          </div>

          <div className="absolute top-72 left-24 animate-pulse animation-delay-400">
            <div className="w-6 h-6 bg-safezone-blue rounded-full flex items-center justify-center shadow-lg opacity-70">
              <div className="w-2 h-2 bg-safezone-blue-light rounded-full" />
            </div>
          </div>

          {/* User Location */}
          <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2">
            <div className="relative">
              <div className="absolute -inset-4 bg-primary/20 rounded-full animate-ping" />
              <div className="absolute -inset-2 bg-primary/30 rounded-full" />
              <div className="w-5 h-5 bg-primary rounded-full border-2 border-primary-foreground shadow-lg" />
            </div>
          </div>

          {/* Bottom Card */}
          <div className="absolute bottom-4 left-4 right-4 glass-card p-4 z-10">
            <div className="flex items-center justify-between mb-3">
              <div className="flex items-center gap-2">
                <div className="w-8 h-8 rounded-lg gradient-hero flex items-center justify-center">
                  <Shield className="w-4 h-4 text-primary-foreground" />
                </div>
                <span className="font-display font-semibold text-foreground text-sm">SafeZone</span>
              </div>
              <div className="flex items-center gap-1 px-2 py-1 bg-accent/10 rounded-full">
                <div className="w-2 h-2 bg-accent rounded-full animate-pulse" />
                <span className="text-xs text-accent font-medium">Active</span>
              </div>
            </div>

            <div className="space-y-2">
              {mockIncidents.map((incident, i) => (
                <div
                  key={i}
                  className="flex items-center gap-3 p-2 rounded-lg bg-secondary/50 hover:bg-secondary transition-colors"
                >
                  <div className={`w-2 h-2 rounded-full ${incident.color}`} />
                  <span className="text-xs font-medium text-foreground flex-1">{incident.type}</span>
                  <span className="text-xs text-muted-foreground">{incident.time}</span>
                </div>
              ))}
            </div>

            <div className="flex gap-2 mt-4">
              <button className="flex-1 flex items-center justify-center gap-2 py-2 bg-primary text-primary-foreground rounded-lg text-xs font-medium hover:bg-primary/90 transition-colors">
                <Bell className="w-3 h-3" />
                Report
              </button>
              <button className="flex-1 flex items-center justify-center gap-2 py-2 bg-destructive text-destructive-foreground rounded-lg text-xs font-medium hover:bg-destructive/90 transition-colors">
                <Phone className="w-3 h-3" />
                Emergency
              </button>
            </div>
          </div>
        </div>
      </div>

      {/* Floating Elements */}
      <div className="absolute -top-4 -right-4 glass-card p-3 animate-float">
        <div className="flex items-center gap-2">
          <div className="w-8 h-8 rounded-lg bg-safezone-orange-light flex items-center justify-center">
            <Bell className="w-4 h-4 text-safezone-orange" />
          </div>
          <div>
            <div className="text-xs font-medium text-foreground">Alert Nearby</div>
            <div className="text-xs text-muted-foreground">200m away</div>
          </div>
        </div>
      </div>

      <div className="absolute -bottom-4 -left-4 glass-card p-3 animate-float animation-delay-300">
        <div className="flex items-center gap-2">
          <div className="w-8 h-8 rounded-lg bg-safezone-green-light flex items-center justify-center">
            <Shield className="w-4 h-4 text-safezone-green" />
          </div>
          <div>
            <div className="text-xs font-medium text-foreground">Area Status</div>
            <div className="text-xs text-accent font-medium">Generally Safe</div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default AppMockup;
