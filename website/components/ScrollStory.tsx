"use client";

import { motion } from "motion/react";
import { useState } from "react";
import VideoPlayerDemo, { type ProductHighlight } from "../app/components/VideoPlayerDemo";

const steps: Array<{
  title: string;
  copy: string;
  highlight: ProductHighlight;
  mode: string;
  progress: number;
}> = [
  {
    title: "Diseñado para macOS.",
    copy: "La ventana, los controles y la jerarquía visual hablan el mismo idioma que tu Mac.",
    highlight: "frame",
    mode: "Native",
    progress: 26
  },
  {
    title: "La interfaz aparece cuando importa.",
    copy: "Controles compactos, legibles y tranquilos, pensados para no competir con la película.",
    highlight: "controls",
    mode: "Focus",
    progress: 43
  },
  {
    title: "Frame+ aporta fluidez sin sentirse artificial.",
    copy: "La mejora se presenta como una capa precisa, controlada y reversible.",
    highlight: "performance",
    mode: "Frame+",
    progress: 62
  },
  {
    title: "Visual cuida el detalle en escenas oscuras.",
    copy: "La imagen respira mejor sin romper la intención cinematográfica del contenido.",
    highlight: "visual",
    mode: "Visual",
    progress: 78
  }
];

export default function ScrollStory() {
  const [active, setActive] = useState(0);

  return (
    <section className="story-section section-pad" aria-label="Historia de Rift">
      <div className="story-sticky content-grid">
        <div className="story-copy-stack">
          {steps.map((step, index) => (
            <motion.button
              type="button"
              className={`story-step ${active === index ? "active" : ""}`}
              key={step.title}
              onClick={() => setActive(index)}
              onFocus={() => setActive(index)}
              onPointerEnter={() => setActive(index)}
              initial={{ opacity: 0, y: 18 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true, margin: "-12% 0px" }}
              transition={{ duration: 0.44, delay: index * 0.06, ease: [0.16, 1, 0.3, 1] }}
            >
              <span className="story-index">{String(index + 1).padStart(2, "0")}</span>
              <h2>{step.title}</h2>
              <p>{step.copy}</p>
            </motion.button>
          ))}
        </div>
        <motion.div className="story-product" initial={{ opacity: 0, y: 24 }} whileInView={{ opacity: 1, y: 0 }} viewport={{ once: true, margin: "-18% 0px" }} transition={{ duration: 0.58, ease: [0.16, 1, 0.3, 1] }}>
          <VideoPlayerDemo
            highlight={steps[active].highlight}
            modeLabel={steps[active].mode}
            progress={steps[active].progress}
            visualTone={active === 3 ? "deep" : "cinema"}
          />
        </motion.div>
      </div>
    </section>
  );
}
