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
    targets: [
        .executableTarget(
            name: "marker"
        ),
        .testTarget(
            name: "markerTests",
            dependencies: ["marker"]
        ),
    ]
)
