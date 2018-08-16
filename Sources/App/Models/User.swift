//
//  User.swift
//  App
//
//  Created by Luke Newman on 7/14/18.
//

import FluentPostgreSQL
import Fluent
import Vapor

final class User: PostgreSQLModel {
    var id: Int?

    var email: String
    var password: String

    var stripeCustomerID: String

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

    struct PlatesRequest: Content {
        var userID: Int
    }
}

extension User: Migration { }   // allows dynamic migration
extension User: Content { }     // allows HTTP message coding / decoding
extension User: Parameter { }   // allows parameterization in route defs
