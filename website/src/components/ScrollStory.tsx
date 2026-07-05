"use client";

import { useEffect, useRef, useState } from "react";
import { ScrollTrigger } from "gsap/ScrollTrigger";
import StickyPlayer, { type StoryState } from "./StickyPlayer";

const STEPS = [
  {
    text: "",
    eyebrow: "Cinematic playback",
    description: "A native macOS player built around the frame, not the chrome.",
    scene: 0,
    showControls: true,
    showHDR: false,
    progress: 0.04,
    scale: 1.6,
  },
  {
    text: "The player recedes into place.",
    eyebrow: "Scroll to dock",
    description: "The hero-sized window shrinks toward the product frame you already had.",
    scene: 1,
    showControls: true,
    showHDR: true,
    progress: 0.16,
    scale: 1.0,
  },
  {
    text: "HDR highlights stay alive.",
    eyebrow: "4K HDR",
    description: "Tone mapping keeps bright detail controlled across displays.",
    scene: 2,
    showControls: true,
    showHDR: true,
    progress: 0.32,
    scale: 0.98,
  },
  {
    text: "Motion and audio stay in sync.",
    eyebrow: "Frame+",
    description: "Interpolation and playback controls remain visible only when useful.",
    scene: 3,
    showControls: true,
    showHDR: true,
    progress: 0.52,
    scale: 0.96,
  },
  {
    text: "The interface belongs on macOS.",
    eyebrow: "Native feel",
    description: "The controls settle into a compact player instead of fighting the content.",
    scene: 4,
    showControls: true,
    showHDR: true,
    progress: 0.7,
    scale: 0.94,
  },
  {
    text: "Then the frame gets out of the way.",
    eyebrow: "No distractions",
    description: "The story ends with the player quiet and the page ready to continue.",
    scene: 5,
    showControls: false,
    showHDR: false,
    progress: 0.9,
    scale: 0.92,
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
      },
    });

    return () => st.kill();
  }, []);

  // Advance timer progress when playing
  useEffect(() => {
    const DURATION = 296;
    let lastTime = performance.now();

    function tick(now: number) {
      if (isPlaying) {
        const dt = (now - lastTime) / 1000;
        timerProgressRef.current = Math.min(1, timerProgressRef.current + dt / DURATION);
      }
      lastTime = now;

      const effective = Math.max(scrollProgressRef.current, timerProgressRef.current);
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

  const heroHidden = state.scene > 1 || state.progress > 0.25;
  const activeStory = Math.max(0, Math.min(STORY_LABELS.length - 1, state.scene - 1));

  return (
    <section id="hero" ref={sectionRef} className="story-section">
      <div className="story-sticky">
        <div className="story-shell">
          <div
            className="hero-copy"
            style={{
              opacity: heroHidden ? 0 : 1,
              transform: heroHidden ? "translateY(-20px)" : "translateY(0)",
              pointerEvents: heroHidden ? "none" : "auto",
            }}
          >
            <div className="hero-kicker">
              <span className="w-2 h-2 rounded-full bg-[var(--color-accent)] shadow-[0_0_12px_var(--color-accent-soft)]" />
              Frame+ AI interpolation
            </div>
            <h1 className="hero-title">Video, made native.</h1>
            <div className="w-12 h-[2px] bg-gradient-to-r from-[var(--color-accent)] to-transparent mt-4 mb-6" />
            <p className="hero-lede">
              Rift turns your Mac into a clean cinema surface: HDR playback,
              Metal rendering, FFmpeg support, and controls that shrink away as
              the picture takes over.
            </p>
            <div className="hero-actions">
              <a href="#download" className="hero-cta hero-cta--primary">
                Download for macOS
              </a>
              <a
                href="https://github.com/anomalyco/VideoPlayerUI"
                target="_blank"
                rel="noopener noreferrer"
                className="hero-cta hero-cta--secondary"
              >
                View source
              </a>
            </div>
          </div>

          <div className="min-w-0">
            <StickyPlayer
              state={state}
              isPlaying={isPlaying}
              onPlayToggle={() => setIsPlaying((v) => !v)}
              onPrev={() => {
                const p = Math.max(0, state.progress - 0.15);
                scrollProgressRef.current = p;
                timerProgressRef.current = p;
              }}
              onNext={() => {
                const p = Math.min(1, state.progress + 0.15);
                scrollProgressRef.current = p;
                timerProgressRef.current = p;
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

    </section>
  );
}
