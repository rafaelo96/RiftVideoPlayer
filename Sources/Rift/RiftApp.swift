import SwiftUI
import AppKit

extension Notification.Name {
    static let riftOpenURLs = Notification.Name("RiftOpenURLs")
}

@main
struct RiftApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup("Rift") {
            ContentView()
                .frame(minWidth: 780, minHeight: 480)
                .onAppear {
                    AppDelegate.bringPlayerWindowToFront()
                }
        }
        .windowResizability(.contentMinSize)
        .commands {
            CommandGroup(replacing: .newItem) { }
        }
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private static var pendingOpenURLs: [URL] = []
    private static var fallbackWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        Self.setApplicationIcon()
        Self.bringPlayerWindowToFront()
        Self.createFallbackWindowIfNeeded()
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        Self.enqueueOpenURLs(urls)
        Self.bringPlayerWindowToFront()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }

    @MainActor
    static func takePendingOpenURLs() -> [URL] {
        defer { pendingOpenURLs.removeAll() }
        return pendingOpenURLs
    }

    @MainActor
    private static func enqueueOpenURLs(_ urls: [URL]) {
        pendingOpenURLs.append(contentsOf: urls)
        NotificationCenter.default.post(name: .riftOpenURLs, object: nil, userInfo: ["urls": urls])
    }

    @MainActor
    static func setApplicationIcon() {
        if let url = Bundle.main.url(forResource: "icon", withExtension: "png"),
           let image = NSImage(contentsOf: url) {
            NSApp.applicationIconImage = image
        }
    }

    @MainActor
    static func bringPlayerWindowToFront() {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            NSApp.windows.first?.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    @MainActor
    private static func createFallbackWindowIfNeeded() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            guard NSApp.windows.isEmpty, fallbackWindow == nil else { return }

            let rootView = ContentView()
                .frame(minWidth: 780, minHeight: 480)
            let hostingController = NSHostingController(rootView: rootView)
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 1120, height: 680),
                styleMask: [.titled, .closable, .miniaturizable, .resizable],
                backing: .buffered,
                defer: false
            )
            window.title = "Rift"
            window.contentViewController = hostingController
            window.center()
            window.makeKeyAndOrderFront(nil)
            fallbackWindow = window
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
