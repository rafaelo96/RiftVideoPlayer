"use client";

import {
  Clapperboard,
  Cpu,
  Keyboard,
  Monitor,
  PictureInPicture2,
  Zap
} from "lucide-react";
import { motion, useMotionValue, useSpring, useTransform } from "motion/react";
import type { MouseEvent, ReactNode } from "react";
import { useEffect, useState } from "react";

const features = [
  {
    title: "Reproducción ultra fluida",
    copy: "Movimiento estable, controles inmediatos y una capa visual diseñada para respetar el contenido.",
    icon: Zap,
    size: "large"
  },
  {
    title: "Interfaz nativa macOS",
    copy: "Ventanas, vidrio, sombras y ritmo visual pensados para convivir con el escritorio de Mac.",
    icon: Monitor,
    size: "wide"
  },
  {
    title: "Atajos de teclado",
    copy: "Control rápido para usuarios que viven en el teclado.",
    icon: Keyboard,
    size: "small"
  },
  {
    title: "Picture in Picture",
    copy: "La reproducción sigue contigo mientras trabajas en otras ventanas.",
    icon: PictureInPicture2,
    size: "small"
  },
  {
    title: "Múltiples formatos",
    copy: "Un reproductor flexible para bibliotecas reales, archivos grandes y audio dual.",
    icon: Clapperboard,
    size: "small"
  },
  {
    title: "Optimización moderna",
    copy: "Una base preparada para Apple Silicon, pipelines limpios y animación de interfaz a 60 fps.",
    icon: Cpu,
    size: "wide"
  }
];

function TiltCard({
  children,
  className,
  index
}: {
  children: ReactNode;
  className: string;
  index: number;
}) {
  const [isTouch, setIsTouch] = useState(false);
  const x = useMotionValue(0);
  const y = useMotionValue(0);
  const smoothX = useSpring(x, { stiffness: 160, damping: 22 });
  const smoothY = useSpring(y, { stiffness: 160, damping: 22 });
  const rotateX = useTransform(smoothY, [-0.5, 0.5], [7, -7]);
  const rotateY = useTransform(smoothX, [-0.5, 0.5], [-8, 8]);

  useEffect(() => {
    setIsTouch("ontouchstart" in window);
  }, []);

  const handleMove = (event: MouseEvent<HTMLElement>) => {
    const rect = event.currentTarget.getBoundingClientRect();
    const localX = (event.clientX - rect.left) / rect.width;
    const localY = (event.clientY - rect.top) / rect.height;
    event.currentTarget.style.setProperty("--mx", `${localX * 100}%`);
    event.currentTarget.style.setProperty("--my", `${localY * 100}%`);
    x.set(localX - 0.5);
    y.set(localY - 0.5);
  };

  return (
    <motion.article
      className={className}
      onMouseMove={handleMove}
      onMouseLeave={() => {
        x.set(0);
        y.set(0);
      }}
      initial={{ opacity: 0, y: 34 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true, margin: "-12% 0px" }}
      transition={{ duration: 0.62, delay: index * 0.055, ease: [0.16, 1, 0.3, 1] }}
      style={!isTouch ? { rotateX, rotateY } : undefined}
    >
      {children}
    </motion.article>
  );
}

export default function FeatureGrid() {
  return (
    <section id="features" className="section-pad feature-section">
      <div className="content-grid">
        <span className="eyebrow">Features</span>
        <h2 className="section-title">Herramientas pequeñas. Sensación enorme.</h2>
        <p className="section-copy">
          Rift evita la complejidad visible y deja que los detalles de interacción carguen el peso del producto.
        </p>
        <div className="feature-grid">
          {features.map((feature, index) => {
            const Icon = feature.icon;
            return (
              <TiltCard className={`feature-card glass-panel ${feature.size}`} index={index} key={feature.title}>
                <div className="feature-content">
                  <span className="feature-icon">
                    <Icon size={22} />
                  </span>
                  <div>
                    <h3>{feature.title}</h3>
                    <p>{feature.copy}</p>
                  </div>
                </div>
              </TiltCard>
            );
          })}
        </div>
      </div>
    </section>
  );
}
