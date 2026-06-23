"use client";

const dockLeft = [16, 22, 18, 24, 19];
const dockRight = [21, 15, 23, 18];

export default function MacOSScene({ isActive }: { isActive: boolean }) {
  return (
    <div
      className={`absolute inset-0 transition-opacity duration-500 ${
        isActive ? "opacity-100" : "opacity-0 pointer-events-none"
      }`}
    >
      <div className="absolute inset-0 bg-gradient-to-br from-[#0a0d1a] via-[#111530] to-[#0a0d1a]" />
      <div className="absolute inset-0 overflow-hidden">
        <div className="absolute top-[-10%] left-[-5%] w-[60%] h-[60%] bg-gradient-to-br from-[#3B82F6]/5 via-[#8B5CF6]/3 to-transparent rounded-full blur-[100px]" />
        <div className="absolute bottom-[-10%] right-[-5%] w-[50%] h-[50%] bg-gradient-to-tl from-[#6366F1]/5 via-transparent to-transparent rounded-full blur-[80px]" />
      </div>
      <div className="absolute top-0 left-0 right-0 h-[6%] flex items-center justify-between px-[3%] glass-border border-t-0">
        <div className="flex items-center gap-3">
          <div className="flex items-center gap-1.5">
            <div className="w-2.5 h-2.5 rounded-full bg-[#FF5F57]" />
            <div className="w-2.5 h-2.5 rounded-full bg-[#FEBC2E]" />
            <div className="w-2.5 h-2.5 rounded-full bg-[#28C840]" />
          </div>
          <span className="text-[8px] font-semibold text-white/60 ml-3">Rift</span>
        </div>
        <div className="flex items-center gap-4 text-[7px] text-white/40">
          <span>File</span>
          <span>Edit</span>
          <span>View</span>
          <span>Playback</span>
          <span>Window</span>
          <span>Help</span>
        </div>
        <div className="flex items-center gap-2 text-[7px] text-white/40">
          <svg width="9" height="9" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
            <path d="M11 5L6 9H2v6h4l5 4V5z" />
            <path d="M15.54 8.46a5 5 0 010 7.07" />
            <path d="M19.07 4.93a10 10 0 010 14.14" />
          </svg>
          <span>Wi-Fi</span>
          <span>100%</span>
          <span className="text-white/60 font-semibold">10:41 PM</span>
        </div>
      </div>
      <div className="absolute bottom-[4%] left-1/2 -translate-x-1/2 flex items-end gap-[6px]">
        {dockLeft.map((size, i) => (
          <div
            key={i}
            className="w-[18px] h-[18px] rounded-lg bg-white/5 border border-white/5"
            style={{
              height: `${size}px`,
              width: `${Math.max(14, size - 3)}px`,
            }}
          />
        ))}
        <div className="w-[22px] h-[22px] rounded-xl bg-[#3B82F6]/20 border border-[#3B82F6]/30 flex items-center justify-center">
          <svg width="10" height="10" viewBox="0 0 24 24" fill="#3B82F6">
            <polygon points="8 5 19 12 8 19 8 5" />
          </svg>
        </div>
        {dockRight.map((size, i) => (
          <div
            key={i}
            className="w-[18px] h-[18px] rounded-lg bg-white/5 border border-white/5"
            style={{
              height: `${size}px`,
              width: `${Math.max(14, size - 3)}px`,
            }}
          />
        ))}
      </div>
      <div
        className="absolute inset-0 opacity-[0.03]"
        style={{
          backgroundImage:
            "linear-gradient(rgba(255,255,255,0.05) 1px, transparent 1px), linear-gradient(90deg, rgba(255,255,255,0.05) 1px, transparent 1px)",
          backgroundSize: "40px 40px",
        }}
      />
    </div>
  );
}
