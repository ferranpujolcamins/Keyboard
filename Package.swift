// swift-tools-version: 5.5

import PackageDescription

let package = Package(
    name: "Keyboard",
    platforms: [ .macOS(.v12), .iOS(.v15)],
    products: [.library(name: "Keyboard", targets: ["Keyboard"])],
    dependencies: [.package(url: "https://github.com/ferranpujolcamins/Tonic.git", .exact("1.0.1"))],
    targets: [
        .target(name: "Keyboard", dependencies: ["Tonic"]),
        .testTarget(name: "KeyboardTests", dependencies: ["Keyboard"]),
    ]
)
