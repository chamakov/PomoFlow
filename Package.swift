// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "TimeTracker",
    platforms: [
        .macOS(.v14),
    ],
    dependencies: [
        .package(url: "https://github.com/sindresorhus/KeyboardShortcuts", from: "2.2.2")
    ],
    targets: [
        .executableTarget(
            name: "TimeTracker",
            dependencies: [
                .product(name: "KeyboardShortcuts", package: "KeyboardShortcuts")
            ],
            path: "Sources/TimeTracker",
            resources: [
                .process("Resources"),
            ])
    ]
)
