"use client";

import { useEffect, useRef } from "react";

export default function Navbar() {
  const ref = useRef<HTMLElement>(null);

  useEffect(() => {
    const el = ref.current;
    if (!el) return;

    const threshold = 80;
    let floating = false;
    let ticking = false;

    const update = () => {
      const next = window.scrollY > threshold;
      if (next !== floating) {
        floating = next;
        el.classList.toggle("is-floating", floating);
      }
    };

    const onScroll = () => {
      if (ticking) return;
      ticking = true;
      requestAnimationFrame(() => {
        update();
        ticking = false;
      });
    };

    window.addEventListener("scroll", onScroll, { passive: true });
    update();

    return () => {
      window.removeEventListener("scroll", onScroll);
    };
  }, []);

  return (
    <nav ref={ref} className="site-nav" aria-label="Primary navigation">
      <div className="site-nav__inner">
        <a href="#hero" className="nav-wordmark">
          <span className="nav-mark" aria-hidden="true">
            <svg width="15" height="15" viewBox="0 0 24 24" fill="currentColor">
              <polygon points="8 5 19 12 8 19 8 5" />
            </svg>
          </span>
          <span className="font-display text-[0.98rem] font-[800] tracking-[-0.04em]">
            Rift
          </span>
        </a>

        <div className="nav-links">
          {[
            ["Features", "#features"],
            ["Technology", "#technology"],
            ["Download", "#download"],
          ].map(([item, href]) => (
            <a key={item} href={href} className="nav-link">
              {item}
            </a>
          ))}
        </div>

        <a href="#download" className="nav-cta">
          Download
        </a>
      </div>
    </nav>
  );
}
