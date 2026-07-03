"use client";

export default function Download() {
  return (
    <section id="download" className="ay-section">
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
            <div className="ay-label">Download</div>
            <h2 className="ay-heading" style={{ marginTop: "var(--space-md)" }}>
              Download Rift.
            </h2>
          </div>
          <p className="ay-sub">
            Free, open-source, and built for macOS. Grab the release if you want
            to watch now, or open the source if you want to inspect the pipeline.
          </p>
        </div>

        <div className="ay-download-grid">
          <a
            href="https://github.com/anomalyco/VideoPlayerUI/releases"
            target="_blank"
            rel="noopener noreferrer"
            className="ay-download-card"
          >
            <div>
              <div className="ay-download-label">Recommended</div>
              <h3>Rift.dmg</h3>
              <p>Apple Silicon · Intel · macOS 14+</p>
            </div>
            <span style={{ color: "var(--color-accent)", fontWeight: 700, fontSize: "var(--text-sm)" }}>
              Download latest release &rarr;
            </span>
          </a>

          <a
            href="https://github.com/anomalyco/VideoPlayerUI"
            target="_blank"
            rel="noopener noreferrer"
            className="ay-download-card"
          >
            <div>
              <div className="ay-download-label">Source</div>
              <h3>Build from source</h3>
              <p style={{ fontFamily: "var(--font-mono)" }}>swift build · MIT licensed</p>
            </div>
            <span style={{ color: "var(--color-accent)", fontWeight: 700, fontSize: "var(--text-sm)" }}>
              View GitHub repo &rarr;
            </span>
          </a>
        </div>
      </div>
    </section>
  );
}
