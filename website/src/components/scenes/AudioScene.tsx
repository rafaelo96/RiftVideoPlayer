"use client";

import { useRef, useEffect } from "react";

function round2(n: number) {
  return Math.round(n * 100) / 100;
}

const SPECTRUM_COUNT = 48;
const RADIUS_CENTER = 500;

const spectrumLines = Array.from({ length: SPECTRUM_COUNT }, (_, i) => {
  const angle = (i / SPECTRUM_COUNT) * 360;
  const rad = (angle * Math.PI) / 180;
  const innerR = 120;
  const outerR = 140 + (i % 7) * 8;
  const x1 = round2(RADIUS_CENTER + Math.cos(rad) * innerR);
  const y1 = round2(RADIUS_CENTER + Math.sin(rad) * innerR);
  const x2 = round2(RADIUS_CENTER + Math.cos(rad) * outerR);
  const y2 = round2(RADIUS_CENTER + Math.sin(rad) * outerR);
  const lift = 20 + (i % 6) * 5;
  const sway = -10 + (i % 5) * 5;

  return {
    x1, y1, x2, y2,
    x2Active: round2(x2 + sway),
    y2Active: round2(y2 - lift),
    duration: round2(1.5 + (i % 4) * 0.18),
    delay: round2(i * 0.05),
  };
});

export default function AudioScene({ isActive }: { isActive: boolean }) {
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const frameRef = useRef<number | null>(null);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas || !isActive) return;
    const ctx = canvas.getContext("2d");
    if (!ctx) return;

    canvas.width = 1000;
    canvas.height = 1000;

    let start = performance.now();

    function draw(now: number) {
      if (!ctx || !canvas) return;
      const t = (now - start) / 1000;

      ctx.clearRect(0, 0, canvas.width, canvas.height);

      // Draw spectrum lines
      for (const line of spectrumLines) {
        const pulse = 0.1 + 0.4 * (0.5 + 0.5 * Math.sin(t * (2 * Math.PI / line.duration) + line.delay * 5));
        const liftOffset = (line.y2Active - line.y2) * (0.5 + 0.5 * Math.sin(t * (2 * Math.PI / line.duration) + line.delay * 5));
        const swayOffset = (line.x2Active - line.x2) * (0.5 + 0.5 * Math.sin(t * (2 * Math.PI / line.duration) + line.delay * 5));

        ctx.beginPath();
        ctx.moveTo(line.x1, line.y1);
        ctx.lineTo(line.x2 + swayOffset, line.y2 + liftOffset);
        ctx.strokeStyle = `rgba(59, 130, 246, ${pulse})`;
        ctx.lineWidth = 2;
        ctx.lineCap = "round";
        ctx.stroke();
      }

      // Draw concentric circles
      const circles = [60, 100, 150, 210, 280, 360, 450, 550, 660];
      for (let i = 0; i < circles.length; i++) {
        const r = circles[i] + 20 * (0.5 + 0.5 * Math.sin(t * (2 * Math.PI / (3 + i * 0.4)) + i * 0.15));
        const opacity = 0.4 - i * 0.04 - 0.15 * (0.5 + 0.5 * Math.sin(t * (2 * Math.PI / (3 + i * 0.4)) + i * 0.15));
        ctx.beginPath();
        ctx.arc(RADIUS_CENTER, RADIUS_CENTER, r, 0, Math.PI * 2);
        ctx.strokeStyle = `rgba(59, 130, 246, ${Math.max(0, opacity)})`;
        ctx.lineWidth = 1;
        ctx.stroke();
      }

      // Draw center dot
      ctx.beginPath();
      ctx.arc(RADIUS_CENTER, RADIUS_CENTER, 3, 0, Math.PI * 2);
      ctx.fillStyle = "rgba(59, 130, 246, 0.6)";
      ctx.fill();

      frameRef.current = requestAnimationFrame(draw);
    }

    frameRef.current = requestAnimationFrame(draw);
    return () => {
      if (frameRef.current) cancelAnimationFrame(frameRef.current);
    };
  }, [isActive]);

  return (
    <div
      className={`absolute inset-0 transition-opacity duration-500 ${
        isActive ? "opacity-100" : "opacity-0 pointer-events-none"
      }`}
    >
      <div className="absolute inset-0 bg-gradient-to-br from-[#050510] via-[#0a0520] to-[#050510]" />
      <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[30%] h-[30%] bg-[#3B82F6]/10 rounded-full blur-[80px]" />
      <canvas
        ref={canvasRef}
        className="absolute inset-0 w-full h-full"
        aria-hidden="true"
      />
    </div>
  );
}