//
//  User.swift
//  App
//
//  Created by Luke Newman on 7/14/18.
//

import Vapor
import Fluent
import FluentPostgreSQL
import Authentication

final class User: Content, PostgreSQLModel {
    var id: Int?

    private(set) var email: String
    private(set) var password: String

    private(set) var stripeCustomerID: String

    init(email: String, password: String, stripeCustomerID: String) {
        self.email = email
        self.password = password
        self.stripeCustomerID = stripeCustomerID
    }

    var sessions: Children<User, Session> {
        return children(\.id)
    }

    var plates: Children<User, Plate> {
        return children(\.id)
    }

    struct CreateRequest: Content {
        var email: String
        var password: String
        var plate: String
        var stripeToken: String
    }

    struct LoginRequest: Content {
        var email: String
        var password: String
    }

    struct PlatesRequest: Content {
        var userID: Int
    }

    struct SessionsRequest: Content {
        var userID: Int
    }
}

extension User: BasicAuthenticatable {
    static let usernameKey: UsernameKey = \User.email
    static let passwordKey: PasswordKey = \User.password
}

extension User: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.unique(on: \.email)
        }
    }
}

// MARK: - Public

extension User {
    final class Public: Codable, Content {
        var id: Int?
        var email: String
        // todo: add plates and sessions

        init(id: Int?, email: String) {
            self.id = id
            self.email = email
        }
    }

    func convertToPublic() -> User.Public {
        return User.Public(id: id, email: email)
    }
}

extension Future where T: User {
    func convertToPublic() -> Future<User.Public> {
        return self.map(to: User.Public.self) { user in
            return user.convertToPublic()
        }
    }
}
