// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GAuthSignin",
    platforms: [.iOS(.v13), .tvOS(.v13), .macOS(.v12)],
    products: [
        .library(
            name: "GAuthSignin",
            targets: ["GAuthSignin"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "GAuthSignin",
            dependencies: [],
            resources: [.process("Resources")]),
        .testTarget(
            name: "GAuthSigninTests",
            dependencies: ["GAuthSignin"]),
    ]
)
