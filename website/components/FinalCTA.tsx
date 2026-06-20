"use client";

import { motion } from "motion/react";
import { ArrowDownToLine, Github } from "lucide-react";
import RiftMark from "./RiftMark";

export default function FinalCTA() {
  return (
    <section id="final" className="final-section section-pad">
      <motion.div
        className="final-card"
        initial={{ opacity: 0, y: 46, scale: 0.96 }}
        whileInView={{ opacity: 1, y: 0, scale: 1 }}
        viewport={{ once: true, margin: "-18% 0px" }}
        transition={{ duration: 0.82, ease: [0.16, 1, 0.3, 1] }}
      >
        <motion.div
          className="final-icon"
          animate={{ y: [0, -12, 0], rotate: [0, -2, 0] }}
          transition={{ duration: 6.2, repeat: Infinity, ease: "easeInOut" }}
        >
          <RiftMark compact />
        </motion.div>
        <span className="eyebrow">Rift para macOS</span>
        <h2 className="section-title">Redescubre cómo debería sentirse un reproductor de video.</h2>
        <p className="section-copy">
          Una app veloz, elegante y construida con el nivel de detalle que esperas de una herramienta nativa para Mac.
        </p>
        <div className="final-actions">
          <a className="button-primary" href="/Rift.dmg">
            <ArrowDownToLine size={17} />
            Descargar para macOS
          </a>
          <a className="button-secondary" href="https://github.com/rafaelo96/RiftVideoPlayer" target="_blank" rel="noreferrer">
            <Github size={17} />
            Ver en GitHub
          </a>
        </div>
      </motion.div>
    </section>
  );
}
