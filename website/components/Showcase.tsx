"use client";

import { motion } from "motion/react";
import VideoPlayerDemo from "../app/components/VideoPlayerDemo";

export default function Showcase() {
  return (
    <section id="showcase" className="showcase-section section-pad">
      <div className="showcase-sticky">
        <motion.div
          className="showcase-heading"
          initial={{ opacity: 0, y: 22 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: "-16% 0px" }}
          transition={{ duration: 0.58, ease: [0.16, 1, 0.3, 1] }}
        >
          <span className="eyebrow">Showcase</span>
          <h2 className="section-title">Una ventana que se mueve como producto real.</h2>
          <p className="section-copy">
            El mockup no es decoración. La profundidad está en las capas, no en obligarte a perseguir la animación.
          </p>
        </motion.div>
        <motion.div
          className="showcase-product"
          initial={{ opacity: 0, y: 32, scale: 0.98 }}
          whileInView={{ opacity: 1, y: 0, scale: 1 }}
          viewport={{ once: true, margin: "-14% 0px" }}
          transition={{ duration: 0.72, ease: [0.16, 1, 0.3, 1] }}
        >
          <div className="showcase-glow" />
          <VideoPlayerDemo highlight="controls" modeLabel="Visual" progress={71} visualTone="bright" />
        </motion.div>
      </div>
    </section>
  );
}
