// swift-tools-version:6.1
import PackageDescription

let package = Package(
    name: "sql-kit-extras",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .watchOS(.v6),
        .tvOS(.v13),
        .visionOS(.v1),
    ],
    products: [
        .library(name: "SQLKitExtras", targets: ["SQLKitExtras"]),
        .library(name: "FluentKitExtras", targets: ["FluentKitExtras"]),
    ],
    traits: [
        .trait(
            name: "FluentSQLKitExtras",
            description: "Enable additional utilities for working with Fluent models from SQLKit contexts.",
            enabledTraits: []
        ),
        .trait(
            name: "PostgreSQLKitExtras",
            description: "Enable additional expressions and builders for PostgreSQL-specific syntax.",
            enabledTraits: []
        ),
        .default(enabledTraits: [
            "FluentSQLKitExtras",
        ]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-algorithms.git", from: "1.2.1"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.97.1"),
        .package(url: "https://github.com/vapor/fluent-kit.git", from: "1.56.0"),
        .package(url: "https://github.com/vapor/sql-kit.git", from: "3.35.0"),
    ],
    targets: [
        .target(
            name: "SQLKitExtras",
            dependencies: [
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "FluentKit", package: "fluent-kit", condition: .when(traits: ["FluentSQLKitExtras"])),
                .product(name: "SQLKit", package: "sql-kit"),
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "FluentKitExtras",
            dependencies: [
                .product(name: "FluentKit", package: "fluent-kit"),
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "SQLKitExtrasTests",
            dependencies: [
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOEmbedded", package: "swift-nio"),
                .target(name: "SQLKitExtras"),
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "FluentKitExtrasTests",
            dependencies: [
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOEmbedded", package: "swift-nio"),
                .target(name: "FluentKitExtras"),
            ],
            swiftSettings: swiftSettings
        ),
    ]
)

var swiftSettings: [SwiftSetting] { [
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("InternalImportsByDefault"),
    .enableUpcomingFeature("MemberImportVisibility"),
    .enableUpcomingFeature("InferIsolatedConformances"),
    //.enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    .enableUpcomingFeature("ImmutableWeakCaptures"),
] }
