// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Marker",
    platforms: [.macOS(.v10_15)],
    products: [
        .executable(
            name: "Marker",
            targets: ["Marker"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.0"),
    ],
    targets: [
        .executableTarget(
            name: "Marker",
            dependencies: [
                .target(name: "DotMd"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            path: "Cli"
        ),
        .target(
            name: "DotMd",
            path: "Markdown"
        ),
        .testTarget(
            name: "DotMdTests",
            dependencies: [
                .target(name: "DotMd"),
            ],
            path: "Tests/MarkdownTests"
        ),
    ]
)
