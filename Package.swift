// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "WageBar",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "WageBar", targets: ["WageBar"])
    ],
    targets: [
        .executableTarget(
            name: "WageBar",
            path: "Sources"
        )
    ]
)
