//
//  Session.swift
//  App
//
//  Created by Luke Newman on 7/16/18.
//

import FluentPostgreSQL
import Vapor

final class Session: PostgreSQLModel {
    var id: Int?

    var userID: Int

    var plate: String

    var lotID: Int

    var entryTimestamp: Date
    var exitTimestamp: Date?

    var isActive: Bool {
        return exitTimestamp == nil
    }

    init(userID: Int, plate: String, lotID: Int, entryTimestamp: Date) {
        self.userID = userID
        self.plate = plate
        self.lotID = lotID
        self.entryTimestamp = entryTimestamp
    }

    var user: Parent<Session, User> {
        return parent(\.userID)
    }

    struct StartRequest: Content {
        var lotID: Int
        var plate: String
        var timestamp: Date
    }

    struct EndRequest: Content {
        var lotID: Int
        var plate: String
        var timestamp: Date
    }
}

extension Session: Migration { }
extension Session: Content { }
extension Session: Parameter { }
