"use client";

function round2(n: number) {
  return Math.round(n * 100) / 100;
}

const spectrumLines = Array.from({ length: 32 }, (_, i) => {
  const angle = (i / 32) * 360;
  const rad = (angle * Math.PI) / 180;
  const innerR = 120;
  const outerR = 140 + (i % 7) * 8;
  return {
    x1: round2(500 + Math.cos(rad) * innerR),
    y1: round2(500 + Math.sin(rad) * innerR),
    x2: round2(500 + Math.cos(rad) * outerR),
    y2: round2(500 + Math.sin(rad) * outerR),
    angle: round2(angle),
    length: round2(outerR - innerR),
    duration: round2(1.5 + (i % 4) * 0.18),
    delay: round2(i * 0.05),
    lift: 20 + (i % 6) * 5,
  };
});

const rings = [60, 100, 150, 210, 280, 360, 450, 550, 660];

export default function AudioScene({ isActive }: { isActive: boolean }) {
  return (
    <div
      className={`absolute inset-0 transition-opacity duration-500 ${
        isActive ? "opacity-100" : "opacity-0 pointer-events-none"
      }`}
    >
      <div className="absolute inset-0 bg-gradient-to-br from-[#050510] via-[#0a0520] to-[#050510]" />
      <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[30%] h-[30%] bg-[#3B82F6]/10 rounded-full blur-[80px]" />
      <svg
        className="absolute inset-0 w-full h-full"
        viewBox="0 0 1000 1000"
        preserveAspectRatio="xMidYMid slice"
      >
        <defs>
          <linearGradient id="waveGrad" x1="0" y1="0" x2="1" y2="1">
            <stop offset="0%" stopColor="#3B82F6" stopOpacity="0.3" />
            <stop offset="50%" stopColor="#8B5CF6" stopOpacity="0.15" />
            <stop offset="100%" stopColor="#3B82F6" stopOpacity="0.05" />
          </linearGradient>
        </defs>
        <circle cx="500" cy="500" r="3" fill="#3B82F6" opacity="0.6">
          <animate attributeName="r" values="2;4;2" dur="2s" repeatCount="indefinite" />
        </circle>
        {rings.map((r, i) => (
          <circle
            key={i}
            cx="500"
            cy="500"
            r={r}
            fill="none"
            stroke="url(#waveGrad)"
            strokeWidth="1"
            opacity={0.4 - i * 0.04}
          >
            <animate attributeName="r" values={`${r};${r + 40};${r}`} dur={`${3 + i * 0.4}s`} repeatCount="indefinite" begin={`${i * 0.15}s`} />
          </circle>
        ))}
        {spectrumLines.map((line, i) => (
          <line
            key={i}
            x1={line.x1}
            y1={line.y1}
            x2={line.x2}
            y2={line.y2}
            stroke="#3B82F6"
            strokeWidth="2"
            strokeLinecap="round"
            opacity={0.2}
          >
            <animate attributeName="opacity" values="0.1;0.5;0.1" dur={`${line.duration}s`} repeatCount="indefinite" begin={`${line.delay}s`} />
            <animate
              attributeName="y2"
              values={`${line.y2};${line.y2 - line.lift};${line.y2}`}
              dur={`${line.duration}s`}
              repeatCount="indefinite"
              begin={`${line.delay}s`}
            />
          </line>
        ))}
      </svg>
    </div>
  );
}