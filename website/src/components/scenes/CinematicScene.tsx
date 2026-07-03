"use client";

const stars = Array.from({ length: 30 }, (_, i) => ({
  left: `${(i * 37 + 11) % 100}%`,
  top: `${(i * 53 + 17) % 100}%`,
  opacity: 0.3 + ((i * 7) % 5) * 0.1,
  duration: 3 + (i % 5) * 0.7,
  delay: (i % 6) * 0.45,
}));

export default function CinematicScene({ isActive }: { isActive: boolean }) {
  return (
    <div
      className={`absolute inset-0 transition-opacity duration-500 ${
        isActive ? "opacity-100" : "opacity-0 pointer-events-none"
      }`}
    >
      <div className="absolute inset-0 bg-gradient-to-br from-[#050816] via-[#0a0e2a] to-[#050816]" />
      <div className="absolute inset-0 overflow-hidden">
        <div className="absolute top-[-20%] left-[-10%] w-[80%] h-[80%] bg-gradient-to-br from-[#3B82F6]/10 via-transparent to-transparent rounded-full blur-3xl animate-pulse-glow" />
        <div className="absolute bottom-[-20%] right-[-10%] w-[60%] h-[60%] bg-gradient-to-tl from-[#8B5CF6]/8 via-transparent to-transparent rounded-full blur-3xl" />
      </div>
      <div
        className="absolute inset-0 opacity-[0.08]"
        style={{
          background:
            "linear-gradient(105deg, transparent 30%, rgba(59,130,246,0.4) 45%, rgba(139,92,246,0.2) 50%, transparent 65%)",
          animation: "ray-sweep 8s ease-in-out infinite",
        }}
      />
      <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[50%] h-[50%]">
        <div className="w-full h-full bg-gradient-to-r from-[#3B82F6]/8 via-[#8B5CF6]/5 to-[#3B82F6]/8 rounded-full blur-[100px]" />
      </div>
      <div className="absolute inset-0">
        {stars.map((star, i) => (
          <div
            key={i}
            className="absolute w-px h-px bg-white/30 rounded-full"
            style={{
              left: star.left,
              top: star.top,
              opacity: star.opacity,
              animation: `float ${star.duration}s ease-in-out infinite`,
              animationDelay: `${star.delay}s`,
            }}
          />
        ))}
      </div>
      <div
        className="absolute inset-0 opacity-[0.015] mix-blend-overlay pointer-events-none"
        style={{
          backgroundImage:
            "url(\"data:image/svg+xml,%3Csvg viewBox='0 0 128 128' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noise'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.65' numOctaves='3' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noise)'/%3E%3C/svg%3E\")",
        }}
      />
    </div>
  );
}
