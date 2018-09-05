//
//  Session.swift
//  App
//
//  Created by Luke Newman on 7/16/18.
//

import Vapor
import Fluent
import FluentPostgreSQL

final class Session: Content, PostgreSQLModel, Migration {
    var id: Int?

    var userID: User.ID

    var lotID: Int

    var entryTimestamp: Date
    var exitTimestamp: Date?

    init(userID: User.ID, lotID: Int, entryTimestamp: Date) {
        self.userID = userID
        self.lotID = lotID
        self.entryTimestamp = entryTimestamp
    }

    var user: Parent<Session, User> {
        return parent(\.userID)
    }

    struct Request: Content {
        var lotID: Int
        var plate: String
        var timestamp: Date
    }
}

extension Session {
    func calculateCharge() -> Int {
        // TODO - get lot and calculate with that
        return 1234
    }
}
