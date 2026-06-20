"use client";

import React, { useState, useRef, useEffect } from 'react';
import { Play, Pause, Volume2, VolumeX, SkipBack, SkipForward, Maximize2, Sparkles, Gauge, X } from 'lucide-react';

interface VideoPlayerProps {
  videoSrc?: string;
  className?: string;
}

export default function VideoPlayer({ videoSrc, className }: VideoPlayerProps) {
  const [isPlaying, setIsPlaying] = useState(false);
  const [currentTime, setCurrentTime] = useState(0);
  const [duration, setDuration] = useState(0);
  const [volume, setVolume] = useState(0.72);
  const [isMuted, setIsMuted] = useState(false);
  const [playbackRate, setPlaybackRate] = useState(1.0);
  const [isFramePlusActive, setIsFramePlusActive] = useState(false);
  const [isVisualEnhancementsActive, setIsVisualEnhancementsActive] = useState(false);
  const [isControlsVisible, setIsControlsVisible] = useState(true);
  const [isFramePlusPreparing, setIsFramePlusPreparing] = useState(false);
  const [isFramePlusPreRendered, setIsFramePlusPreRendered] = useState(false);
  const [isArtificialInterpolationActive, setIsArtificialInterpolationActive] = useState(false);
  const [currentRenderingFPS] = useState(0);
  const [isDraggingSlider, setIsDraggingSlider] = useState(false);
  const [dragSliderValue, setDragSliderValue] = useState(0);
  const [showPerformanceStats, setShowPerformanceStats] = useState(false);
  
  const videoRef = useRef<HTMLVideoElement>(null);
  const playerRef = useRef<HTMLDivElement>(null);
  const controlsTimeoutRef = useRef<NodeJS.Timeout | null>(null);
  
  const formatTime = (seconds: number) => {
    const totalSeconds = Math.max(0, Math.floor(seconds));
    const hours = Math.floor(totalSeconds / 3600);
    const minutes = Math.floor((totalSeconds % 3600) / 60);
    const secs = totalSeconds % 60;
    if (hours > 0) return `${hours}:${minutes.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
    return `${minutes}:${secs.toString().padStart(2, '0')}`;
  };

  const handlePlayPause = () => {
    if (videoRef.current) {
      if (isPlaying) videoRef.current.pause();
      else videoRef.current.play();
      setIsPlaying(!isPlaying);
    }
  };

  const handleVolumeChange = (value: number) => {
    setVolume(value);
    if (videoRef.current) videoRef.current.volume = value;
  };

  const handleMuteToggle = () => {
    if (videoRef.current) {
      if (isMuted) {
        videoRef.current.volume = volume > 0 ? volume : 0.72;
        setVolume(videoRef.current.volume);
      } else {
        videoRef.current.volume = 0;
        setVolume(0);
      }
      setIsMuted(!isMuted);
    }
  };

  const handleSeek = (value: number) => {
    if (videoRef.current) {
      videoRef.current.currentTime = value;
      setCurrentTime(value);
    }
  };

  const handleSeekBackward = () => {
    if (videoRef.current) videoRef.current.currentTime = Math.max(0, videoRef.current.currentTime - 10);
  };

  const handleSeekForward = () => {
    if (videoRef.current) videoRef.current.currentTime = Math.min(duration, videoRef.current.currentTime + 10);
  };

  const handleSpeedChange = () => {
    const speeds = [1.0, 1.25, 1.5, 2.0];
    const currentIndex = speeds.indexOf(playbackRate);
    const nextIndex = (currentIndex + 1) % speeds.length;
    const newSpeed = speeds[nextIndex];
    setPlaybackRate(newSpeed);
    if (videoRef.current) videoRef.current.playbackRate = newSpeed;
  };

  const handleFramePlusToggle = () => {
    setIsFramePlusActive(!isFramePlusActive);
    if (!isFramePlusActive) {
      setIsFramePlusPreparing(true);
      setTimeout(() => {
        setIsFramePlusPreparing(false);
        setIsFramePlusPreRendered(true);
        setIsArtificialInterpolationActive(true);
      }, 1500);
    } else {
      setIsArtificialInterpolationActive(false);
      setIsFramePlusPreRendered(false);
    }
  };

  const resetHideTimer = () => {
    if (controlsTimeoutRef.current) clearTimeout(controlsTimeoutRef.current);
    if (isPlaying) {
      controlsTimeoutRef.current = setTimeout(() => setIsControlsVisible(false), 3000);
    }
  };

  const handleMouseMove = () => {
    setIsControlsVisible(true);
    resetHideTimer();
  };

  useEffect(() => {
    const element = playerRef.current;
    if (element) {
      const handler = () => handleMouseMove();
      document.addEventListener('mousemove', handler);
      return () => document.removeEventListener('mousemove', handler);
    }
  }, []);

  useEffect(() => {
    const video = videoRef.current;
    if (!video) return;
    const onTimeUpdate = () => setCurrentTime(video.currentTime);
    const onDurationChange = () => setDuration(video.duration);
    const onRateChange = () => setPlaybackRate(video.playbackRate);
    const onPlay = () => { setIsPlaying(true); resetHideTimer(); };
    const onPause = () => setIsPlaying(false);
    video.addEventListener('timeupdate', onTimeUpdate);
    video.addEventListener('durationchange', onDurationChange);
    video.addEventListener('ratechange', onRateChange);
    video.addEventListener('play', onPlay);
    video.addEventListener('pause', onPause);
    return () => {
      video.removeEventListener('timeupdate', onTimeUpdate);
      video.removeEventListener('durationchange', onDurationChange);
      video.removeEventListener('ratechange', onRateChange);
      video.removeEventListener('play', onPlay);
      video.removeEventListener('pause', onPause);
    };
  }, []);

  const getFpsDisplay = () => {
    if (isFramePlusPreRendered) return 60;
    if (currentRenderingFPS > 0) return currentRenderingFPS;
    return 0;
  };

  const getFramePlusStateTitle = () => {
    if (isFramePlusPreparing) return 'Preparando HQ';
    if (isFramePlusPreRendered) return '60fps listo';
    if (!isFramePlusActive) return 'Desactivado';
    return isArtificialInterpolationActive ? 'Interpolando' : 'Esperando';
  };

  const progress = duration > 0 ? (currentTime / duration) * 100 : 0;

  const btnBase = 'px-3 py-1 rounded-full text-xs font-medium bg-white/5 text-gray-300 border border-white/10 hover:bg-white/10 transition-colors';

  return (
    <div ref={playerRef} className={'relative w-full h-full bg-black overflow-hidden ' + (className || '')} onMouseEnter={handleMouseMove}>
      <video ref={videoRef} src={videoSrc} className="absolute inset-0 w-full h-full object-cover" onClick={handlePlayPause} muted={isMuted} />
      
      <div className="absolute inset-0 pointer-events-none">
        <div className="absolute inset-0 bg-gradient-to-b from-black/20 via-transparent to-black/40" style={{ opacity: isControlsVisible ? 1 : 0, transition: 'opacity 0.3s ease' }} />
        
        <div className="absolute bottom-0 left-0 right-0" style={{ transform: isControlsVisible ? 'translateY(0)' : 'translateY(12px)', opacity: isControlsVisible ? 1 : 0, transition: 'all 0.3s ease' }}>
          <div className="p-4">
            <div className="max-w-3xl mx-auto bg-black/60 backdrop-blur-xl rounded-2xl border border-white/10 shadow-2xl p-3">
              <div className="flex items-center justify-between mb-3">
                <div className="flex items-center gap-3">
                  <div className="flex items-center gap-2 text-white font-medium text-sm">
                    <Sparkles size={16} className="text-blue-400" /> Rift
                  </div>
                  <div className="flex items-center gap-2">
                    <button onClick={handleFramePlusToggle} className={'px-3 py-1 rounded-full text-xs font-medium transition-all duration-200 ' + (isFramePlusActive ? 'bg-blue-500/20 text-blue-400 border border-blue-500/30' : 'bg-white/5 text-gray-400 border border-white/10 hover:bg-white/10')}>
                      {isFramePlusPreparing ? 'Frame+...' : isFramePlusActive ? 'Frame+' : 'Frame+'}
                    </button>
                    <button onClick={() => setIsVisualEnhancementsActive(!isVisualEnhancementsActive)} className={'px-3 py-1 rounded-full text-xs font-medium transition-all duration-200 ' + (isVisualEnhancementsActive ? 'bg-purple-500/20 text-purple-400 border border-purple-500/30' : 'bg-white/5 text-gray-400 border border-white/10 hover:bg-white/10')}>
                      <span className="flex items-center gap-1"><Gauge size={12} /> Visual</span>
                    </button>
                  </div>
                </div>
                <div className="flex items-center gap-2 text-xs">
                  <span className="text-gray-400">{getFpsDisplay().toFixed(0)} FPS</span>
                  <span className="text-gray-500">{getFramePlusStateTitle()}</span>
                </div>
              </div>

              <div className="space-y-3">
                <div className="flex items-center gap-3">
                  <span className="text-xs text-gray-400 w-12">{formatTime(currentTime)}</span>
                  <div className="flex-1 h-1 bg-white/10 rounded-full overflow-hidden">
                    <div className="h-full bg-gradient-to-r from-blue-500 to-cyan-500 rounded-full" style={{ width: progress + '%', transition: 'width 0.1s ease' }} />
                  </div>
                  <span className="text-xs text-gray-400 w-12 text-right">{formatTime(duration)}</span>
                </div>

                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <button onClick={handleSeekBackward} className="w-8 h-8 bg-white/5 hover:bg-white/10 rounded-full flex items-center justify-center"><SkipBack size={16} className="text-gray-300" /></button>
                    <button onClick={handlePlayPause} className="w-12 h-12 bg-white hover:bg-gray-200 rounded-full flex items-center justify-center shadow-lg">
                      {isPlaying ? <Pause size={20} className="text-black" /> : <Play size={20} className="text-black ml-0.5" />}
                    </button>
                    <button onClick={handleSeekForward} className="w-8 h-8 bg-white/5 hover:bg-white/10 rounded-full flex items-center justify-center"><SkipForward size={16} className="text-gray-300" /></button>
                    <div className="flex items-center gap-2 ml-2">
                      <Volume2 size={14} className="text-gray-400" />
                      <div className="w-20 h-1 bg-white/10 rounded-full overflow-hidden">
                        <div className="h-full bg-gradient-to-r from-blue-500 to-cyan-500 rounded-full" style={{ width: (isMuted ? 0 : volume * 100) + '%' }} />
                      </div>
                      <button onClick={handleMuteToggle} className="w-6 h-6 hover:bg-white/10 rounded">{isMuted ? <VolumeX size={14} className="text-gray-400" /> : <Volume2 size={14} className="text-gray-400" />}</button>
                    </div>
                  </div>
                  <div className="flex items-center gap-2">
                    <button onClick={handleSpeedChange} className={btnBase}>{playbackRate === 1.0 ? '1x' : playbackRate.toFixed(2) + 'x'}</button>
                    <button onClick={() => setShowPerformanceStats(!showPerformanceStats)} className="w-8 h-8 bg-white/5 hover:bg-white/10 rounded-full flex items-center justify-center"><Maximize2 size={14} className="text-gray-400" /></button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        {showPerformanceStats && (
          <div className="absolute top-4 right-4 bg-black/80 backdrop-blur-xl rounded-lg border border-white/10 p-4 text-xs text-gray-300">
            <div className="flex items-center justify-between mb-2">
              <span className="text-white font-medium">Rendimiento</span>
              <button onClick={() => setShowPerformanceStats(false)} className="text-gray-400 hover:text-white"><X size={14} /></button>
            </div>
            <div className="space-y-1">
              <div>FPS: {currentRenderingFPS.toFixed(1)}</div>
              <div>Frame+: {isFramePlusActive ? 'Si' : 'No'}</div>
              <div>Visual: {isVisualEnhancementsActive ? 'Si' : 'No'}</div>
              <div>Velocidad: {playbackRate.toFixed(2)}x</div>
              <div>Volumen: {Math.round(volume * 100)}%</div>
              <div>Interpolacion: {isArtificialInterpolationActive ? 'Activa' : 'Inactiva'}</div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
