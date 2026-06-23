import OSLog

extension Logger {
    static let playback = Logger(subsystem: "com.rift.player", category: "playback")
    static let ui = Logger(subsystem: "com.rift.player", category: "ui")
    static let conversion = Logger(subsystem: "com.rift.player", category: "conversion")
    static let rendering = Logger(subsystem: "com.rift.player", category: "rendering")
    static let engine = Logger(subsystem: "com.rift.player", category: "engine")
    static let lifecycle = Logger(subsystem: "com.rift.player", category: "lifecycle")
}
