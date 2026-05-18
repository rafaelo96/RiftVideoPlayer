// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "VideoPlayerUI",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "VideoPlayerUI",
            path: "Sources/VideoPlayerUI"
        )
    ]
)
