# Session Summary

## Current State
Player website running at localhost:3000 with full Anytype-inspired redesign.

## What we did

### Initial: macOS-styled video player
- Native macOS traffic light buttons, titlebar, menu bar, status bar (WiFi, battery, clock)
- Grid-style "featured in" section at bottom
- Everything scaled together via `transform: scale(1.6)` — controls grew oversized

### Bento Grid redesign (session 2)
- Switched to Anytype-inspired dark theme design
- Color palette: `oklch()` ink/panel/accent/rule tokens, warm accent
- Layout: bento grid with FeatureCard components, pixel-precise spacing
- Removed macOS chrome, "featured in" bar, simplified to 4 bento features
- Dark/light mode via `.dark` class, prefers-color-scheme detection, toggle in nav
- Premium table with System/Value/Why It Matters columns
- Rift logo with animated gradient
- Smooth scroll, sticky nav with backdrop-blur
- Framer Motion was introduced but later fully removed (animation reverted to GSAP-only)

### Anytype redesign (session 2 continued)
- Full design system: `--color-ink`, `--color-panel`, `--color-accent`, etc.
- Anytype-style nav: left logo, center links, right CTA
- Hero with large display text "Video, made native."
- Premium selector group for features (similar to Anytype's tab navigation)
- Centered window bar with title "Rift — 4K HDR Demo.mov"
- Controls: timeline, play controls, Frame⁺ badge, volume/speed/subs
- Feature cards: 6 features in 3x2 grid (Liquid Glass UI, Frame+ AI, Format Support, HDR, Movable Controls, Metal Pipeline)
- Pipeline table: render path, interpolation, sync target, tone mapping, format engine, platform
- Downloads section with card layout for DMG / Build from source
- Footer with minimal links
- Hero visual: Anytype-style window with player inside + macOS menu bar
- No animation on page load (static initial render)
- Scale is 1.6 across all scenes

### StickyPlayer restructuring (session 3 — control alignment fix)
- **Problem**: `transform: scale(1.6)` was applied to the entire player element, making the window bar, controls, and story text all oversized and mispositioned
- **Fix**: Only the scene layer (`.absolute inset-0` inside the screen area) scales via `transform: scale()`. The window bar, story text overlay, and ControlBar all live *outside* the zoom layer but inside the `.aspect-video` screen area, so they stay at natural size and correct position
- Controls are anchored at the bottom of the `.aspect-video` container regardless of zoom
- Build passes cleanly with no TypeScript or compilation errors

## Audit: Native App (Rift) — Problems & Fixes

### 🔴 Critical

| # | File:Line | Problem | Fix |
|---|-----------|---------|-----|
| 1 | `PlayerState.swift:1347` | **Main-thread blocking loop** — `runFFmpegHLS` polls `process.isRunning` in a `while` loop on `@MainActor` with `Task.sleep`. Freezes UI for the entire FFmpeg duration (minutes). | Move polling to a detached background Task; post status via `Notification` or `@Published` on `MainActor`. |
| 2 | `PlayerState.swift:1452` | **Polling instead of FSEvents** — `startHLSPlaylistMirror` polls files every 250ms on MainActor. Wastes CPU; misses fast segment writes. | Replace with `DispatchSource.makeFileDispatchSource` or `FSEventStream` on the HLS directory. |
| 3 | `ContentView.swift:224-267` | **Keyboard monitor leak** — `NSEvent.addLocalMonitorForEvents(matching:handler:)` stores the old monitor but SwiftUI can recreate `ContentView` without deinit, causing multiple monitors to stack. | Store monitor in a `static` / shared registry, or use `NSApplication.shared.delegate` pattern in `RiftApp`. |
| 4 | `ContentView.swift:186` | **Infinite animation consumes CPU** — `repeatForever` on `promptPulse` runs even when `openVideoPrompt` is hidden. | Stop the animation when `hasVideo = true`. |
| 5 | `ContentView.swift:391-413` | **Film grain runs at display refresh rate** — `TimelineView(.animation(paused: false))` redraws entire canvas every frame with `CGFloat.random()`. | Reduce to ~6fps; use pre-generated noise texture. |

### 🟡 High

| # | File:Line | Problem | Fix |
|---|-----------|---------|-----|
| 6 | `RiftApp.swift:81-100` | **Duplicate PlayerState** — `createFallbackWindowIfNeeded()` creates a second `ContentView` → second `PlayerState`. Two instances exist if both paths activate. | Reuse the existing window's `PlayerState` via shared singleton or environment. |
| 7 | `RiftPlayerView.swift:552` | **Semaphore blocks calling thread** — `framePlusInFlightSemaphore.wait(timeout: .now()+0.008)` blocks Metal display link for up to 8ms. | Use async `Task` with `await` or double-buffer without backpressure. |
| 8 | `RiftPlayerView.swift:859` | **GPU use-after-free risk** — `framePlusOutputPoolA/B` set to `nil` while GPU may still be reading. | Wrap in `MTLCommandBuffer` completion handler before releasing. |
| 9 | `RiftPlayerView.swift:1213` | **Race in AsyncFrameBuffer** — `frameBuffer.reset()` clears indices while `FramePrefetcher` may be mid-enqueue. | Add atomic flag or cancel prefetcher before reset. |
| 10 | `RiftPlayerView.swift:215-238` | `nonisolated(unsafe)` observations accessed in deinit via `DispatchQueue.main.async` — KVO callback could fire between deinit and async block. | Move observation cleanup to `.onDisappear` or explicit `invalidate()`. |
| 11 | `PlayerState.swift:1707` | **HLS parser is incomplete** — no handling of `EXT-X-BYTERANGE`, `EXT-X-KEY`, `EXT-X-DISCONTINUITY`, multiple variants. Breaks on real streams. | Use `AVPlayerItem` for HLS or delegate to a proven parser. |

### 🟢 Medium

| # | File:Line | Problem | Fix |
|---|-----------|---------|-----|
| 12 | `PlayerState.swift:390` | **No debounce on track selection** — rapid taps spawn multiple `loadTracks` Tasks. | Add `TaskDebouncer` or cancel previous task. |
| 13 | `PlayerState.swift:1990` | **AVPlayer decodes all audio tracks** — `applyAudioMix` sets volume=0 instead of removing tracks. | Use `AVPlayerItem.tracks` to disable unselected tracks. |
| 14 | `PlayerState.swift:2002` | **FFmpeg search only checks 3 paths** — misses Homebrew, MacPorts, Nix, `~/.local/bin`. | Search `PATH` via `which ffmpeg`. |
| 15 | `RiftPlayerView.swift:1290` | **GPU sync every 6 frames** — `detectSceneChangeIfNeeded` reads back 1px `CIAreaAverage` pixel buffer. | Use Metal compute shader for histogram without readback. |
| 16 | `PlayerControlsView.swift:458` | **Hardcoded timeline width** — `value.translation.width + 340` assumes 680px track. | Use `GeometryReader` for actual width. |
| 17 | `RiftPlayerView.swift:164` | **CIKernel as inline string** — ~50 lines GLSL string literal in Swift; no compile-time validation. | Move to `.ci.metal` file and load via `MTLLibrary`. |

---

## Audit: Website (Next.js) — Problems & Fixes

### 🔴 Critical

| # | File:Line | Problem | Fix |
|---|-----------|---------|-----|
| 1 | `Navbar.tsx:29` | **Mobile nav completely broken** — links hidden below 48rem with no hamburger/toggle. Mobile users cannot access Features / Technology / Download. | Add hamburger menu + slide-in drawer with `useState`. |
| 2 | `ControlBar.tsx:68,96,123` | **Buttons that do nothing** — "Mute preview audio", "Previous chapter", "Next chapter" are focusable `<button>`s with no `onClick`. Keyboard trap for assistive tech. | Wire handlers or replace with `<span>` + remove from tab order. |
| 3 | `ControlBar.tsx:130` | **Invisible but tabbable controls** — `opacity-0` + `pointer-events-none` keeps controls in tab order when hidden. | Add `inert` attribute or `display: none` when hidden. |
| 4 | `globals.css:782` | **`prefers-reduced-motion` only shortens, doesn't disable** — users who need no motion still get 150ms animations. | `* { animation: none !important; transition: none !important; }` at 0 duration. |

### 🟡 High

| # | File:Line | Problem | Fix |
|---|-----------|---------|-----|
| 5 | Cross-cutting | **No Error Boundary** — Any uncaught React exception white-screens the entire page. | Wrap `<ClientLayout>` in `<ErrorBoundary>` with fallback UI. |
| 6 | `page.tsx:12-17` | **Stale closure in scroll-to-hash** — `setTimeout` in `useEffect` without cleanup; fires on unmounted component. | Return cleanup `() => clearTimeout()`. |
| 7 | `layout.tsx` | **No skip-to-content link** — keyboard users must tab through entire nav. | Add `<SkipLink>` as first child of `<body>`. |
| 8 | `globals.css:57` | **Global `:focus { outline: none }`** — removes focus ring without equivalent visible indicator in older browsers. | Keep `:focus-visible` only. |
| 9 | `ClientLayout.tsx:29` | **Lenis ignores `prefers-reduced-motion`** — smooth scroll still animates for users who need reduced motion. | Read media query; set `duration: 0` when reduced. |

### 🟢 Medium

| # | File:Line | Problem | Fix |
|---|-----------|---------|-----|
| 10 | `CinematicScene.tsx:28` | **Undefined CSS animation `ray-sweep`** — keyframe doesn't exist, animation silently fails. | Define `@keyframes ray-sweep` or remove dead code. |
| 11 | `AudioScene.tsx:61-69` | **144 concurrent SVG `<animate>` elements** — extreme performance cost on low-power devices. | Replace with JS-driven Canvas or CSS transitions. |
| 12 | `CinematicScene.tsx:50` | **Full-viewport feTurbulence SVG filter** — heavy GPU cost on all GPUs. | Reduce resolution or use pre-rendered image. |
| 13 | `package.json` | **`framer-motion` installed but unused** — adds ~30KB gzipped dead JS. | Remove from dependencies. |
| 14 | `globals.css:694` | **Nav links `display: none` below 48rem with no fallback** — no mobile nav at all. | See #1 above. |
| 15 | `Features.tsx:95` | **Array index as React key** — `key={i}` on a static list (ok for now but fragile). | Use stable feature title as key. |

---

## Summary

| Severity | App (native) | Website |
|----------|:------------:|:-------:|
| 🔴 Critical | 5 | 4 |
| 🟡 High | 5 | 5 |
| 🟢 Medium | 7 | 6 |
| **Total** | **17** | **15** |

**Top priorities:**
1. **Native**: Kill the main-thread FFmpeg polling loop (freezes UI for minutes)
2. **Native**: Fix keyboard monitor leak (crashes after repeated file opens)
3. **Website**: Add mobile navigation (50%+ of users currently see a broken site)
4. **Website**: Wire or fix the 3 non-functional buttons in ControlBar
5. **Both**: Respect `prefers-reduced-motion` properly (accessibility)
