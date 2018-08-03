// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "CarPay",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),

        // 🐘 Swift ORM (queries, models, relations, etc) built on Postgresql.
        .package(url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0"),

        // 💸 Stripe provider for billing.
        .package(url: "https://github.com/vapor-community/stripe-provider.git", from: "2.1.2"),
    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "FluentPostgreSQL", "Stripe"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

