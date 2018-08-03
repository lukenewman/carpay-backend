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

    var plates: [String]

    var stripeCustomerID: String

    init(email: String, password: String, plate: String, stripeCustomerID: String) {
        self.email = email
        self.password = password
        self.plates = [plate]
        self.stripeCustomerID = stripeCustomerID
    }

}

extension User: Migration { }   // allows dynamic migration
extension User: Content { }     // allows HTTP message coding / decoding
extension User: Parameter { }   // allows parameterization in route defs

struct UserRequest: Content {
    var email: String
    var password: String
    var plate: String
    var stripeToken: String
}
