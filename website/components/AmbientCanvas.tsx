"use client";

import { useEffect, useRef } from "react";

type Particle = {
  x: number;
  y: number;
  vx: number;
  vy: number;
  depth: number;
};

export default function AmbientCanvas() {
  const canvasRef = useRef<HTMLCanvasElement>(null);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return undefined;

    const context = canvas.getContext("2d", { alpha: true });
    if (!context) return undefined;

    const reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)");
    const pointer = { x: 0.5, y: 0.5 };
    const particles: Particle[] = [];
    let width = 0;
    let height = 0;
    let frame = 0;
    let idleTimer: ReturnType<typeof setTimeout> | null = null;
    let isPaused = false;

    const resize = () => {
      const ratio = Math.min(window.devicePixelRatio || 1, 2);
      width = window.innerWidth;
      height = window.innerHeight;
      canvas.width = Math.floor(width * ratio);
      canvas.height = Math.floor(height * ratio);
      canvas.style.width = `${width}px`;
      canvas.style.height = `${height}px`;
      context.setTransform(ratio, 0, 0, ratio, 0, 0);

      particles.length = 0;
      const count = Math.min(92, Math.max(46, Math.round(width / 20)));
      for (let index = 0; index < count; index += 1) {
        particles.push({
          x: Math.random() * width,
          y: Math.random() * height,
          vx: (Math.random() - 0.5) * 0.16,
          vy: (Math.random() - 0.5) * 0.12,
          depth: 0.35 + Math.random() * 0.85
        });
      }
    };

    const startAnimation = () => {
      if (isPaused) {
        isPaused = false;
        frame = requestAnimationFrame(draw);
      }
    };

    const pauseAnimation = () => {
      isPaused = true;
      cancelAnimationFrame(frame);
    };

    const resetIdleTimer = () => {
      if (idleTimer) clearTimeout(idleTimer);
      startAnimation();
      idleTimer = setTimeout(pauseAnimation, 5000);
    };

    const handlePointer = (event: PointerEvent) => {
      pointer.x = event.clientX / width;
      pointer.y = event.clientY / height;
      resetIdleTimer();
    };

    const draw = () => {
      context.clearRect(0, 0, width, height);

      const centerX = width * (0.48 + (pointer.x - 0.5) * 0.035);
      const centerY = height * (0.34 + (pointer.y - 0.5) * 0.035);
      const gradient = context.createRadialGradient(
        centerX,
        centerY,
        40,
        centerX,
        centerY,
        Math.max(width, height) * 0.72
      );
      gradient.addColorStop(0, "rgba(57, 124, 255, 0.11)");
      gradient.addColorStop(0.42, "rgba(35, 211, 206, 0.045)");
      gradient.addColorStop(1, "rgba(0, 0, 0, 0)");
      context.fillStyle = gradient;
      context.fillRect(0, 0, width, height);

      context.lineWidth = 1;
      for (let index = 0; index < particles.length; index += 1) {
        const particle = particles[index];
        const driftX = (pointer.x - 0.5) * particle.depth * 0.18;
        const driftY = (pointer.y - 0.5) * particle.depth * 0.14;
        particle.x += particle.vx + driftX;
        particle.y += particle.vy + driftY;

        if (particle.x < -40) particle.x = width + 40;
        if (particle.x > width + 40) particle.x = -40;
        if (particle.y < -40) particle.y = height + 40;
        if (particle.y > height + 40) particle.y = -40;

        const alpha = 0.06 * particle.depth;
        context.beginPath();
        context.arc(particle.x, particle.y, 1.1 * particle.depth, 0, Math.PI * 2);
        context.fillStyle = `rgba(215, 231, 255, ${alpha})`;
        context.fill();

        const neighbor = particles[(index + 7) % particles.length];
        const distance = Math.hypot(particle.x - neighbor.x, particle.y - neighbor.y);
        if (distance < 180) {
          context.beginPath();
          context.moveTo(particle.x, particle.y);
          context.lineTo(neighbor.x, neighbor.y);
          context.strokeStyle = `rgba(91, 155, 255, ${(1 - distance / 180) * 0.05})`;
          context.stroke();
        }
      }

      frame = requestAnimationFrame(draw);
    };

    resize();

    if (!reduceMotion.matches) {
      resetIdleTimer();
    } else {
      draw();
    }

    window.addEventListener("resize", resize);
    window.addEventListener("pointermove", handlePointer, { passive: true });

    return () => {
      cancelAnimationFrame(frame);
      if (idleTimer) clearTimeout(idleTimer);
      window.removeEventListener("resize", resize);
      window.removeEventListener("pointermove", handlePointer);
    };
  }, []);

  return <canvas ref={canvasRef} className="ambient-canvas" aria-hidden="true" />;
}
