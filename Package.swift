// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "PomoFlow",
    platforms: [
        .macOS(.v14),
    ],
    dependencies: [
        .package(url: "https://github.com/sindresorhus/KeyboardShortcuts", from: "2.2.2")
    ],
    targets: [
        .executableTarget(
            name: "PomoFlow",
            dependencies: [
                .product(name: "KeyboardShortcuts", package: "KeyboardShortcuts")
            ],
            path: "Sources/PomoFlow",
            resources: [
                .process("Resources"),
            ])
    ]
)
