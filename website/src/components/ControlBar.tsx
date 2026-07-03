"use client";

import { useRef, useEffect } from "react";
import gsap from "gsap";

interface ControlBarProps {
  progress: number;
}

export default function ControlBar({ progress }: ControlBarProps) {
  const ref = useRef<HTMLDivElement>(null);
  const progressRef = useRef<HTMLDivElement>(null);
  const fpsRef = useRef<HTMLSpanElement>(null);

  useEffect(() => {
    if (!progressRef.current) return;
    gsap.to(progressRef.current, {
      width: `${progress * 100}%`,
      duration: 0.4,
      ease: "power2.out",
      overwrite: "auto",
    });
  }, [progress]);

  // Cycle FPS display
  useEffect(() => {
    const fpsVals = ["23.976", "29.97", "30", "48", "59.94", "60"];
    let i = 0;
    const interval = setInterval(() => {
      if (fpsRef.current) {
        fpsRef.current.textContent = fpsVals[i % fpsVals.length];
        i++;
      }
    }, 2000);
    return () => clearInterval(interval);
  }, []);

  return (
    <div
      ref={ref}
      className="absolute bottom-2 sm:bottom-[10px] left-1/2 -translate-x-1/2 w-[94%] max-w-[660px] z-20"
    >
      <div className="rounded-xl bg-[var(--color-panel)] backdrop-blur-xl border border-[var(--color-rule)] px-[14px] py-[3px]">
        {/* Timeline */}
        <div className="flex items-center gap-[6px] mb-[6px]">
          <span className="text-[9px] font-semibold text-[var(--color-ink-soft)] min-w-[34px] tabular-nums">
            {formatTime(progress * 296)}
          </span>
          <div className="flex-1 h-[3px] bg-[var(--color-rule)] rounded-full overflow-hidden">
            <div
              ref={progressRef}
              className="h-full rounded-full bg-[var(--color-accent)]"
              style={{ width: "0%" }}
            />
          </div>
          <span className="text-[9px] font-semibold text-[var(--color-muted)] min-w-[34px] tabular-nums text-right">
            04:56
          </span>
        </div>

        {/* Row */}
        <div className="grid grid-cols-[minmax(0,1fr)_auto_minmax(0,1fr)] items-center gap-2">
          {/* Left group */}
          <div className="min-w-0 flex items-center gap-2">
            <div className="hidden sm:flex items-center gap-[3px] min-w-0">
              <button
                type="button"
                aria-label="Mute preview audio"
                className="w-7 h-7 flex items-center justify-center text-[var(--color-muted)] hover:text-[var(--color-ink)] transition-colors"
              >
                <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <path d="M11 5L6 9H2v6h4l5 4V5z" />
                  <path d="M19 7l-5 5 5 5" />
                </svg>
              </button>
              <div className="w-[48px] h-[3px] bg-[var(--color-rule)] rounded-full overflow-hidden">
                <div className="h-full w-[65%] bg-[var(--color-muted)] rounded-full" />
              </div>
            </div>
            <div className="hidden sm:block w-[1px] h-[12px] bg-[var(--color-rule)]" />
            <div className="flex items-center gap-[2px] text-[8px] font-semibold text-[var(--color-muted)] min-w-0">
              <svg width="9" height="9" viewBox="0 0 24 24" fill="none" stroke="var(--color-accent)" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
                <rect x="2" y="3" width="20" height="14" rx="2" ry="2" />
                <line x1="8" y1="21" x2="16" y2="21" />
                <line x1="12" y1="17" x2="12" y2="21" />
              </svg>
              <span ref={fpsRef}>60</span>
              <span className="text-[6px] text-[var(--color-dim)]">FPS</span>
            </div>
          </div>

          {/* Center - Play controls */}
          <div className="flex items-center gap-2 sm:gap-3">
            <button
              type="button"
              aria-label="Previous chapter"
              className="w-8 h-8 sm:w-7 sm:h-7 rounded-full border border-[var(--color-rule)] flex items-center justify-center text-[var(--color-muted)] hover:text-[var(--color-ink)] transition-colors"
            >
              <svg width="9" height="9" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <polygon points="13 5 6 12 13 19 13 5" />
                <line x1="18" y1="5" x2="18" y2="19" />
              </svg>
            </button>
            <button
              type="button"
              aria-label="Play preview"
              className="w-9 h-9 sm:w-8 sm:h-8 rounded-full bg-[var(--color-accent)] text-[var(--color-accent-ink)] flex items-center justify-center hover:-translate-y-px active:translate-y-0 transition-transform"
            >
              <svg width="12" height="12" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
                <polygon points="8 5 19 12 8 19 8 5" />
              </svg>
            </button>
            <button
              type="button"
              aria-label="Next chapter"
              className="w-8 h-8 sm:w-7 sm:h-7 rounded-full border border-[var(--color-rule)] flex items-center justify-center text-[var(--color-muted)] hover:text-[var(--color-ink)] transition-colors"
            >
              <svg width="9" height="9" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <polygon points="11 5 18 12 11 19 11 5" />
                <line x1="6" y1="5" x2="6" y2="19" />
              </svg>
            </button>
          </div>

          {/* Right group */}
          <div className="min-w-0 flex items-center justify-end">
            <div className="flex items-center gap-[2px] p-[2px] bg-[oklch(22%_0.03_252_/_0.48)] rounded-full overflow-hidden">
              <div className="flex items-center gap-[2px] px-[7px] py-[3px] rounded-full bg-[var(--color-accent-soft)] border border-[var(--color-rule-strong)] text-[7px] font-semibold text-[var(--color-ink)]">
                <svg width="8" height="8" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
                  <rect x="2" y="2" width="20" height="20" rx="2.18" />
                  <rect x="6" y="6" width="4" height="4" />
                  <rect x="14" y="6" width="4" height="4" />
                  <rect x="6" y="14" width="4" height="4" />
                  <rect x="14" y="14" width="4" height="4" />
                </svg>
                <span>Frame⁺</span>
              </div>
              <div className="hidden sm:flex items-center gap-[2px] px-[7px] py-[3px] text-[7px] font-semibold text-[var(--color-dim)]">
                <svg width="8" height="8" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
                  <circle cx="12" cy="12" r="10" />
                  <polyline points="12 6 12 12 16 14" />
                </svg>
                <span>1x</span>
              </div>
              <div className="hidden md:flex items-center gap-[2px] px-[7px] py-[3px] text-[7px] font-semibold text-[var(--color-dim)]">
                <svg width="8" height="8" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
                  <path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z" />
                  <polyline points="14 2 14 8 20 8" />
                </svg>
                <span>Subs</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

function formatTime(seconds: number): string {
  const m = Math.floor(seconds / 60);
  const s = Math.floor(seconds % 60);
  return `${String(m).padStart(2, "0")}:${String(s).padStart(2, "0")}`;
}
