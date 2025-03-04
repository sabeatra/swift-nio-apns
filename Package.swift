// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "nio-apns",
    products: [
        .executable(name: "NIOAPNSExample", targets: ["NIOAPNSExample"]),
        .library(name: "NIOAPNS", targets: ["NIOAPNS"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-nio-ssl.git", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-nio-http2.git", from: "1.0.0"),
    ],
    targets: [
        .systemLibrary(
            name: "CAPNSOpenSSL",
            pkgConfig: "openssl",
            providers: [
                .apt(["openssl libssl-dev"]),
                .brew(["openssl"]),
            ]
        ),

        .target(name: "NIOAPNSExample", dependencies: ["NIOAPNS"]),
        .testTarget(name: "NIOAPNSJWTTests", dependencies: ["NIOAPNS"]),
        .testTarget(name: "NIOAPNSTests", dependencies: ["NIOAPNS"]),
        .target(name: "NIOAPNS", dependencies: ["NIO",
                                                "NIOSSL",
                                                "NIOHTTP1",
                                                "NIOHTTP2",
                                                "NIOFoundationCompat",
                                                "CAPNSOpenSSL"]),
    ]
)
