import SwiftUI

@main
struct LiquidPlayerApp: App {
    var body: some Scene {
        // Hidden title bar lets the custom liquid top bar become the visible window chrome.
        WindowGroup("Liquid Player") {
            ContentView()
                .frame(minWidth: 780, minHeight: 480)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentMinSize)
        .commands {
            CommandGroup(replacing: .newItem) { }
        }
    }
}
