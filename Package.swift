// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "Marker",
    products: [
        .executable(
            name: "Marker",
            targets: ["Marker"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-testing.git", branch: "main"),
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
                .product(name: "Testing", package: "swift-testing"),
            ],
            path: "Tests/MarkdownTests"
        ),
    ]
)
