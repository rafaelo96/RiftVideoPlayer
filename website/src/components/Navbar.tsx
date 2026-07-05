"use client";

import { useRef, useState, useEffect } from "react";
import { useLenis } from "lenis/react";

const links = [
  ["Features", "#features"],
  ["Technology", "#technology"],
  ["Download", "#download"],
] as const;

const sectionIds = ["features", "technology", "download"];

export default function Navbar() {
  const ref = useRef<HTMLElement>(null);
  const [mobileOpen, setMobileOpen] = useState(false);
  const [activeSection, setActiveSection] = useState("");

  useLenis((lenis) => {
    const el = ref.current;
    if (!el) return;
    el.classList.toggle("is-floating", lenis.scroll <= 80);
  });

  useEffect(() => {
    if (mobileOpen) {
      document.body.style.overflow = "hidden";
    } else {
      document.body.style.overflow = "";
    }
    return () => { document.body.style.overflow = ""; };
  }, [mobileOpen]);

  useEffect(() => {
    const observer = new IntersectionObserver(
      (entries) => {
        for (const entry of entries) {
          if (entry.isIntersecting) {
            setActiveSection(entry.target.id);
          }
        }
      },
      { rootMargin: "-40% 0px -55% 0px" }
    );

    for (const id of sectionIds) {
      const el = document.getElementById(id);
      if (el) observer.observe(el);
    }

    return () => observer.disconnect();
  }, []);

  return (
    <nav ref={ref} className="site-nav is-floating" aria-label="Primary navigation">
      <div className="site-nav__inner">
        <a href="#hero" className="nav-wordmark" onClick={() => setMobileOpen(false)} aria-label="Go to top">
          <span className="nav-mark" aria-hidden="true">
            <svg width="15" height="15" viewBox="0 0 24 24" fill="currentColor">
              <polygon points="8 5 19 12 8 19 8 5" />
            </svg>
          </span>
          <span className="font-display text-[0.98rem] font-[700] tracking-[-0.04em]">
            Rift
          </span>
        </a>

        <div className={`nav-links ${mobileOpen ? "nav-links--open" : ""}`}>
          {links.map(([item, href]) => {
            const sectionId = href.replace("#", "");
            return (
              <a
                key={item}
                href={href}
                className="nav-link"
                onClick={() => setMobileOpen(false)}
                aria-current={activeSection === sectionId ? "location" : undefined}
              >
                {item}
              </a>
            );
          })}
        </div>

        {mobileOpen && (
          <div
            className="nav-overlay"
            onClick={() => setMobileOpen(false)}
            aria-hidden="true"
          />
        )}

        <button
          type="button"
          className="nav-hamburger"
          aria-label={mobileOpen ? "Close navigation menu" : "Open navigation menu"}
          aria-expanded={mobileOpen}
          onClick={() => setMobileOpen((v) => !v)}
        >
          <span className={`nav-hamburger__line ${mobileOpen ? "nav-hamburger__line--open" : ""}`} />
          <span className={`nav-hamburger__line ${mobileOpen ? "nav-hamburger__line--open" : ""}`} />
          <span className={`nav-hamburger__line ${mobileOpen ? "nav-hamburger__line--open" : ""}`} />
        </button>

        <a href="#download" className="nav-cta" onClick={() => setMobileOpen(false)}>
          Download
        </a>
      </div>
    </nav>
  );
}
