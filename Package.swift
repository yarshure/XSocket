// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "XSocket",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
    ],
    products: [
        .library(
            name: "XSocket",
            targets: ["XSocket"]
        ),
        .executable(
            name: "xsocket-test",
            targets: ["xsocket-test"]
        ),
    ],
    dependencies: [
        .package(path: "../AxLogger/AxLogger"),
        .package(path: "../CocoaAsyncSocket"),
    ],
    targets: [
        .target(
            name: "XSocket",
            dependencies: [
                .product(name: "AxLogger", package: "AxLogger"),
                .product(name: "CocoaAsyncSocket", package: "CocoaAsyncSocket"),
            ],
            path: "XSocket",
            exclude: [
                "Info.plist",
                "XSocket.h",
                "ios.xcconfig",
            ]
        ),
        .executableTarget(
            name: "xsocket-test",
            dependencies: ["XSocket"],
            path: "test"
        ),
    ]
)
