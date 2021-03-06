// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "codetemplater",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .executable(name: "codetemplater", targets: ["codetemplater"]),
        .library(name: "CodeTemplaterFramework", targets: ["CodeTemplaterFramework"])
    ],
    dependencies: [
        .package(url: "https://github.com/JohnSundell/Files.git", from: "4.1.1"),
        .package(url: "https://github.com/kareman/Moderator.git", from: "0.5.1"),
        .package(url: "https://github.com/DanielCech/ScriptToolkit.git", .branch("master")),
        .package(url: "https://github.com/kareman/SwiftShell.git", from: "5.0.1"),
        .package(url: "https://github.com/kareman/FileSmith.git", from: "0.3.0"),
        .package(url: "https://github.com/stencilproject/Stencil.git", from: "0.13.0"),
        .package(url: "https://github.com/SwiftGen/StencilSwiftKit.git", from: "2.7.2"),
        .package(url: "https://github.com/DaveWoodCom/XCGLogger.git", from: "7.0.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "4.0.6")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "codetemplater",
            dependencies: ["Files", "Moderator", "ScriptToolkit", "SwiftShell", "FileSmith", "Stencil", "StencilSwiftKit", "XCGLogger", "CodeTemplaterFramework",    "Yams"]
        ),
        .target(
            name: "CodeTemplaterFramework",
            dependencies: ["Files", "Moderator", "ScriptToolkit", "SwiftShell", "FileSmith", "Stencil", "StencilSwiftKit", "XCGLogger", "Yams"]
        ),
        .testTarget(
            name: "codeTemplaterTests",
            dependencies: ["codetemplater"]
        )
    ]
)
