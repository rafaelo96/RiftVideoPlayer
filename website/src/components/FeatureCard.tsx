"use client";

import type { ReactNode } from "react";

interface FeatureCardProps {
  icon: ReactNode;
  title: string;
  desc: string;
  variant?: "hero" | "grid";
}

export default function FeatureCard({ icon, title, desc, variant = "grid" }: FeatureCardProps) {
  if (variant === "hero") {
    return (
      <div
        className="ay-card ay-card--dark"
        style={{
          padding: "clamp(1.5rem, 3vw, 2.5rem)",
          display: "flex",
          flexDirection: "row",
          alignItems: "center",
          gap: "clamp(1.5rem, 4vw, 3rem)",
        }}
      >
        <div
          className="ay-icon"
          style={{
            margin: 0,
            flexShrink: 0,
            width: "2.5rem",
            height: "2.5rem",
            color: "var(--color-accent)",
          }}
        >
          {icon}
        </div>
        <div>
          <h3
            style={{
              fontFamily: "var(--font-display)",
              fontSize: "var(--text-lg)",
              fontWeight: 600,
              lineHeight: 1.15,
              marginBlockEnd: "var(--space-sm)",
              color: "var(--color-ink)",
            }}
          >
            {title}
          </h3>
          <p style={{ color: "var(--color-ink-soft)", lineHeight: 1.6, maxWidth: "42rem" }}>
            {desc}
          </p>
        </div>
      </div>
    );
  }

  return (
    <div
      className="bordered"
      style={{
        borderColor: "var(--color-rule)",
        padding: "clamp(1.5rem, 3vw, 2.5rem)",
      }}
    >
      <div className="ay-icon" style={{ margin: "0 0 var(--space-md)" }}>
        {icon}
      </div>
      <h3>{title}</h3>
      <p>{desc}</p>
    </div>
  );
}
