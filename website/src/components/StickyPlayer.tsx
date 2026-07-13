"use client";

import { useEffect, useRef } from "react";
import gsap from "gsap";
import CinematicScene from "./scenes/CinematicScene";
import HDRScene from "./scenes/HDRScene";
import AudioScene from "./scenes/AudioScene";
import MacOSScene from "./scenes/MacOSScene";
import LogoScene from "./scenes/LogoScene";
import ControlBar from "./ControlBar";

export interface StoryState {
  scene: number;
  text: string;
  eyebrow: string;
  description: string;
  showControls: boolean;
  showHDR: boolean;
  progress: number;
  scale: number;
}

interface StickyPlayerProps {
  state: StoryState;
  isPlaying: boolean;
  onPlayToggle: () => void;
  onPrev?: () => void;
  onNext?: () => void;
}

export default function StickyPlayer({ state, isPlaying, onPlayToggle, onPrev, onNext }: StickyPlayerProps) {
  const textRef = useRef<HTMLDivElement>(null);
  const zoomRef = useRef<HTMLDivElement>(null);

  // Animate main text
  useEffect(() => {
    const el = textRef.current;
    if (!el) return;
    const tween = gsap.fromTo(
      el,
      { opacity: 0, y: 20, filter: "blur(8px)" },
      {
        opacity: 1,
        y: 0,
        filter: "blur(0px)",
        duration: 0.6,
        ease: "power3.out",
        overwrite: "auto",
      }
    );
    return () => {
      tween.kill();
      gsap.killTweensOf(el);
    };
  }, [state.text]);

  return (
    <div className="w-full flex justify-center px-0 sm:px-4">
      <div className="relative w-full max-w-[980px] rounded-[1.15rem] overflow-hidden premium-shadow">
        {/* Window bar — never scaled */}
        <div className="relative z-10 flex items-center gap-2 px-3 sm:px-4 py-[10px] bg-[var(--color-panel-solid)] border-b border-[var(--color-rule)]">
          <div className="flex-1 text-center">
            <span className="text-[10px] font-medium text-[var(--color-muted)] tracking-wide">
              Rift — 4K HDR Demo.mov
            </span>
          </div>
          <div
            className={`flex items-center gap-1 px-2 py-0.5 rounded text-[8px] font-bold tracking-wider transition-colors duration-500 ${
              state.showHDR
                ? "bg-[var(--color-warm-soft)] text-[var(--color-warm)] border border-[var(--color-rule-strong)]"
                : "bg-transparent text-[var(--color-dim)] border border-transparent"
            }`}
          >
            <svg width="8" height="8" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
              <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2" />
            </svg>
            <span>HDR</span>
          </div>
          {state.showHDR && (
            <span className="text-[8px] font-bold text-[var(--color-muted)] tracking-wider">4K</span>
          )}
        </div>

        {/* Screen area — fixed aspect, clips zoom */}
        <div className="relative w-full aspect-video overflow-hidden bg-[oklch(8%_0.02_252)]">
          {/* Zoom layer — only video scenes scale */}
          <div
            ref={zoomRef}
            className="absolute inset-0"
            style={{ transform: `scale(${state.scale})`, transformOrigin: "center center" }}
          >
            <CinematicScene isActive={state.scene === 0 || state.scene === 1} />
            <HDRScene isActive={state.scene === 2} />
            <AudioScene isActive={state.scene === 3} />
            <MacOSScene isActive={state.scene === 4} />

            {/* Black overlay for LogoScene transition */}
            <div
              className={`absolute inset-0 transition-colors duration-500 ${
                state.scene >= 5 ? "bg-[oklch(8%_0.02_252)]" : "bg-transparent"
              }`}
            />

            <LogoScene isActive={state.scene === 6} />
          </div>

          {/* Story text — never scaled */}
          {state.text && (
            <div
              ref={textRef}
              className="absolute inset-0 flex items-center justify-center z-10 pointer-events-none px-4 sm:px-6"
            >
              <div className="w-full max-w-[28rem] text-center">
                <div className="font-mono text-[9px] sm:text-[11px] font-bold tracking-[0.16em] uppercase text-[var(--color-accent)] mb-2 sm:mb-3">
                  {state.eyebrow}
                </div>
                <h3
                  className="font-display text-[clamp(17px,2.6vw,32px)] font-[800] tracking-[-0.03em] text-center leading-[1.1] text-[var(--color-ink)]"
                  style={{ textShadow: "0 12px 32px oklch(5% 0.02 252 / 0.7)" }}
                >
                  {state.text}
                </h3>
                <p className="mt-2 sm:mt-3 text-[10px] sm:text-sm text-[var(--color-ink-soft)] leading-relaxed">
                  {state.description}
                </p>
              </div>
            </div>
          )}

          {/* Controls — never scaled */}
          <div
            className={`absolute inset-x-0 bottom-0 transition-[opacity,transform] duration-700 ${
              state.showControls
                ? "opacity-100 translate-y-0"
                : "opacity-0 translate-y-4 pointer-events-none"
            }`}
            inert={!state.showControls ? true : undefined}
          >
            <ControlBar progress={state.progress} isPlaying={isPlaying} onPlayToggle={onPlayToggle} onPrev={onPrev} onNext={onNext} />
          </div>
        </div>
      </div>
    </div>
  );
}
