
import Vapor
import FluentPostgreSQL
import Stripe
import Authentication

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(FluentPostgreSQLProvider())
    if let prodStripeKey = Environment.get("STRIPE_SECRET_KEY_PROD") {
        services.register(StripeConfig(apiKey: prodStripeKey))
    } else {
        services.register(StripeConfig(apiKey: "sk_test_OrVZR4UOWHvgDEaCgSE0nPLc"))
    }
    try services.register(StripeProvider())

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    /// Configure PostgreSQL database
    var postgreConfig: PostgreSQLDatabaseConfig? = nil
    if let url = Environment.get("DATABASE_URL") {
        postgreConfig = PostgreSQLDatabaseConfig(url: url)
    }
    if postgreConfig == nil {
        postgreConfig = PostgreSQLDatabaseConfig(hostname: "localhost", port: 5432, username: "luke", database: "carpay-testing", transport: .cleartext)
    }
    guard let config = postgreConfig else {
        preconditionFailure("Expected to have a valid postgreConfig")
    }
    services.register(config)

    var dbs = DatabasesConfig()
    dbs.add(database: PostgreSQLDatabase.self, as: .psql)
    dbs.enableLogging(on: .psql)
    services.register(dbs)

    /// Configure authentication
    try services.register(AuthenticationProvider())

    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: User.self, database: .psql)
    migrations.add(model: Plate.self, database: .psql)
    migrations.add(model: Session.self, database: .psql)
    migrations.add(model: Token.self, database: .psql)
    services.register(migrations)
}
