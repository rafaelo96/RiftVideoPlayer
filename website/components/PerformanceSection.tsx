"use client";

import { animate, motion, useInView, useMotionValue, useTransform } from "motion/react";
import { Cpu, Gauge, MemoryStick, Timer } from "lucide-react";
import { useEffect, useRef } from "react";
import type { ComponentType } from "react";

type Metric = {
  label: string;
  value: number;
  suffix: string;
  prefix?: string;
  decimals?: number;
  bar: number;
  icon: ComponentType<{ size?: number }>;
};

const metrics: Metric[] = [
  { label: "Inicio percibido", value: 0.8, suffix: "s", decimals: 1, bar: 92, icon: Timer },
  { label: "Reproducción fluida", value: 60, suffix: " fps", bar: 96, icon: Gauge },
  { label: "Menos memoria en idle", value: 38, suffix: "%", bar: 72, icon: MemoryStick },
  { label: "Optimizado para Apple Silicon", value: 100, suffix: "%", bar: 100, icon: Cpu }
];

function AnimatedValue({ value, suffix, prefix = "", decimals = 0 }: Omit<Metric, "label" | "bar" | "icon">) {
  const ref = useRef<HTMLElement>(null);
  const isInView = useInView(ref, { once: true, margin: "-18% 0px" });
  const motionValue = useMotionValue(0);
  const display = useTransform(motionValue, (latest) => {
    const formatted = latest.toFixed(decimals);
    return `${prefix}${formatted}${suffix}`;
  });

  useEffect(() => {
    if (!isInView) return;
    const controls = animate(motionValue, value, {
      duration: 1.25,
      ease: [0.16, 1, 0.3, 1]
    });
    return controls.stop;
  }, [decimals, isInView, motionValue, value]);

  return <motion.strong ref={ref}>{display}</motion.strong>;
}

export default function PerformanceSection() {
  return (
    <section id="performance" className="section-pad">
      <div className="performance-layout content-grid">
        <motion.div
          className="performance-copy"
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: "-18% 0px" }}
          transition={{ duration: 0.7, ease: [0.16, 1, 0.3, 1] }}
        >
          <span className="eyebrow">Performance</span>
          <h2 className="section-title">Velocidad que se siente antes de medirse.</h2>
          <p className="section-copy">
            Rift prioriza apertura rápida, controles inmediatos y una ruta de reproducción limpia para que la app
            desaparezca y el video tome el espacio.
          </p>
          <motion.div
            className="performance-visual"
            initial={{ opacity: 0, y: 22 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: "-14% 0px" }}
            transition={{ duration: 0.58, delay: 0.08, ease: [0.16, 1, 0.3, 1] }}
          >
            <div className="latency-line">
              <span />
              <span />
              <span />
              <span />
            </div>
          </motion.div>
        </motion.div>
        <div className="metric-rail">
          {metrics.map((metric, index) => {
            const Icon = metric.icon;
            return (
              <motion.article
                className="metric-card glass-panel"
                key={metric.label}
                initial={{ opacity: 0, x: 28 }}
                whileInView={{ opacity: 1, x: 0 }}
                viewport={{ once: true, margin: "-16% 0px" }}
                transition={{ duration: 0.58, delay: index * 0.08, ease: [0.16, 1, 0.3, 1] }}
              >
                <Icon size={18} />
                <AnimatedValue
                  value={metric.value}
                  suffix={metric.suffix}
                  prefix={metric.prefix}
                  decimals={metric.decimals}
                />
                <span>{metric.label}</span>
                <div className="bar-shell">
                  <motion.div
                    className="bar-fill"
                    initial={{ scaleX: 0 }}
                    whileInView={{ scaleX: metric.bar / 100 }}
                    viewport={{ once: true }}
                    transition={{ duration: 1, delay: 0.12 + index * 0.08, ease: [0.16, 1, 0.3, 1] }}
                    style={{ transformOrigin: "left center" }}
                  />
                </div>
              </motion.article>
            );
          })}
        </div>
      </div>
    </section>
  );
}
