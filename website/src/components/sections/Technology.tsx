"use client";

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
    <section id="technology" className="content-section">
      <div className="section-head">
        <h2 className="section-title">A player with a real pipeline.</h2>
        <p className="section-copy">
          The technology section is now a proper spec sheet: easier to scan,
          stable across widths, and less likely to drift out of alignment while
          the page animates around it.
        </p>
      </div>

      <div className="spec-wrap">
        <table className="spec-table">
          <thead>
            <tr>
              <th scope="col">System</th>
              <th scope="col">Value</th>
              <th scope="col">Why it matters</th>
            </tr>
          </thead>
          <tbody>
            {specs.map((spec) => (
              <tr key={spec.name}>
                <th scope="row">{spec.name}</th>
                <td className="spec-value" data-label="Value">
                  {spec.value}
                </td>
                <td data-label="Why it matters">{spec.detail}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </section>
  );
}
