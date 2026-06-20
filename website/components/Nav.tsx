"use client";

import { Github, Menu, X } from "lucide-react";
import RiftMark from "./RiftMark";
import { useState } from "react";

const links = [
  { href: "#showcase", label: "Showcase" },
  { href: "#performance", label: "Rendimiento" },
  { href: "#features", label: "Features" },
  { href: "#tech", label: "Tecnología" }
];

export default function Nav() {
  const [open, setOpen] = useState(false);

  return (
    <header className="nav-shell">
      <nav className="nav-inner glass-panel" aria-label="Principal">
        <a href="#top" aria-label="Ir al inicio">
          <RiftMark />
        </a>
        <div className="nav-links">
          {links.map((link) => (
            <a className="nav-link" href={link.href} key={link.href}>
              {link.label}
            </a>
          ))}
        </div>
        <button
          className="nav-hamburger"
          aria-label={open ? "Cerrar menú" : "Abrir menú"}
          aria-expanded={open}
          onClick={() => setOpen(!open)}
        >
          {open ? <X size={18} /> : <Menu size={18} />}
        </button>
        <a
          className="button-secondary nav-github"
          href="https://github.com/rafaelo96/RiftVideoPlayer"
          target="_blank"
          rel="noreferrer"
        >
          <Github size={16} />
          GitHub
        </a>
      </nav>
      {open && (
        <div className="nav-mobile glass-panel">
          {links.map((link) => (
            <a
              className="nav-mobile-link"
              href={link.href}
              key={link.href}
              onClick={() => setOpen(false)}
            >
              {link.label}
            </a>
          ))}
        </div>
      )}
    </header>
  );
}
