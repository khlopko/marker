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
    ],
    targets: [
        .executableTarget(
            name: "Marker",
            dependencies: [
                .target(name: "DotMd"),
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
