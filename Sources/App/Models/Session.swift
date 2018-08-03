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

    var plate: String

    var lotID: Int

    var entryTimestamp: Date
    var exitTimestamp: Date?

    var isActive: Bool {
        return exitTimestamp == nil
    }

    init(plate: String, lotID: Int, entryTimestamp: Date) {
        self.plate = plate
        self.lotID = lotID
        self.entryTimestamp = entryTimestamp
    }
}

extension Session: Migration { }
extension Session: Content { }
extension Session: Parameter { }

struct SessionStartRequest: Content {
    var lotID: Int
    var plate: String
    var timestamp: Date
}

struct SessionEndRequest: Content {
    var lotID: Int
    var plate: String
    var timestamp: Date
}
