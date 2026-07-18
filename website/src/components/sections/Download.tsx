"use client";

import { useEffect, useState } from "react";
import { GITHUB_URL, GITHUB_LATEST_URL, GITHUB_API_LATEST } from "@/lib/config";

interface ReleaseInfo {
  version: string;
  size: string;
  updated: string;
}

export default function Download() {
  const [release, setRelease] = useState<ReleaseInfo | null>(null);
  const [copied, setCopied] = useState(false);

  useEffect(() => {
    fetch(GITHUB_API_LATEST)
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
      .catch(() => {});
  }, []);

  const copyBrew = async () => {
    try {
      await navigator.clipboard.writeText("brew install rafaelo96/rift/rift");
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    } catch {}
  };

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
            to watch now, or install with Homebrew for automatic updates.
          </p>
        </div>

        <div className="ay-download-grid" style={{ borderColor: "var(--color-rule)" }}>
          <a
            href={GITHUB_LATEST_URL}
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
            href={GITHUB_URL}
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

        <div className="ay-download-extras">
          <div className="ay-download-card">
            <div>
              <div className="ay-download-label">Homebrew</div>
              <h3>Install with a single command</h3>
              <div className="ay-code-block" onClick={copyBrew}>
                <span>$ brew install rafaelo96/rift/rift</span>
                <span className="ay-code-block__action" style={{ color: copied ? "var(--color-accent)" : undefined }}>
                  {copied ? "Copied!" : "Copy"}
                </span>
              </div>
              <p>Auto-updates via Homebrew. No configuration needed.</p>
            </div>
          </div>

          <div className="ay-download-card">
            <div>
              <div className="ay-download-label">Gatekeeper? No problem.</div>
              <h3>macOS might block Rift</h3>
              <p>
                If macOS says{" "}
                <span style={{ fontStyle: "italic" }}>
                  &ldquo;Rift is damaged&rdquo;
                </span>{" "}
                after downloading the DMG, run this in Terminal:
              </p>
              <div className="ay-code-block">
                <span>$ xattr -cr /Applications/Rift.app</span>
              </div>
              <p>Or use Homebrew above &mdash; it handles this automatically.</p>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}

function formatSize(bytes: number): string {
  const mb = bytes / (1024 * 1024);
  return mb >= 1 ? `${mb.toFixed(1)} MB` : `${(bytes / 1024).toFixed(0)} KB`;
}
