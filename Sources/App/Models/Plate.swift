//
//  Plate.swift
//  App
//
//  Created by Luke Newman on 8/13/18.
//

import FluentPostgreSQL
import Fluent
import Vapor

final class Plate: PostgreSQLModel {
    var id: Int?

    var userID: Int

    var value: String

    init(userID: Int, value: String) {
        self.userID = userID
        self.value = value
    }

    var user: Parent<Plate, User> {
        return parent(\.userID)
    }
}
