import SwiftUI
import AppKit

@main
struct LiquidPlayerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    init() {
        LiquidPlayerApp.writeLaunchLog("LiquidPlayerApp init args=\(CommandLine.arguments.joined(separator: " "))")
    }

    var body: some Scene {
        // Hidden title bar lets the custom liquid top bar become the visible window chrome.
        WindowGroup("Liquid Player") {
            if CommandLine.arguments.count > 1 {
                EmptyView()
                    .frame(width: 1, height: 1)
            } else {
                ContentView()
                    .frame(minWidth: 780, minHeight: 480)
            }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentMinSize)
        .commands {
            CommandGroup(replacing: .newItem) { }
        }
    }

    private static func writeLaunchLog(_ message: String) {
        let url = URL(fileURLWithPath: "/private/tmp/LiquidPlayer-launch.log")
        let line = "[\(Date())] \(message)\n"
        try? line.write(to: url, atomically: true, encoding: .utf8)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var diagnosticWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)

        guard CommandLine.arguments.count > 1 else { return }

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1200, height: 720),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Liquid Player"
        window.center()
        window.contentView = NSHostingView(rootView: ContentView())
        window.makeKeyAndOrderFront(nil)
        diagnosticWindow = window
    }
}
