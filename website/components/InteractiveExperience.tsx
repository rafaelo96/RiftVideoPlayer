"use client";

import { motion } from "motion/react";
import { Check, SlidersHorizontal } from "lucide-react";
import { useState } from "react";
import VideoPlayerDemo, { type ProductHighlight } from "../app/components/VideoPlayerDemo";

type Mode = {
  name: string;
  copy: string;
  highlight: ProductHighlight;
  tone: "cinema" | "bright" | "deep" | "studio";
  progress: number;
};

const modes: Mode[] = [
  {
    name: "Cine",
    copy: "Interfaz silenciosa, contraste suave y foco total en la reproducción.",
    highlight: "controls",
    tone: "cinema",
    progress: 34
  },
  {
    name: "Frame+",
    copy: "La capa de fluidez aparece como una mejora precisa, visible y controlable.",
    highlight: "performance",
    tone: "bright",
    progress: 52
  },
  {
    name: "Visual",
    copy: "Escenas oscuras con más lectura, sin lavar negros ni romper el color.",
    highlight: "visual",
    tone: "deep",
    progress: 68
  },
  {
    name: "Subtítulos",
    copy: "Pistas claras y accesibles, listas para audio dual y bibliotecas grandes.",
    highlight: "subtitles",
    tone: "studio",
    progress: 84
  }
];

export default function InteractiveExperience() {
  const [active, setActive] = useState(0);
  const selected = modes[active];

  return (
    <section className="interactive-section section-pad">
      <div className="interactive-sticky content-grid">
        <motion.div
          initial={{ opacity: 0, y: 22 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: "-14% 0px" }}
          transition={{ duration: 0.56, ease: [0.16, 1, 0.3, 1] }}
        >
          <span className="eyebrow">Live interface</span>
          <h2 className="section-title">La app cambia contigo.</h2>
          <p className="section-copy">
            Los modos se sienten como controles reales: eliges uno y la interfaz responde sin secuestrar el scroll.
          </p>
          <div className="mode-list">
            {modes.map((mode, index) => (
              <motion.button
                type="button"
                className={`mode-item ${active === index ? "active" : ""}`}
                key={mode.name}
                onClick={() => setActive(index)}
                onFocus={() => setActive(index)}
                onPointerEnter={() => setActive(index)}
                animate={{ x: active === index ? 8 : 0 }}
                transition={{ duration: 0.28, ease: [0.16, 1, 0.3, 1] }}
              >
                <span>{mode.name}</span>
                {active === index ? <Check size={16} /> : <SlidersHorizontal size={16} />}
              </motion.button>
            ))}
          </div>
        </motion.div>
        <motion.div
          className="interactive-preview"
          initial={{ opacity: 0, y: 28 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: "-14% 0px" }}
          transition={{ duration: 0.62, delay: 0.05, ease: [0.16, 1, 0.3, 1] }}
        >
          <VideoPlayerDemo
            highlight={selected.highlight}
            modeLabel={selected.name}
            progress={selected.progress}
            visualTone={selected.tone}
          />
          <motion.div
            className="interactive-caption glass-panel"
            key={selected.name}
            initial={{ opacity: 0, y: 16, filter: "blur(8px)" }}
            animate={{ opacity: 1, y: 0, filter: "blur(0px)" }}
            transition={{ duration: 0.44, ease: [0.16, 1, 0.3, 1] }}
          >
            <strong>{selected.name}</strong>
            <span>{selected.copy}</span>
          </motion.div>
        </motion.div>
      </div>
    </section>
  );
}
