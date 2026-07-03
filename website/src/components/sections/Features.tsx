"use client";

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
        <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2" />
      </svg>
    ),
    title: "HDR & Visual Enhancements",
    desc: "Adaptive tone-mapping, highlight control, sharpening. Core Image filters make HDR content look stunning on any display.",
  },
  {
    icon: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
        <circle cx="12" cy="12" r="10" />
        <polyline points="12 6 12 12 16 14" />
      </svg>
    ),
    title: "Movable Controls",
    desc: "Drag the control bar anywhere in the window. Double-tap resets to center. Auto-hides when you're immersed.",
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
  return (
    <section id="features" className="ay-section ay-section--dark">
      <div className="ay-inner">
        <div
          style={{
            display: "grid",
            gridTemplateColumns: "1fr 1fr",
            gap: "clamp(1.5rem, 5vw, 4rem)",
            alignItems: "end",
            marginBlockEnd: "clamp(2rem, 5vw, 4rem)",
          }}
        >
          <div>
            <div className="ay-label ay-label--dark">Features</div>
            <h2 className="ay-heading ay-heading--dark" style={{ marginTop: "var(--space-md)" }}>
              Built for cinematic playback.
            </h2>
          </div>
          <p className="ay-sub ay-sub--dark">
            Every detail of Rift is engineered for immersive, frame-perfect video
            playback on macOS: the render path, the control surface, and the way
            the interface disappears when the picture needs the room.
          </p>
        </div>

        <div className="ay-grid-3">
          {features.map((f, i) => (
            <div key={f.title} className="ay-card ay-card--dark">
              <div>
                <div style={{ display: "flex", alignItems: "flex-start", justifyContent: "space-between", marginBlockEnd: "var(--space-lg)" }}>
                  <div className="ay-icon" style={{ margin: 0 }}>
                    {f.icon}
                  </div>
                  <span className="ay-index ay-index--dark">{String(i + 1).padStart(2, "0")}</span>
                </div>
                <h3>{f.title}</h3>
                <p>{f.desc}</p>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
