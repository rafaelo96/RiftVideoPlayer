"use client";

import { motion, useMotionValue, useSpring, useTransform } from "motion/react";
import { ArrowDownToLine, Github, Sparkles } from "lucide-react";
import { useEffect, useState } from "react";
import VideoPlayerDemo from "../app/components/VideoPlayerDemo";
import RiftMark from "./RiftMark";

export default function Hero() {
  const [isTouch, setIsTouch] = useState(false);
  const pointerX = useMotionValue(0);
  const pointerY = useMotionValue(0);
  const smoothX = useSpring(pointerX, { stiffness: 110, damping: 28, mass: 0.5 });
  const smoothY = useSpring(pointerY, { stiffness: 110, damping: 28, mass: 0.5 });
  const rotateX = useTransform(smoothY, [-1, 1], [3, -3]);
  const rotateY = useTransform(smoothX, [-1, 1], [-4, 4]);

  useEffect(() => {
    setIsTouch("ontouchstart" in window);
  }, []);

  return (
    <section
      id="top"
      className="hero-section"
      onPointerMove={(event) => {
        const rect = event.currentTarget.getBoundingClientRect();
        pointerX.set(((event.clientX - rect.left) / rect.width - 0.5) * 2);
        pointerY.set(((event.clientY - rect.top) / rect.height - 0.5) * 2);
      }}
      onPointerLeave={() => {
        pointerX.set(0);
        pointerY.set(0);
      }}
    >
      <div className="hero-sticky">
        <div className="hero-stage">
          <motion.div className="hero-copy">
            <motion.div
              className="hero-badge glass-panel"
              initial={{ opacity: 0, y: 18, scale: 0.96 }}
              animate={{ opacity: 1, y: 0, scale: 1 }}
              transition={{ duration: 0.8, ease: [0.16, 1, 0.3, 1] }}
            >
              <RiftMark compact />
              <span>macOS video player</span>
            </motion.div>
            <motion.h1
              className="display-title"
              initial={{ opacity: 0, y: 28, filter: "blur(12px)" }}
              animate={{ opacity: 1, y: 0, filter: "blur(0px)" }}
              transition={{ duration: 1, delay: 0.08, ease: [0.16, 1, 0.3, 1] }}
            >
              Rift
            </motion.h1>
            <motion.p
              className="section-copy"
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.82, delay: 0.18, ease: [0.16, 1, 0.3, 1] }}
            >
              Un reproductor de video para Mac diseñado alrededor de velocidad, calma visual y una interfaz que se
              siente nativa desde el primer frame.
            </motion.p>
            <motion.div
              className="hero-actions"
              initial={{ opacity: 0, y: 18 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.72, delay: 0.28, ease: [0.16, 1, 0.3, 1] }}
            >
              <a className="button-primary" href="#final">
                <ArrowDownToLine size={17} />
                Descargar para macOS
              </a>
              <a className="button-secondary" href="https://github.com/rafaelo96/RiftVideoPlayer" target="_blank" rel="noreferrer">
                <Github size={17} />
                Ver en GitHub
              </a>
            </motion.div>
            <motion.p
              className="hero-note"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ duration: 0.7, delay: 0.44 }}
            >
              SwiftUI, AVFoundation, Metal y una obsesión sana por cada milisegundo.
            </motion.p>
          </motion.div>

          <motion.div
            className="hero-product"
            initial={{ opacity: 0, y: 32, scale: 0.96 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            transition={{ duration: 0.9, delay: 0.22, ease: [0.16, 1, 0.3, 1] }}
            style={!isTouch ? { rotateX, rotateY } : undefined}
          >
            <div className="hero-product-glow" />
            <VideoPlayerDemo highlight="frame" modeLabel="Frame+" progress={62} visualTone="cinema" />
            <motion.div
              className="hero-floating-tag glass-panel"
              initial={{ opacity: 0, y: 18, x: -30 }}
              animate={{ opacity: 1, y: [0, -8, 0], x: 0 }}
              transition={{
                opacity: { duration: 0.7, delay: 0.6 },
                x: { duration: 0.7, delay: 0.6 },
                y: { duration: 5.4, repeat: Infinity, ease: "easeInOut" }
              }}
            >
              <Sparkles size={15} />
              60 fps visuales
            </motion.div>
          </motion.div>
        </div>
      </div>
    </section>
  );
}
