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
            name: "Marker"
        ),
        .testTarget(
            name: "MarkerTests",
            dependencies: [
                .target(name: "Marker"),
                .product(name: "Testing", package: "swift-testing"),
            ]
        ),
    ]
)
