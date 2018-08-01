// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Redift",
    products: [
        .library(
            name: "Redift",
            targets: ["Redift"]),
	.library(
            name: "Redift-Router",
            targets: ["Redift"]),
    ],
    dependencies: [
        .package(url: "https://github.com/JustinGuedes/Prelude", from: "0.0.0")
    ],
    targets: [
        .target(
            name: "Redift",
            dependencies: ["Prelude"],
            path: "Sources"),
        .testTarget(
            name: "RediftTests",
            dependencies: ["Redift"],
            path: "Tests")
    ]
)
