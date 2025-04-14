// swift-tools-version:6.1
import PackageDescription

let package = Package(
    name: "SQLKitExtras",
    platforms: [
        .macOS(.v13),
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
        .package(url: "https://github.com/apple/swift-algorithms.git", from: "1.2.0"),
        .package(url: "https://github.com/vapor/fluent-kit.git", from: "1.51.0"),
        .package(url: "https://github.com/vapor/sql-kit.git", from: "3.32.0"),
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
                .target(name: "SQLKitExtras"),
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "FluentKitExtrasTests",
            dependencies: [
                .target(name: "FluentKitExtras"),
            ],
            swiftSettings: swiftSettings
        ),
    ]
)

var swiftSettings: [SwiftSetting] { [
  .enableUpcomingFeature("ExistentialAny"),
  .enableUpcomingFeature("MemberImportVisibility"),
] }
