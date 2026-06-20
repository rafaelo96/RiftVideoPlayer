"use client";

import { Captions, Gauge, Maximize2, MonitorPlay, Play, SkipBack, SkipForward, Sparkles } from "lucide-react";
import type { CSSProperties } from "react";
import VideoPlayer from "./VideoPlayer";

export type ProductHighlight = "controls" | "frame" | "visual" | "performance" | "subtitles" | "none";

type VideoPlayerDemoProps = {
  highlight?: ProductHighlight;
  modeLabel?: string;
  progress?: number;
  visualTone?: "cinema" | "bright" | "deep" | "studio";
  className?: string;
};

const highlightClass: Record<ProductHighlight, string> = {
  controls: "highlight-ring controls",
  frame: "highlight-ring frame",
  visual: "highlight-ring visual",
  performance: "highlight-ring performance",
  subtitles: "highlight-ring subtitles",
  none: "highlight-ring hidden"
};

export default function VideoPlayerDemo({
  highlight = "none",
  modeLabel = "Frame+",
  progress = 58,
  visualTone = "cinema",
  className
}: VideoPlayerDemoProps) {
  const safeProgress = Math.min(96, Math.max(8, progress));

  return (
    <div className={`mac-window ${visualTone} ${className ?? ""}`}>
      <div className="mac-chrome">
        <div className="traffic" aria-hidden="true">
          <span />
          <span />
          <span />
        </div>
        <span className="chrome-title">Rift</span>
        <Maximize2 size={13} aria-hidden="true" />
      </div>
      <div className="video-surface">
        <VideoPlayer className="w-full h-full" />
        <div className="video-caption">Latino 5.1</div>
        <div className="player-controls">
          <div className="timeline" style={{ "--progress": `${safeProgress}%` } as CSSProperties}>
            <span />
          </div>
          <div className="control-cluster">
            <span className="control-dot" aria-hidden="true">
              <SkipBack size={14} />
            </span>
            <span className="control-dot play" aria-hidden="true">
              <Play size={15} fill="currentColor" />
            </span>
            <span className="control-dot" aria-hidden="true">
              <SkipForward size={14} />
            </span>
            <span className="control-pill active">
              <Sparkles size={12} />
              {modeLabel}
            </span>
            <span className="control-pill">
              <Gauge size={12} />
              60 FPS
            </span>
            <span className="control-pill">
              <Captions size={12} />
              Subs
            </span>
            <span className="control-pill">
              <MonitorPlay size={12} />
              HDR
            </span>
          </div>
        </div>
        <span className={highlightClass[highlight]} />
      </div>
    </div>
  );
}
