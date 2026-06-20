"use client";

import { motion } from "motion/react";
import { CircleDot, Cpu, Layers3, RadioTower, SquareCode } from "lucide-react";
import RiftMark from "./RiftMark";

const chips = [
  { label: "Swift", icon: SquareCode, x: -290, y: -76, delay: 0 },
  { label: "SwiftUI", icon: Layers3, x: 222, y: -136, delay: 0.2 },
  { label: "AVFoundation", icon: RadioTower, x: 270, y: 112, delay: 0.4 },
  { label: "Metal", icon: CircleDot, x: -214, y: 152, delay: 0.1 },
  { label: "Apple Silicon", icon: Cpu, x: 0, y: -245, delay: 0.3 }
];

export default function TechnologyOrbit() {
  return (
    <section id="tech" className="section-pad">
      <div className="content-grid tech-copy">
        <span className="eyebrow">Tecnologías</span>
        <h2 className="section-title">Una base técnica que los reclutadores pueden leer de inmediato.</h2>
        <p className="section-copy">
          La web muestra producto y también criterio frontend: Motion, TypeScript, responsividad y performance visual.
        </p>
      </div>
      <motion.div
        className="tech-orbit"
        initial={{ opacity: 0, y: 24 }}
        whileInView={{ opacity: 1, y: 0 }}
        viewport={{ once: true, margin: "-14% 0px" }}
        transition={{ duration: 0.62, ease: [0.16, 1, 0.3, 1] }}
      >
        <div className="orbit-ring one" />
        <div className="orbit-ring two" />
        <div className="orbit-ring three" />
        <motion.div
          className="tech-core glass-panel"
          animate={{ y: [0, -12, 0] }}
          transition={{ duration: 6, repeat: Infinity, ease: "easeInOut" }}
        >
          <RiftMark compact />
          <strong>Rift Engine</strong>
        </motion.div>
        {chips.map((chip) => {
          const Icon = chip.icon;
          return (
            <motion.div
              className="tech-chip"
              key={chip.label}
              style={{ left: "50%", top: "50%", marginLeft: chip.x, marginTop: chip.y }}
              animate={{ y: [0, -10, 0], rotate: [0, 1.8, 0] }}
              transition={{ duration: 5.2, delay: chip.delay, repeat: Infinity, ease: "easeInOut" }}
            >
              <Icon size={15} />
              {chip.label}
            </motion.div>
          );
        })}
      </motion.div>
    </section>
  );
}
