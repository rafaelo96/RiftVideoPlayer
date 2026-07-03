# Graph Report - /Users/rafael/VideoPlayerUI  (2026-07-03)

## Corpus Check
- cluster-only mode — file stats not available

## Summary
- 948 nodes · 2090 edges · 57 communities (46 shown, 11 thin omitted)
- Extraction: 96% EXTRACTED · 4% INFERRED · 0% AMBIGUOUS · INFERRED: 83 edges (avg confidence: 0.77)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `b2ba62a0`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- [[_COMMUNITY_Community 0|Community 0]]
- [[_COMMUNITY_Community 1|Community 1]]
- [[_COMMUNITY_Community 2|Community 2]]
- [[_COMMUNITY_Community 3|Community 3]]
- [[_COMMUNITY_Community 4|Community 4]]
- [[_COMMUNITY_Community 5|Community 5]]
- [[_COMMUNITY_Community 6|Community 6]]
- [[_COMMUNITY_Community 7|Community 7]]
- [[_COMMUNITY_Community 8|Community 8]]
- [[_COMMUNITY_Community 9|Community 9]]
- [[_COMMUNITY_Community 10|Community 10]]
- [[_COMMUNITY_Community 11|Community 11]]
- [[_COMMUNITY_Community 12|Community 12]]
- [[_COMMUNITY_Community 13|Community 13]]
- [[_COMMUNITY_Community 14|Community 14]]
- [[_COMMUNITY_Community 15|Community 15]]
- [[_COMMUNITY_Community 16|Community 16]]
- [[_COMMUNITY_Community 17|Community 17]]
- [[_COMMUNITY_Community 18|Community 18]]
- [[_COMMUNITY_Community 19|Community 19]]
- [[_COMMUNITY_Community 20|Community 20]]
- [[_COMMUNITY_Community 21|Community 21]]
- [[_COMMUNITY_Community 22|Community 22]]
- [[_COMMUNITY_Community 23|Community 23]]
- [[_COMMUNITY_Community 24|Community 24]]
- [[_COMMUNITY_Community 25|Community 25]]
- [[_COMMUNITY_Community 26|Community 26]]
- [[_COMMUNITY_Community 27|Community 27]]
- [[_COMMUNITY_Community 29|Community 29]]
- [[_COMMUNITY_Community 30|Community 30]]
- [[_COMMUNITY_Community 31|Community 31]]
- [[_COMMUNITY_Community 32|Community 32]]
- [[_COMMUNITY_Community 33|Community 33]]
- [[_COMMUNITY_Community 34|Community 34]]
- [[_COMMUNITY_Community 35|Community 35]]
- [[_COMMUNITY_Community 36|Community 36]]
- [[_COMMUNITY_Community 37|Community 37]]
- [[_COMMUNITY_Community 38|Community 38]]
- [[_COMMUNITY_Community 39|Community 39]]
- [[_COMMUNITY_Community 40|Community 40]]
- [[_COMMUNITY_Community 41|Community 41]]
- [[_COMMUNITY_Community 42|Community 42]]
- [[_COMMUNITY_Community 43|Community 43]]
- [[_COMMUNITY_Community 44|Community 44]]
- [[_COMMUNITY_Community 45|Community 45]]
- [[_COMMUNITY_Community 46|Community 46]]
- [[_COMMUNITY_Community 47|Community 47]]
- [[_COMMUNITY_Community 48|Community 48]]
- [[_COMMUNITY_Community 51|Community 51]]
- [[_COMMUNITY_Community 52|Community 52]]
- [[_COMMUNITY_Community 53|Community 53]]
- [[_COMMUNITY_Community 54|Community 54]]
- [[_COMMUNITY_Community 55|Community 55]]
- [[_COMMUNITY_Community 56|Community 56]]
- [[_COMMUNITY_Community 57|Community 57]]
- [[_COMMUNITY_Community 58|Community 58]]

## God Nodes (most connected - your core abstractions)
1. `PlayerState` - 128 edges
2. `MetalVideoRenderer` - 87 edges
3. `VideoInterpolationPipeline` - 41 edges
4. `RIFEEngine` - 40 edges
5. `Coordinator` - 26 edges
6. `ContentView` - 22 edges
7. `SourceVideoFrame` - 22 edges
8. `MediaTrack` - 20 edges
9. `FramePlusMEMCEngine` - 19 edges
10. `VideoDecoderEngine` - 19 edges

## Surprising Connections (you probably didn't know these)
- `PlayerStateTests` --calls--> `PlayerState`  [INFERRED]
  Tests/RiftTests/RiftTests.swift → Sources/Rift/PlayerState.swift
- `import_ifnet()` --indirect_call--> `IFNet`  [INFERRED]
  scripts/convert_rife_v4_coreml.py → external/rife-4.25-lite/train_log/IFNet_HDv3.py
- `RiftLogo` --references--> `View`  [EXTRACTED]
  Sources/Rift/ContentView.swift → Sources/Rift/LiquidGlassPanel.swift
- `ContentView` --calls--> `PlayerState`  [INFERRED]
  Sources/Rift/ContentView.swift → Sources/Rift/PlayerState.swift
- `MetalVideoRenderer` --calls--> `AsyncFrameBuffer`  [INFERRED]
  Sources/Rift/RiftPlayerView.swift → Sources/Rift/FramePipeline.swift

## Import Cycles
- None detected.

## Communities (57 total, 11 thin omitted)

### Community 0 - "Community 0"
Cohesion: 0.09
Nodes (30): Accelerate, CVPixelBufferPool, Float16, LocalizedError, MLComputeUnits, MLFeatureProvider, MLFeatureValue, MLModelDescription (+22 more)

### Community 1 - "Community 1"
Cohesion: 0.09
Nodes (19): KSPlayerLayer, KSPlayerState, MediaPlayerTrack, NSViewRepresentable, Coordinator, DirectFFmpegHostView, DirectFFmpegPlayerView, Context (+11 more)

### Community 2 - "Community 2"
Cohesion: 0.07
Nodes (19): conv(), Head, IFBlock, IFNet, ResConv, Model, Module, Namespace (+11 more)

### Community 3 - "Community 3"
Cohesion: 0.06
Nodes (17): ControlBar(), ControlBarProps, formatTime(), AudioScene(), spectrumLines, stars, HDRScene(), LogoScene() (+9 more)

### Community 4 - "Community 4"
Cohesion: 0.08
Nodes (21): Notification, NSApplication, NSApplicationDelegate, NSItemProvider, NSObject, NSWindow, AmbientParticle, ContentView (+13 more)

### Community 5 - "Community 5"
Cohesion: 0.09
Nodes (22): CoreML, Foundation, NSFont, NSPoint, NSTextAlignment, drawText(), CGFloat, String (+14 more)

### Community 6 - "Community 6"
Cohesion: 0.14
Nodes (21): MTLComputeCommandEncoder, MTLComputePipelineState, MTLLibrary, MTLPixelFormat, FramePlusMEMCEngine, FramePlusMEMCError, function, library (+13 more)

### Community 7 - "Community 7"
Cohesion: 0.13
Nodes (29): constant, half, half2, half3, kernel, read, sample, lumaFromRGB() (+21 more)

### Community 8 - "Community 8"
Cohesion: 0.10
Nodes (14): AVMediaSelectionGroup, AVMediaSelectionOption, AVPlayerItemLegibleOutput, AVPlayerItemLegibleOutputPushDelegate, IOPMAssertionID, NSAttributedString, ObservableObject, PlayerState (+6 more)

### Community 9 - "Community 9"
Cohesion: 0.12
Nodes (13): Darwin, Rift, Testing, BenchmarkResult, RIFEEngineBenchmarks, CVPixelBuffer, Double, Float (+5 more)

### Community 10 - "Community 10"
Cohesion: 0.13
Nodes (15): CFTypeRef, CGRect, CIKernel, MTKViewDelegate, MetalVideoRenderer, Any, CFString, CGColorSpace (+7 more)

### Community 11 - "Community 11"
Cohesion: 0.14
Nodes (10): ContiguousArray, DispatchSourceTimer, AsyncFrameBuffer, FramePrefetcher, SourceVideoFrame, AVPlayerItemVideoOutput, Bool, CMTime (+2 more)

### Community 12 - "Community 12"
Cohesion: 0.15
Nodes (13): Data, Network, NWConnection, NWEndpoint, NWListener, Range, LocalHLSHTTPServer, StartState (+5 more)

### Community 13 - "Community 13"
Cohesion: 0.08
Nodes (24): dependencies, framer-motion, gsap, lenis, next, react, react-dom, devDependencies (+16 more)

### Community 14 - "Community 14"
Cohesion: 0.13
Nodes (10): MainActor, NSScreen, MetalVideoView, RiftPlayerView, AVPlayer, AVPlayerItem, Context, Int (+2 more)

### Community 15 - "Community 15"
Cohesion: 0.19
Nodes (7): AVAssetTrack, Equatable, Identifiable, AudioTrack, AVPlayerItem, Task, MediaTrack

### Community 16 - "Community 16"
Cohesion: 0.10
Nodes (19): compilerOptions, allowJs, esModuleInterop, incremental, isolatedModules, jsx, lib, module (+11 more)

### Community 17 - "Community 17"
Cohesion: 0.17
Nodes (13): OutputFrame, Bool, CMTime, CVPixelBuffer, Double, Int, MTLCommandBuffer, MTLTexture (+5 more)

### Community 18 - "Community 18"
Cohesion: 0.18
Nodes (3): Bundle, Process, URL

### Community 19 - "Community 19"
Cohesion: 0.16
Nodes (13): CFTimeInterval, MetalKit, InterpolatedImage, LiveInterpolationPair, MEMCImage, MEMCIntensity, high, Bool (+5 more)

### Community 20 - "Community 20"
Cohesion: 0.15
Nodes (12): AppKit, CryptoKit, IOKit.pwr_mgt, KSPlayer, OSLog, RiftLogo, PlaybackBackend, avFoundation (+4 more)

### Community 21 - "Community 21"
Cohesion: 0.12
Nodes (18): Sendable, Config, Downscaler, bilinear, hermite, lanczos, Bool, Int (+10 more)

### Community 22 - "Community 22"
Cohesion: 0.23
Nodes (9): AVAssetReader, AVAssetReaderTrackOutput, AVURLAsset, AVAsset, CMTime, Int, KSOptions, URL (+1 more)

### Community 23 - "Community 23"
Cohesion: 0.30
Nodes (3): Bool, CMTime, Double

### Community 24 - "Community 24"
Cohesion: 0.16
Nodes (3): AnyObject, DirectFFmpegPlaybackControlling, Float

### Community 25 - "Community 25"
Cohesion: 0.20
Nodes (9): AsyncStream, CIContext, MTLCommandQueue, MTLDevice, Never, Task, URL, Void (+1 more)

### Community 26 - "Community 26"
Cohesion: 0.19
Nodes (7): CAMetalDrawable, MTKView, AVPlayerItemVideoOutput, CGSize, CIContext, CMTime, MTLCommandBuffer

### Community 27 - "Community 27"
Cohesion: 0.20
Nodes (12): CGPoint, PlaceboRenderer, CGColorSpace, CIContext, CIImage, CVPixelBuffer, MTLCommandBuffer, MTLDevice (+4 more)

### Community 29 - "Community 29"
Cohesion: 0.22
Nodes (6): FPSMode, flux, native, StreamInfo, Int, String

### Community 30 - "Community 30"
Cohesion: 0.14
Nodes (13): author, description, name, path, author, description, name, path (+5 more)

### Community 31 - "Community 31"
Cohesion: 0.28
Nodes (10): Color, Content, GlassBackground, GlassButtonStyle, GlassCapsule, LiquidGlassPanel, Bool, CGFloat (+2 more)

### Community 32 - "Community 32"
Cohesion: 0.24
Nodes (5): Contextnet, conv(), Conv2, deconv(), Unet

### Community 33 - "Community 33"
Cohesion: 0.33
Nodes (9): OpticalFlowEngine, OpticalFlowInput, OpticalFlowSnapshot, CVPixelBuffer, Float, Int, String, TimeInterval (+1 more)

### Community 34 - "Community 34"
Cohesion: 0.30
Nodes (7): AVFoundation, CoreImage, CoreMedia, CoreVideo, Metal, os, QuartzCore

### Community 35 - "Community 35"
Cohesion: 0.23
Nodes (7): NSView, NativeVideoLayerView, NativeVideoPlayerView, AVPlayer, Context, NSCoder, NSRect

### Community 36 - "Community 36"
Cohesion: 0.31
Nodes (8): GlassIconButton, PlayerControlsView, Bool, CGFloat, Double, String, Void, TimelineTrack

### Community 38 - "Community 38"
Cohesion: 0.25
Nodes (8): LiquidGlassButton, Size, compact, largeIcon, metric, CGFloat, String, Void

### Community 39 - "Community 39"
Cohesion: 0.22
Nodes (9): Kind, audio, subtitle, video, VideoDecoderEngineError, asset, endOfStream, reader (+1 more)

### Community 41 - "Community 41"
Cohesion: 0.25
Nodes (5): body, display, metadata, mono, ClientLayout()

### Community 43 - "Community 43"
Cohesion: 0.29
Nodes (7): CaseIterable, InterpolationMode, disabled, motion2Intense, rife2x, rife4x, rifeAdaptive

### Community 44 - "Community 44"
Cohesion: 0.33
Nodes (6): Upscaler, bilinear, ewa_lanczos, jinc, lanczos, nearest

### Community 45 - "Community 45"
Cohesion: 0.40
Nodes (4): App, Scene, Notification.Name, RiftApp

### Community 46 - "Community 46"
Cohesion: 0.40
Nodes (3): AVVideoComposition, AVAsset, CIImage

### Community 47 - "Community 47"
Cohesion: 0.40
Nodes (5): Error, PlaceboRendererError, metal, render, String

### Community 48 - "Community 48"
Cohesion: 0.70
Nodes (3): NSVisualEffectView, NativeVisualEffectView, Context

## Knowledge Gaps
- **136 isolated node(s):** `PackageDescription`, `os`, `fullWidth`, `fullHeight`, `lowWidth` (+131 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **11 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `PlayerState` connect `Community 8` to `Community 1`, `Community 4`, `Community 36`, `Community 37`, `Community 9`, `Community 42`, `Community 12`, `Community 46`, `Community 15`, `Community 18`, `Community 20`, `Community 23`, `Community 24`, `Community 25`, `Community 27`, `Community 29`?**
  _High betweenness centrality (0.255) - this node is a cross-community bridge._
- **Why does `MetalVideoRenderer` connect `Community 10` to `Community 33`, `Community 4`, `Community 5`, `Community 6`, `Community 11`, `Community 14`, `Community 19`, `Community 25`, `Community 26`, `Community 29`?**
  _High betweenness centrality (0.170) - this node is a cross-community bridge._
- **Why does `VideoInterpolationPipeline` connect `Community 25` to `Community 0`, `Community 34`, `Community 37`, `Community 8`, `Community 40`, `Community 10`, `Community 43`, `Community 14`, `Community 17`, `Community 51`, `Community 22`, `Community 27`?**
  _High betweenness centrality (0.166) - this node is a cross-community bridge._
- **Are the 4 inferred relationships involving `PlayerState` (e.g. with `ContentView` and `.selectAudioTrack()`) actually correct?**
  _`PlayerState` has 4 INFERRED edges - model-reasoned connections that need verification._
- **Are the 3 inferred relationships involving `MetalVideoRenderer` (e.g. with `AsyncFrameBuffer` and `OpticalFlowEngine`) actually correct?**
  _`MetalVideoRenderer` has 3 INFERRED edges - model-reasoned connections that need verification._
- **What connects `PackageDescription`, `os`, `fullWidth` to the rest of the system?**
  _136 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Community 0` be split into smaller, more focused modules?**
  _Cohesion score 0.09376890502117362 - nodes in this community are weakly interconnected._