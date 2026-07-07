// Generates a Liquid Glass DMG background matching the app's aesthetic
// Usage: swift -F /Library/Frameworks scripts/gen-dmg-bg.swift [output.png]

import AppKit
import Foundation

let output = CommandLine.arguments.dropFirst().first ?? "scripts/dmg-background.png"
let w: CGFloat = 720
let h: CGFloat = 420
let scale: CGFloat = 1
let size = NSSize(width: w, height: h)
let image = NSImage(size: size)

image.lockFocus()

let rect = NSRect(origin: .zero, size: size)
let ctx = NSGraphicsContext.current!.cgContext

// ── Dark base ──
let baseGradient = NSGradient(
    colors: [
        NSColor(calibratedRed: 0.02, green: 0.04, blue: 0.10, alpha: 1.0),
        NSColor(calibratedRed: 0.04, green: 0.08, blue: 0.18, alpha: 1.0),
        NSColor(calibratedRed: 0.01, green: 0.02, blue: 0.06, alpha: 1.0),
    ]
)!
baseGradient.draw(in: rect, angle: -18)

// ── Subtle vignette ──
let vignette = NSGradient(
    colors: [
        NSColor(calibratedRed: 0.08, green: 0.14, blue: 0.30, alpha: 0.12),
        NSColor.clear,
        NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 0.30),
    ]
)!
vignette.draw(in: rect, angle: 45)

// ── Glass panel simulated (center area with light frost) ──
let glassRect = NSRect(x: w * 0.12, y: h * 0.22, width: w * 0.76, height: h * 0.56)
let glassPath = NSBezierPath(roundedRect: glassRect, xRadius: 18 * scale, yRadius: 18 * scale)

ctx.saveGState()
glassPath.addClip()

// Frosted glass gradient
let glassGradient = NSGradient(
    colors: [
        NSColor(calibratedWhite: 1.0, alpha: 0.07),
        NSColor(calibratedWhite: 1.0, alpha: 0.03),
        NSColor(calibratedWhite: 1.0, alpha: 0.06),
    ]
)!
glassGradient.draw(in: glassRect, angle: 90)

// Subtle white border at top
NSColor(calibratedWhite: 1.0, alpha: 0.12).setStroke()
let topBorder = NSBezierPath()
topBorder.move(to: NSPoint(x: glassRect.minX + 12 * scale, y: glassRect.maxY - 1))
topBorder.line(to: NSPoint(x: glassRect.maxX - 12 * scale, y: glassRect.maxY - 1))
topBorder.lineWidth = 1 * scale
topBorder.stroke()

ctx.restoreGState()

// Glass border stroke
NSColor(calibratedWhite: 1.0, alpha: 0.15).setStroke()
glassPath.lineWidth = 1 * scale
glassPath.stroke()

// ── Rift logo text ──
func drawText(_ text: String, at point: NSPoint, size fontSize: CGFloat, weight: NSFont.Weight, alpha: CGFloat) {
    let p = NSMutableParagraphStyle()
    p.alignment = .center
    let attrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: fontSize * scale, weight: weight),
        .foregroundColor: NSColor(calibratedRed: 0.75, green: 0.85, blue: 0.98, alpha: alpha),
        .paragraphStyle: p,
        .kern: 3 * scale,
    ]
    let textRect = NSRect(x: point.x, y: point.y, width: w - point.x * 2, height: (fontSize + 8) * scale)
    (text as NSString).draw(in: textRect, withAttributes: attrs)
}

drawText("RIFT", at: NSPoint(x: 0, y: h - 70 * scale), size: 28, weight: .bold, alpha: 0.92)
drawText("Arrastra la app a Aplicaciones", at: NSPoint(x: 0, y: h - 108 * scale), size: 16, weight: .medium, alpha: 0.72)
drawText("para instalar Rift en tu Mac", at: NSPoint(x: 0, y: h - 130 * scale), size: 12, weight: .regular, alpha: 0.44)

// ── Installation guide arrow (inside glass panel) ──
let arrowY = h * 0.50
let arrowStartX = w * 0.20
let arrowEndX = w * 0.80
NSColor(calibratedRed: 0.40, green: 0.65, blue: 1.0, alpha: 0.20).setStroke()

let guide = NSBezierPath()
guide.move(to: NSPoint(x: arrowStartX, y: arrowY))
guide.line(to: NSPoint(x: arrowEndX, y: arrowY))
guide.lineWidth = 1.5 * scale
let dash: [CGFloat] = [6 * scale, 7 * scale]
guide.setLineDash(dash, count: 2, phase: 0)
guide.stroke()

let arrow = NSBezierPath()
let arrowTip = arrowEndX - 4 * scale
arrow.move(to: NSPoint(x: arrowTip, y: arrowY + 8 * scale))
arrow.line(to: NSPoint(x: arrowEndX, y: arrowY))
arrow.line(to: NSPoint(x: arrowTip, y: arrowY - 8 * scale))
arrow.lineWidth = 1.5 * scale
arrow.stroke()

// ── App icon placeholder (subtle glow where icon sits) ──
let iconX: CGFloat = w * 0.23
let iconY: CGFloat = h * 0.46
let glow = NSGradient(
    colors: [
        NSColor(calibratedRed: 0.20, green: 0.45, blue: 0.95, alpha: 0.10),
        NSColor.clear,
    ]
)!
glow.draw(in: NSRect(x: iconX - 32 * scale, y: iconY - 32 * scale, width: 64 * scale, height: 64 * scale), angle: 0)

// ── Applications folder glow ──
let appsX: CGFloat = w * 0.70
glow.draw(in: NSRect(x: appsX - 32 * scale, y: iconY - 32 * scale, width: 64 * scale, height: 64 * scale), angle: 0)

image.unlockFocus()

guard
    let tiff = image.tiffRepresentation,
    let bitmap = NSBitmapImageRep(data: tiff),
    let png = bitmap.representation(using: .png, properties: [.interlaced: false])
else {
    fputs("Error: could not generate background image\n", stderr)
    exit(1)
}

try png.write(to: URL(fileURLWithPath: output))
print("Generated: \(output) (\(png.count / 1024) KB)")
