"use client";

import { useEffect, useState } from "react";

interface ReleaseInfo {
  version: string;
  size: string;
  updated: string;
}

export default function Download() {
  const [release, setRelease] = useState<ReleaseInfo | null>(null);

  useEffect(() => {
    fetch("https://api.github.com/repos/anomalyco/VideoPlayerUI/releases/latest")
      .then((r) => r.json())
      .then((data) => {
        if (data.tag_name) {
          const asset = data.assets?.find((a: { name: string }) => a.name.endsWith(".dmg"));
          setRelease({
            version: data.tag_name.replace(/^v/, ""),
            size: asset ? formatSize(asset.size) : "~12 MB",
            updated: new Date(data.published_at).toLocaleDateString("en-US", {
              month: "short",
              day: "numeric",
              year: "numeric",
            }),
          });
        }
      })
      .catch(() => {
        // Fallback: keep null, card shows no version detail
      });
  }, []);

  return (
    <section id="download" className="ay-section ay-section--dark">
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
            <div className="ay-label ay-label--dark">Download</div>
            <h2 className="ay-heading ay-heading--dark" style={{ marginTop: "var(--space-md)" }}>
              Download Rift.
            </h2>
          </div>
          <p className="ay-sub ay-sub--dark">
            Free, open-source, and built for macOS. Grab the release if you want
            to watch now, or open the source if you want to inspect the pipeline.
          </p>
        </div>

        <div className="ay-download-grid" style={{ borderColor: "var(--color-rule)" }}>
          <a
            href="https://github.com/anomalyco/VideoPlayerUI/releases/latest"
            target="_blank"
            rel="noopener noreferrer"
            className="ay-download-card"
          >
            <div>
              <div className="ay-download-label" style={{ color: "var(--color-dim)" }}>Recommended</div>
              <h3 style={{ color: "var(--color-ink)" }}>Rift.dmg</h3>
              <p style={{ color: "var(--color-ink-soft)" }}>
                Apple Silicon · Intel · macOS 14+
              </p>
              {release && (
                <p style={{ color: "var(--color-dim)", fontSize: "var(--text-xs)", marginTop: "var(--space-xs)", fontFamily: "var(--font-mono)" }}>
                  {release.version} · {release.size} · {release.updated}
                </p>
              )}
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
              <div className="ay-download-label" style={{ color: "var(--color-dim)" }}>Source</div>
              <h3 style={{ color: "var(--color-ink)" }}>Build from source</h3>
              <p style={{ color: "var(--color-ink-soft)", fontFamily: "var(--font-mono)" }}>swift build · MIT licensed</p>
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

function formatSize(bytes: number): string {
  const mb = bytes / (1024 * 1024);
  return mb >= 1 ? `${mb.toFixed(1)} MB` : `${(bytes / 1024).toFixed(0)} KB`;
}
