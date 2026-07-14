"use client";

import { useEffect, useRef, useState } from "react";
import { ScrollTrigger } from "gsap/ScrollTrigger";
import StickyPlayer, { type StoryState } from "./StickyPlayer";
import { GITHUB_URL, GITHUB_LATEST_URL } from "@/lib/config";

const STEPS = [
  {
    text: "",
    eyebrow: "Native macOS video player",
    description: "A native macOS player built around the frame, not the chrome.",
    scene: 0,
    showControls: true,
    showHDR: false,
    progress: 0.04,
    scale: 1.6,
    heroLine: "The cinematic player for macOS.",
    heroDesc: "Rift turns your Mac into a clean cinema surface: HDR playback, Metal rendering, FFmpeg support, and controls that shrink away as the picture takes over.",
  },
  {
    text: "The window shrinks to let the video breathe.",
    eyebrow: "Scroll to dock",
    description: "The hero-sized player contracts into a compact window that stays with you as you browse.",
    scene: 1,
    showControls: true,
    showHDR: true,
    progress: 0.16,
    scale: 1.0,
    heroLine: "A player that shrinks when you need the screen.",
    heroDesc: "The hero window docks into a compact player that follows you as you scroll — the video never stops playing.",
  },
  {
    text: "HDR highlights stay alive.",
    eyebrow: "4K HDR",
    description: "Tone mapping keeps bright detail controlled across any display.",
    scene: 2,
    showControls: true,
    showHDR: true,
    progress: 0.32,
    scale: 0.98,
    heroLine: "HDR that looks right on any display.",
    heroDesc: "Adaptive tone mapping preserves highlight detail whether you're on a Pro Display XDR or an external monitor.",
  },
  {
    text: "Smooth motion at any frame rate.",
    eyebrow: "Frame+",
    description: "AI-powered interpolation generates fluid frames while controls fade when you're immersed.",
    scene: 3,
    showControls: true,
    showHDR: true,
    progress: 0.52,
    scale: 0.96,
    heroLine: "Neural frame generation. Real-time.",
    heroDesc: "The RIFE neural network interpolates frames on the GPU — 24 fps content plays back at 120 fps with no artifacts.",
  },
  {
    text: "Controls that feel part of the system.",
    eyebrow: "Native feel",
    description: "The interface settles into the player chrome, matching macOS design language exactly.",
    scene: 4,
    showControls: true,
    showHDR: true,
    progress: 0.7,
    scale: 0.94,
    heroLine: "Native macOS controls. No compromises.",
    heroDesc: "Every interaction follows platform conventions — spring animations, blur materials, and keyboard shortcuts that just work.",
  },
  {
    text: "The frame disappears. Only the picture remains.",
    eyebrow: "No distractions",
    description: "Controls auto-hide automatically. The video takes the full stage without interference.",
    scene: 5,
    showControls: false,
    showHDR: false,
    progress: 0.9,
    scale: 0.92,
    heroLine: "No chrome. Just the picture.",
    heroDesc: "Controls fade to nothing. The interface disappears. What remains is the frame — and what's inside it.",
  },
  {
    text: "",
    eyebrow: "Rift",
    description: "Cinematic Player",
    scene: 6,
    showControls: false,
    showHDR: false,
    progress: 1,
    scale: 0.92,
    heroLine: "Rift",
    heroDesc: "",
  },
];

const STORY_LABELS = STEPS.slice(1, 6).map((step) => step.eyebrow);

function lerpState(progress: number): StoryState {
  const p = Math.max(0, Math.min(1, progress));
  const total = STEPS.length - 1;
  const raw = p * total;
  const idx = Math.min(Math.floor(raw), total - 1);
  const f = raw - idx;
  const a = STEPS[idx];
  const b = STEPS[Math.min(idx + 1, total)];
  return {
    scene: f < 0.5 ? a.scene : b.scene,
    text: f < 0.5 ? a.text : b.text,
    eyebrow: f < 0.5 ? a.eyebrow : b.eyebrow,
    description: f < 0.5 ? a.description : b.description,
    showControls: f < 0.5 ? a.showControls : b.showControls,
    showHDR: f < 0.5 ? a.showHDR : b.showHDR,
    progress: a.progress + (b.progress - a.progress) * f,
    scale: a.scale + (b.scale - a.scale) * f,
  };
}

export default function ScrollStory() {
  const sectionRef = useRef<HTMLElement>(null);
  const [state, setState] = useState<StoryState>(STEPS[0]);
  const [isPlaying, setIsPlaying] = useState(true);
  const scrollProgressRef = useRef(0);
  const timerProgressRef = useRef(0);
  const hasUserScrolledRef = useRef(false);
  const rafRef = useRef<number | null>(null);

  useEffect(() => {
    const section = sectionRef.current;
    if (!section) return;

    const st = ScrollTrigger.create({
      trigger: section,
      start: "top top",
      end: "bottom bottom",
      scrub: 1,
      anticipatePin: 1,
      invalidateOnRefresh: true,
      onUpdate: (self) => {
        scrollProgressRef.current = self.progress;
        if (self.progress > 0.01 && !hasUserScrolledRef.current) {
          hasUserScrolledRef.current = true;
        }
      },
    });

    return () => st.kill();
  }, []);

  // Advance timer progress when playing (only for users who never scroll)
  useEffect(() => {
    const DURATION = 296;
    let lastTime = performance.now();

    function tick(now: number) {
      if (isPlaying && !hasUserScrolledRef.current) {
        const dt = (now - lastTime) / 1000;
        timerProgressRef.current = Math.min(1, timerProgressRef.current + dt / DURATION);
      }
      lastTime = now;

      const effective = hasUserScrolledRef.current
        ? scrollProgressRef.current
        : Math.max(scrollProgressRef.current, timerProgressRef.current);
      const next = lerpState(effective);
      setState((prev) =>
        prev.progress !== next.progress || prev.scene !== next.scene ? next : prev
      );

      rafRef.current = requestAnimationFrame(tick);
    }

    rafRef.current = requestAnimationFrame(tick);
    return () => {
      if (rafRef.current) cancelAnimationFrame(rafRef.current);
    };
  }, [isPlaying]);

  const activeStory = Math.max(0, Math.min(STORY_LABELS.length - 1, state.scene - 1));
  const currentStep = STEPS[state.scene] ?? STEPS[0];

  return (
    <section id="hero" ref={sectionRef} className="story-section">
      <div className="story-sticky">
        <div className="story-shell">
          <div className="hero-copy">
            <div className="hero-kicker">
              <span className="w-2 h-2 rounded-full bg-[var(--color-accent)] shadow-[0_0_12px_var(--color-accent-soft)]" />
              {currentStep.heroLine === "Rift" ? "Native macOS video player" : currentStep.eyebrow}
            </div>
            <h1 className="hero-title" key={currentStep.scene === state.scene ? currentStep.scene : state.scene}>
              {currentStep.heroLine}
            </h1>
            <div className="w-12 h-[2px] bg-gradient-to-r from-[var(--color-accent)] to-transparent mt-4 mb-6" />
            {currentStep.heroDesc && (
              <p className="hero-lede">{currentStep.heroDesc}</p>
            )}
            <div className="hero-actions">
              <a href={GITHUB_LATEST_URL} target="_blank" rel="noopener noreferrer" className="hero-cta hero-cta--primary">
                Download for macOS
              </a>
              <a
                href={GITHUB_URL}
                target="_blank"
                rel="noopener noreferrer"
                className="hero-cta hero-cta--secondary"
              >
                <svg width="14" height="14" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
                  <path d="M12 0C5.37 0 0 5.37 0 12c0 5.31 3.435 9.795 8.205 11.385.6.105.825-.255.825-.57 0-.285-.015-1.23-.015-2.235-3.015.555-3.795-.735-4.035-1.41-.135-.345-.72-1.41-1.23-1.695-.42-.225-1.02-.78-.015-.795.945-.015 1.62.87 1.845 1.23 1.08 1.815 2.805 1.305 3.495.99.105-.78.42-1.305.765-1.605-2.67-.3-5.46-1.335-5.46-5.925 0-1.305.465-2.385 1.23-3.225-.12-.3-.54-1.53.12-3.18 0 0 1.005-.315 3.3 1.23.96-.27 1.98-.405 3-.405s2.04.135 3 .405c2.295-1.56 3.3-1.23 3.3-1.23.66 1.65.24 2.88.12 3.18.765.84 1.23 1.905 1.23 3.225 0 4.605-2.805 5.625-5.475 5.925.435.375.81 1.095.81 2.22 0 1.605-.015 2.895-.015 3.3 0 .315.225.69.825.57A12.02 12.02 0 0024 12c0-6.63-5.37-12-12-12z" />
                </svg>
                View source
              </a>
              <a
                href={GITHUB_URL}
                target="_blank"
                rel="noopener noreferrer"
                className="github-stars-badge"
                aria-label="GitHub stars"
              >
                <svg width="12" height="12" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
                  <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2" />
                </svg>
                <span>Star</span>
              </a>
            </div>
          </div>

          <div className="min-w-0">
            <StickyPlayer
              state={state}
              isPlaying={isPlaying}
              onPlayToggle={() => {
                setIsPlaying((v) => !v);
                hasUserScrolledRef.current = true;
              }}
              onPrev={() => {
                const p = Math.max(0, state.progress - 0.15);
                scrollProgressRef.current = p;
                timerProgressRef.current = p;
                hasUserScrolledRef.current = true;
              }}
              onNext={() => {
                const p = Math.min(1, state.progress + 0.15);
                scrollProgressRef.current = p;
                timerProgressRef.current = p;
                hasUserScrolledRef.current = true;
              }}
            />
            <div className="story-side" aria-hidden="true">
              {STORY_LABELS.map((label, index) => (
                <div
                  key={label}
                  className={`story-chip ${activeStory === index ? "is-active" : ""}`}
                >
                  {label}
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>

      {/* Scroll indicator */}
      <div
        className="scroll-indicator"
        style={{
          opacity: state.progress > 0.15 ? 0 : 1,
          transform: state.progress > 0.15 ? "translateY(8px)" : "translateY(0)",
          pointerEvents: state.progress > 0.15 ? "none" : "auto",
        }}
      >
        <span className="scroll-indicator__label">Scroll to explore</span>
        <svg className="scroll-indicator__chevron" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
          <polyline points="6 9 12 15 18 9" />
        </svg>
      </div>
    </section>
  );
}
