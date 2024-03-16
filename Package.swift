// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "marker",
    products: [
        .executable(
            name: "marker",
            targets: ["marker"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-testing.git", branch: "main"),
    ],
    targets: [
        .executableTarget(
            name: "marker"
        ),
        .testTarget(
            name: "markerTests",
            dependencies: [
                .target(name: "marker"),
                .product(name: "Testing", package: "swift-testing"),
            ]
        ),
    ]
)
