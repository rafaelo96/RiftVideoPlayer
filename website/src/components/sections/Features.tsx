"use client";

import { useRef, useEffect } from "react";
import gsap from "gsap";

const features = [
  {
    icon: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
        <rect x="2" y="3" width="20" height="14" rx="2" ry="2" />
        <line x1="8" y1="21" x2="16" y2="21" />
        <line x1="12" y1="17" x2="12" y2="21" />
      </svg>
    ),
    title: "Liquid Glass UI",
    desc: "Adaptive transparency with native macOS blur. Controls float over your content with spring animations that feel like part of the system.",
  },
  {
    icon: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
        <path d="M22 12h-4l-3 9L9 3l-3 9H2" />
      </svg>
    ),
    title: "Frame+ AI Interpolation",
    desc: "Real-time motion interpolation via RIFE neural network. GPU-accelerated on Metal. 24 fps to 120 fps without artifacts.",
  },
  {
    icon: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
        <rect x="1" y="3" width="15" height="13" />
        <polygon points="16 8 20 8 23 11 23 16 16 16 16 8" />
        <circle cx="5.5" cy="18.5" r="2.5" />
        <circle cx="18.5" cy="18.5" r="2.5" />
      </svg>
    ),
    title: "Universal Format Support",
    desc: "Open MP4, MOV, MKV, WebM, AVI, and more. FFmpeg-powered conversion handles anything your library throws at it.",
  },
  {
    icon: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
        <rect x="2" y="3" width="20" height="14" rx="2" ry="2" />
        <line x1="8" y1="21" x2="16" y2="21" />
        <line x1="12" y1="17" x2="12" y2="21" />
      </svg>
    ),
    title: "Movable Controls",
    desc: "Drag the control bar anywhere in the window. Double-tap resets to center. Auto-hides when you're immersed.",
  },
  {
    icon: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
        <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" />
        <circle cx="12" cy="12" r="3" />
      </svg>
    ),
    title: "HDR & Visual Enhancements",
    desc: "Adaptive tone-mapping, highlight control, sharpening. Core Image filters make HDR content look stunning on any display.",
  },
  {
    icon: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
        <polygon points="23 7 16 12 23 17 23 7" />
        <rect x="1" y="5" width="15" height="14" rx="2" ry="2" />
      </svg>
    ),
    title: "Native Metal Pipeline",
    desc: "Pure Metal rendering with hardware acceleration. Plays 4K, 8K, and high-bitrate content with zero-copy efficiency.",
  },
];

export default function Features() {
  const ref = useRef<HTMLElement>(null);
  const cardsRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const cards = cardsRef.current?.querySelectorAll(".feature-card");
    if (!cards) return;

    cards.forEach((card, i) => {
      gsap.fromTo(
        card,
        { opacity: 0, y: 30 },
        {
          opacity: 1,
          y: 0,
          duration: 0.6,
          delay: i * 0.08,
          ease: "power3.out",
          scrollTrigger: {
            trigger: card as HTMLElement,
            start: "top 85%",
            toggleActions: "play none none none",
          },
        }
      );
    });
  }, []);

  return (
      <section
      id="features"
      ref={ref}
      className="content-section"
    >
      <div className="section-head">
        <h2 className="section-title">
          Built for cinematic playback.
        </h2>
        <p className="section-copy">
          Every detail of Rift is engineered for immersive, frame-perfect video
          playback on macOS: the render path, the control surface, and the way
          the interface disappears when the picture needs the room.
        </p>
      </div>

      <div
        ref={cardsRef}
        className="feature-grid"
      >
        {features.map((f, i) => (
          <div
            key={i}
            className={`feature-card ${i < 2 ? "feature-card--wide" : ""}`}
          >
            <div className="feature-card__top">
              <div className="feature-icon" aria-hidden="true">
                {f.icon}
              </div>
              <span className="feature-index">{String(i + 1).padStart(2, "0")}</span>
            </div>
            <div>
              <h3>{f.title}</h3>
              <p>{f.desc}</p>
            </div>
          </div>
        ))}
      </div>
    </section>
  );
}
