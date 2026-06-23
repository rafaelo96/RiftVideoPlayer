"use client";

export default function Download() {
  return (
    <section id="download" className="content-section">
      <div className="section-head">
        <h2 className="section-title">Download Rift.</h2>
        <p className="section-copy">
          Free, open-source, and built for macOS. Grab the release if you want
          to watch now, or open the source if you want to inspect the pipeline.
        </p>
      </div>

      <div className="download-grid">
        <a
          href="https://github.com/anomalyco/VideoPlayerUI/releases"
          target="_blank"
          rel="noopener noreferrer"
          className="download-card"
        >
          <div>
            <div className="download-label">Recommended</div>
            <h3>Rift.dmg</h3>
            <p>Apple Silicon · Intel · macOS 14+</p>
          </div>
          <span className="download-link">Download latest release</span>
        </a>

        <a
          href="https://github.com/anomalyco/VideoPlayerUI"
          target="_blank"
          rel="noopener noreferrer"
          className="download-card"
        >
          <div>
            <div className="download-label">Source</div>
            <h3>Build from source</h3>
            <p className="font-mono">swift build · MIT licensed</p>
          </div>
          <span className="download-link">View GitHub repo</span>
        </a>
      </div>
    </section>
  );
}
