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
      <div className="relative z-10 w-[clamp(120px,20vw,220px)]">
        <img
          src="/rift-logo.svg"
          alt="Rift"
          className="w-full h-auto"
          style={{
            filter: "drop-shadow(0 8px 24px rgba(0,0,0,0.3))",
          }}
        />
      </div>
      <p className="absolute bottom-[15%] text-[10px] text-white/30 tracking-[0.4em] uppercase">
        Cinematic Player
      </p>
    </div>
  );
}
