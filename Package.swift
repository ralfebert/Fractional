// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Fractional",
    products: [ .library(name: "Fractional", targets: ["Fractional"]) ],
    targets: [
        .target(name: "Fractional", dependencies: []),
        .testTarget(name: "FractionalTests", dependencies: ["Fractional"])
    ]

)
