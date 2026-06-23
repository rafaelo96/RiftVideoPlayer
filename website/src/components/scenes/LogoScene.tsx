"use client";

export default function LogoScene({ isActive }: { isActive: boolean }) {
  return (
    <div
      className={`absolute inset-0 flex items-center justify-center transition-opacity duration-500 ${
        isActive ? "opacity-100" : "opacity-0 pointer-events-none"
      }`}
    >
      <div className="absolute inset-0 bg-black" />
      <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[40%] h-[40%] bg-[#3B82F6]/8 rounded-full blur-[100px]" />
      <div className="relative z-10 text-center">
        <div className="flex items-center justify-center gap-2 mb-2">
          <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-[#3B82F6] to-[#2563EB] flex items-center justify-center shadow-lg shadow-[#3B82F6]/20">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="white">
              <polygon points="8 5 19 12 8 19 8 5" />
            </svg>
          </div>
        </div>
        <h2
          className="text-[clamp(32px,5vw,52px)] font-bold tracking-tight text-white"
          style={{ letterSpacing: "-0.03em" }}
        >
          RIFT
        </h2>
        <p className="text-[10px] text-white/30 tracking-[0.4em] uppercase mt-2">
          Cinematic Player
        </p>
      </div>
    </div>
  );
}
