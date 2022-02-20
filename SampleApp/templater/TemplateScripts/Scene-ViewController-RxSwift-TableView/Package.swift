// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Scene-ViewController-RxSwift-TableView",
    platforms: [
        .macOS(.v10_15)
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "codeTemplater", url: "https://github.com/strvcom/ios-code-templates.git", .branch("feature/basic-functionality"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Scene-ViewController-RxSwift-TableView",
            dependencies: ["codeTemplater"]
        ),
        .testTarget(
            name: "Scene-ViewController-RxSwift-TableViewTests",
            dependencies: ["Scene-ViewController-RxSwift-TableView"]
        )
    ]
)
