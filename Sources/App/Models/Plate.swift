//
//  Plate.swift
//  App
//
//  Created by Luke Newman on 8/13/18.
//

import FluentPostgreSQL
import Fluent
import Vapor

final class Plate: Content, PostgreSQLModel {
    var id: Int?

    var userID: User.ID

    var value: String

    init(userID: User.ID, value: String) {
        self.userID = userID
        self.value = value
    }

    var user: Parent<Plate, User> {
        return parent(\.userID)
    }
}

extension Plate: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.userID, to: \User.id)
        }
    }
}
