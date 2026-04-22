// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "SuperRight",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(name: "Shared", targets: ["Shared"]),
        .library(name: "ExtensionCore", targets: ["ExtensionCore"]),
        .library(name: "AppCore", targets: ["AppCore"]),
        .executable(name: "RuntimeVerifier", targets: ["RuntimeVerifier"])
    ],
    targets: [
        .target(
            name: "Shared",
            path: "Shared"
        ),
        .target(
            name: "ExtensionCore",
            dependencies: ["Shared"],
            path: "Extension"
        ),
        .target(
            name: "AppCore",
            dependencies: ["Shared"],
            path: "App"
        ),
        .executableTarget(
            name: "RuntimeVerifier",
            dependencies: ["Shared", "ExtensionCore", "AppCore"],
            path: "Tools/RuntimeVerifier"
        ),
        .testTarget(
            name: "SuperRightTests",
            dependencies: ["Shared", "ExtensionCore", "AppCore"],
            path: "Tests/UnitTests"
        )
    ]
)
