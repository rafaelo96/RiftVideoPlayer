"use client";

import { useEffect, useRef } from "react";
import Navbar from "@/components/Navbar";
import ScrollStory from "@/components/ScrollStory";
import Features from "@/components/sections/Features";
import Technology from "@/components/sections/Technology";
import Download from "@/components/sections/Download";
import ErrorBoundary from "@/components/ErrorBoundary";
import { GITHUB_URL, GITHUB_RELEASES_URL, LICENSE_URL } from "@/lib/config";

export default function Home() {
  const mountedRef = useRef(true);

  useEffect(() => {
    mountedRef.current = true;
    if (window.location.hash) {
      const id = window.location.hash.replace("#", "");
      const timeout = setTimeout(() => {
        if (!mountedRef.current) return;
        const el = document.getElementById(id) || document.querySelector(`[data-anchor="${id}"]`);
        if (el) el.scrollIntoView({ behavior: "smooth" });
      }, 1500);
      return () => {
        mountedRef.current = false;
        clearTimeout(timeout);
      };
    }
  }, []);

  return (
    <ErrorBoundary>
      <main className="relative min-h-screen overflow-x-clip">
        <a
          href="#main-content"
          className="sr-only focus:not-sr-only focus:fixed focus:top-4 focus:left-4 focus:z-[9999] focus:px-4 focus:py-2 focus:bg-[var(--color-accent)] focus:text-[var(--color-accent-ink)] focus:rounded-lg focus:font-semibold"
        >
          Skip to content
        </a>

        <Navbar />
        <div id="main-content" />
        <ScrollStory />

        <Features />
        <div className="mx-auto w-[2px] h-16 bg-gradient-to-b from-transparent via-[var(--color-rule)] to-transparent" />
        <Technology />
        <div className="mx-auto w-[2px] h-16 bg-gradient-to-b from-transparent via-[var(--color-rule)] to-transparent" />
        <Download />

        <footer className="site-footer">
          <p>Rift · SwiftUI · Metal Performance Shaders · FFmpeg</p>
          <div className="site-footer__links">
            <a
              href={GITHUB_URL}
              target="_blank"
              rel="noopener noreferrer"
              className="foot-link"
              aria-label="GitHub"
            >
              <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor">
                <path d="M12 0C5.37 0 0 5.37 0 12c0 5.31 3.435 9.795 8.205 11.385.6.105.825-.255.825-.57 0-.285-.015-1.23-.015-2.235-3.015.555-3.795-.735-4.035-1.41-.135-.345-.72-1.41-1.23-1.695-.42-.225-1.02-.78-.015-.795.945-.015 1.62.87 1.845 1.23 1.08 1.815 2.805 1.305 3.495.99.105-.78.42-1.305.765-1.605-2.67-.3-5.46-1.335-5.46-5.925 0-1.305.465-2.385 1.23-3.225-.12-.3-.54-1.53.12-3.18 0 0 1.005-.315 3.3 1.23.96-.27 1.98-.405 3-.405s2.04.135 3 .405c2.295-1.56 3.3-1.23 3.3-1.23.66 1.65.24 2.88.12 3.18.765.84 1.23 1.905 1.23 3.225 0 4.605-2.805 5.625-5.475 5.925.435.375.81 1.095.81 2.22 0 1.605-.015 2.895-.015 3.3 0 .315.225.69.825.57A12.02 12.02 0 0024 12c0-6.63-5.37-12-12-12z" />
              </svg>
            </a>
            <a href={GITHUB_RELEASES_URL} target="_blank" rel="noopener noreferrer" className="foot-link">Releases</a>
            <a href={LICENSE_URL} target="_blank" rel="noopener noreferrer" className="foot-link">MIT License</a>
          </div>
        </footer>
      </main>
    </ErrorBoundary>
  );
}