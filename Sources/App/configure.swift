import FluentMySQL
import Vapor

public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
) throws {
    // Register providers
    try services.register(FluentMySQLProvider())

    // Register router and routes
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Register MySQL database
    let database = MySQLDatabase(
        hostname: "localhost",
        user: "root",
        password: "{ypru3oaKJWsvjadxcxwJU8XZVuWzatWTQrk3DaKP2atQ3npn?",
        database: "vapor-3-test"
    )
    var databases = DatabaseConfig()
    databases.add(database: database, as: .mysql)
    services.register(databases, as: DatabaseConfig.self)

    // Register migrations
    var migrations = MigrationConfig()
    migrations.add(model: Post.self, database: .mysql)
    services.register(migrations)
}
