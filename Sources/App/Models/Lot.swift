//
//  Lot.swift
//  App
//
//  Created by Luke Newman on 9/1/18.
//

import Vapor
import Fluent
import FluentPostgreSQL

final class Lot: Content, PostgreSQLModel {
    var id: Int?

    var name: String?

//    var rates: ???

    init(name: String) {
        self.name = name
    }
}

extension Lot {
    func calculateCharge(for session: Session) -> Int {
        // TODO
        return 1234
    }
}
