// swift-tools-version:5.4.0

import PackageDescription

let package = Package(
    name: "HPParallaxHeader",
    platforms: [ .iOS(.v10)],
    products: [
        .library(
            name: "HPParallaxHeader",
            targets: ["HPParallaxHeader"]),
    ],
    dependencies: [
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "HPParallaxHeader",
            dependencies: [],
            path: "HPParallaxHeader/Classes",
            publicHeadersPath: ".")
    ]
)