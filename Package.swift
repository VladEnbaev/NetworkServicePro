// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NetworkServicePro",
    platforms: [.iOS(.v16), .macOS(.v10_15), .watchOS(.v6), .tvOS(.v13)],
    products: [
        .library(
            name: "NetworkServicePro",
            targets: ["NetworkServicePro"]),
    ],
    targets: [
        .target(
            name: "NetworkServicePro"),
        .testTarget(
            name: "NetworkServiceProTests",
            dependencies: ["NetworkServicePro"]),
    ]
)
