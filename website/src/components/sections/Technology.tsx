"use client";

const categories = ["Render", "AI", "Display", "Display", "Format", "Platform"] as const;

const specs = [
  {
    name: "Render path",
    value: "Metal",
    detail: "GPU pipeline with hardware acceleration for high-bitrate 4K and 8K content.",
  },
  {
    name: "Frame interpolation",
    value: "RIFE",
    detail: "Neural frame generation for smoother motion when the source cadence needs help.",
  },
  {
    name: "Sync target",
    value: "120 fps",
    detail: "Display-aware playback pacing with tabular timing and stable control feedback.",
  },
  {
    name: "Tone mapping",
    value: "HDR",
    detail: "Adaptive highlights, sharpening, and Core Image filters for consistent output.",
  },
  {
    name: "Format engine",
    value: "FFmpeg",
    detail: "Broad file support for MP4, MOV, MKV, WebM, AVI, and conversion workflows.",
  },
  {
    name: "Platform",
    value: "macOS 14+",
    detail: "Built for modern macOS with a native player surface and familiar controls.",
  },
];

export default function Technology() {
  return (
    <section id="technology" className="ay-section">
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
            <div className="ay-label">Pipeline</div>
            <h2 className="ay-heading" style={{ marginTop: "var(--space-md)" }}>
              A player with a real pipeline.
            </h2>
          </div>
          <p className="ay-sub">
            Every component is chosen for performance: Metal rendering, RIFE
            neural interpolation, and HDR tone mapping that preserves the
            director&rsquo;s intent.
          </p>
        </div>

        <div className="spec-wrap">
          <table className="spec-table">
            <thead>
              <tr>
                <th scope="col">Area</th>
                <th scope="col">System</th>
                <th scope="col">Value</th>
                <th scope="col">Why it matters</th>
              </tr>
            </thead>
            <tbody>
              {specs.map((spec, i) => (
                <tr key={spec.name}>
                  <td>
                    <span className="category-chip" data-category={categories[i]}>{categories[i]}</span>
                  </td>
                  <th scope="row">{spec.name}</th>
                  <td style={{ color: "var(--color-accent)", fontFamily: "var(--font-mono)", fontWeight: 700 }}>
                    {spec.value}
                  </td>
                  <td data-label="Why it matters">{spec.detail}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </section>
  );
}
