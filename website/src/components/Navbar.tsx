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
            <svg viewBox="140 220 730 650" fill="none" xmlns="http://www.w3.org/2000/svg">
              <defs>
                <linearGradient id="navPlay" x1="420" y1="310" x2="640" y2="580" gradientUnits="userSpaceOnUse">
                  <stop offset="0%" stop-color="#6A9DFF"/>
                  <stop offset="100%" stop-color="#4A4DFF"/>
                </linearGradient>
              </defs>
              <path d="M320 240H704C784 240 848 304 848 384V520C848 575 825 627 784 664L640 790C602 823 554 842 504 842H320C240 842 176 778 176 698V384C176 304 240 240 320 240Z" fill="white"/>
              <path d="M512 842C560 842 606 824 640 790L784 664C818 633 838 596 848 548C822 602 777 645 708 650H676C628 650 587 676 564 718L541 759C527 786 515 816 512 842Z" fill="#D8DBF3"/>
              <path d="M432 360C432 333 461 317 484 332L633 429C654 443 654 473 633 487L484 584C461 599 432 583 432 556Z" fill="url(#navPlay)"/>
              <rect x="260" y="650" width="320" height="22" rx="11" fill="#D9DCF2"/>
              <rect x="260" y="650" width="130" height="22" rx="11" fill="url(#navPlay)"/>
              <circle cx="370" cy="661" r="32" fill="url(#navPlay)"/>
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

        <a
          href="https://github.com/anomalyco/VideoPlayerUI/releases/latest"
          target="_blank"
          rel="noopener noreferrer"
          className="nav-cta"
          onClick={() => setMobileOpen(false)}
        >
          Download
        </a>
      </div>
    </nav>
  );
}
