"use client";

export default function HDRScene({ isActive }: { isActive: boolean }) {
  return (
    <div
      className={`absolute inset-0 transition-opacity duration-500 ${
        isActive ? "opacity-100" : "opacity-0 pointer-events-none"
      }`}
    >
      <div className="absolute inset-0 bg-gradient-to-br from-[#1a0e05] via-[#2a1508] to-[#0d0a15]" />
      <div className="absolute inset-0 overflow-hidden">
        <div className="absolute top-[10%] left-[15%] w-[70%] h-[60%] bg-gradient-to-r from-[#F59E0B]/15 via-[#F97316]/10 to-[#3B82F6]/5 rounded-full blur-[120px]" />
        <div className="absolute top-[30%] left-[30%] w-[40%] h-[40%] bg-gradient-to-r from-[#FBBF24]/10 via-[#F59E0B]/8 to-transparent rounded-full blur-[80px]" />
      </div>
      <div className="absolute top-[20%] left-[25%] w-[8px] h-[8px] bg-white/60 rounded-full blur-[2px]" />
      <div className="absolute top-[22%] left-[28%] w-[4px] h-[4px] bg-white/40 rounded-full blur-[1px]" />
      <div className="absolute top-[35%] left-[60%] w-[6px] h-[6px] bg-[#FBBF24]/50 rounded-full blur-[2px]" />
      <div
        className="absolute top-[25%] left-[20%] w-[60%] h-[1px] bg-gradient-to-r from-transparent via-white/20 to-transparent blur-[2px]"
        style={{ transform: "rotate(-5deg)" }}
      />
      <div className="absolute inset-0 bg-gradient-to-t from-[#F59E0B]/3 via-transparent to-transparent" />
      <div className="absolute inset-0 bg-gradient-to-b from-[#3B82F6]/3 via-transparent to-transparent" />
      <div className="absolute top-[15%] right-[20%] w-[20px] h-[20px] bg-[#FBBF24]/20 rounded-full blur-[8px]" />
      <div className="absolute top-[18%] right-[22%] w-[8px] h-[8px] bg-[#FBBF24]/15 rounded-full blur-[4px]" />
    </div>
  );
}
