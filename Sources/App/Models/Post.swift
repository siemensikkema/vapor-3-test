import FluentMySQL
import Vapor

final class Post: MySQLModel {
    var id: Int?
    var title: String
    var body: String

    init(id: Int? = nil, title: String, body: String) {
        self.id = id
        self.title = title
        self.body = body
    }
}

extension Post: Content {}

extension Post: Migration {
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return MySQLDatabase.create(self, on: connection) { builder in
            builder.field(type: Int.mysqlColumn, for: \.id, isIdentifier: true)
            try builder.field(for: \.title)
            builder.field(type: .varChar(length: 191), for: \.body)
        }
    }
}

extension Post: Parameter {}

extension Post {
    struct Partial: Content {
        var title: String?
        var body: String?
    }
}
