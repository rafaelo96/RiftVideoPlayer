# Session Summary

## Current State
Player website running at localhost:3000 with full Anytype-inspired redesign.
Rift native app v1.0.0-dev with working Frame⁺ MEMC, menu bar, EDR control.

## What we did

### Initial: macOS-styled video player → Anytype redesign → Frame⁺ MEMC fix
Multiple redesign sessions. Current app has:
- Frame⁺ MEMC interpolation (Metal compute shaders) — was broken because `Rift_Rift.bundle` wasn't copied to `.app`
- Menu bar with File → Open File (⌘O), About Rift with build info
- EDR dynamic switching (bgra10_xr for HDR, bgra8Unorm for SDR)
- Version tracking: `1.0.0-dev.<git-count>` in About panel and DMG

---

## Full Codebase Audit

### 🔴 Critical — Silent Failures (like the Frame+ bundle bug)

| # | File:Line | Problem | Fix |
|---|-----------|---------|-----|
| S1 | `RiftPlayerView.swift:396-398` | **RIFE engine load failure — empty catch** — model missing or corrupt, just sets backoff timer. No user feedback. | Log error + show `statusMessage` or fallback gracefully. |
| S2 | `RIFECoreMLInterpolator.swift:50-54` | **Silent return from throws function** — `loadEngine()` is `async throws` but returns without throwing when model URL not found. Caller never sees failure. | Throw the error so caller can handle it. |
| S3 | `RiftPlayerView.swift:773-774` | **Frame+ MEMC encode failure — empty catch** — GPU shader failure silently returns nil, pipeline degrades to crossfade. No feedback. | Log GPU error + increment a fallback counter. |
| S4 | `FramePlusMEMCEngine.swift:168-209` | **GPU encoder nil — silent skip** — all 5 `encode*` sub-functions `guard` on `makeComputeCommandEncoder()` and silently return. The pipeline continues as if nothing happened. | Propagate encoder failure upward, throw from `encode()`. |
| S5 | `PlayerState.swift:1504,1620` | **HLS playlist write result discarded** — `_ = Self.writeMirroredHLSPlaylist(...)` ignores the `Bool` return. Stale playlist silently served. | Check result; set `hlsPlaybackURL = nil` on failure. |
| S6 | `PlayerState.swift:772-773` | **Cache directory creation failure — silent** — `FileManager.createDirectory` fails, returns `false`. No user feedback. | Log + show cache failure only in development. |
| S7 | `PlayerState.swift:890-891` | **FFprobe failure — empty array** — `inspectTracks` catch returns `[]`. Track list is empty, user sees no audio/subtitle options. | Log FFprobe path/error. |
| S8 | `PlayerState.swift:1731-1732` | **HLS playlist write failure — silently returns false** — mirrored playlist write fails, HLS playback silently breaks. | Propagate error up. |
| S9 | `OpticalFlowEngine.swift:111-115` | **Optical flow failure — empty catch** — Vision request fails silently, flow is nil, caller gets no feedback. | Log error. |
| S10 | `PlayerState.swift:896` | **FFprobe not found — silent nil** — `findFFprobe()` returns nil, `inspectDuration` returns nil, caller treats duration as unknown. | Show user-facing warning. |

### 🔴 Critical — Dead Code (~1,050 lines)

| # | File | Lines | Problem | Fix |
|---|------|-------|---------|-----|
| D1 | `VideoInterpolationPipeline.swift` | 392 | **Entire actor never instantiated** — `VideoInterpolationPipeline(` appears nowhere. Only `InterpolationMode` enum is used. | Remove file (extract `InterpolationMode` to `PlayerTypes.swift`). |
| D2 | `PlaceboRenderer.swift` | 161 | **Entire file only referenced by dead pipeline** — `PlaceboRenderer(` appears nowhere. | Remove file. |
| D3 | `VideoDecoderEngine.swift` | 237 | **Entire actor only referenced by dead pipeline** — only instantiated at `VideoInterpolationPipeline.swift:83` (itself dead). Extract `MediaTrack`/`HDRMetadata` structs first. | Remove file after extracting types. |
| D4 | `RiftPlayerView.swift:571-690` | 120 | **`drawFramePlus` — never called** — full Metal frame rendering pipeline, replaced by normall `drawFrame` → `image()` path. | Remove method. |
| D5 | `LiquidGlassButton.swift` | 140 | **`LiquidGlassButton` — never instantiated** — view struct defined but zero callers. | Remove file. |
| D6 | `RiftPlayerView.swift:830-838` | 9 | **`copyFrame` — private helper never called** | Remove method. |
| D7 | `RiftPlayerView.swift:840-852` | 13 | **`makeTexture(from:)` — private helper never called** (`FramePlusMEMCEngine` has its own). | Remove method. |
| D8 | `LiquidGlassPanel.swift:32-56` | 25 | **`GlassCapsule` — declared, never used** | Remove struct. |
| **Total** | | **~1,097** | | |

### 🟡 High — Dead or Redundant Resources

| # | File:Line | Problem | Fix |
|---|-----------|---------|-----|
| DR1 | `Sources/Rift/Resources/rift-logo.pdf` | **Unreferenced duplicate** — SVG and PNG are used, PDF is dead weight. | Remove file. |
| DR2 | `RiftApp.swift:99` | **`setApplicationIcon()` loads `icon.png` which doesn't exist** — always fails silently. Icon works via `Rift.icns` + Info.plist. | Remove dead `setApplicationIcon()` call. |
| DR3 | `Sources/Rift/Resources/.keep` | **Empty placeholder — unnecessary** (directory has real files). | Remove file. |
| DR4 | `PlayerControlsView.swift:8-9` | **`isSeekingPreview`/`previewTime` — states never set to `true`** — conditional view at line 88 is dead. | Remove dead states and conditional block. |
| DR5 | `RIFECoreMLInterpolator.swift:45-47` | **`init()` async throws — never called** — all callers use `RIFECoreMLInterpolator()` then `loadEngine()`. | Remove dead init. |

### 🟢 Medium — Bundle & Build Issues

| # | File:Line | Problem | Fix |
|---|-----------|---------|-----|
| B1 | `scripts/build-release.sh` | **No `ffmpeg` binary bundled** — app requires ffmpeg at runtime but doesn't include it. | Bundle `ffmpeg` in Resources or document requirement. |
| B2 | `Package.swift:19` | **`FramePlusMEMC.metal` as `.copy` resource** — compiled at runtime from source instead of pre-compiled to metallib. Fragile. | Pre-compile to `.metallib` or use `.process`. |

---

## Summary

| Category | Count |
|----------|:-----:|
| 🔴 Critical — Silent Failures | 10 |
| 🔴 Critical — Dead Code (~1,097 lines) | 8 |
| 🟡 High — Dead/Redundant Resources | 5 |
| 🟢 Medium — Bundle Issues | 2 |
| **Total** | **25** |

**Top priorities:**
1. **Dead code removal**: Delete ~1,097 lines (26% of Swift codebase) — `VideoInterpolationPipeline`, `PlaceboRenderer`, `VideoDecoderEngine`, `LiquidGlassButton`, `drawFramePlus`, `copyFrame`, `makeTexture`
2. **Silent failures**: Fix the 10 catch/guard blocks that swallow errors without user feedback (same pattern as the Frame+ bundle bug)
3. **RIFE engine**: Fix `loadEngine()` to actually throw on failure so caller can surface the error
4. **HLS playlist**: Stop ignoring write failures — stale playlist = broken streaming
