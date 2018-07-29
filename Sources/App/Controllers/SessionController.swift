//
//  SessionController.swift
//  App
//
//  Created by Luke Newman on 7/14/18.
//

import Vapor
import Fluent
import Stripe

final class SessionController {
    
//    func start(_ req: Request) throws -> Future<HTTPStatus> {
//        return try req.content.decode(SessionStartRequest.self).flatMap(to: HTTPStatus.self) { sessionStartRequest in
////            User.query(on: req).filter(\User.plates, in: [sessionStartRequest.plate])
//            return User.find(sessionStartRequest.plate, on: req).unwrap(or: Abort(HTTPStatus.badRequest, reason: "Invalid plate.")).flatMap(to: HTTPStatus.self) { user in
//                let newSession = Session(license: sessionStartRequest.plate, lotID: sessionStartRequest.lotID, entryTimestamp: sessionStartRequest.timestamp)
//                return newSession.create(on: req).map(to: HTTPStatus.self) { session in
//                    return HTTPStatus.ok
//                }
//            }
//        }
//    }
//
//
//    func stop(_ req: Request) throws -> Future<HTTPStatus> {
//        return try req.content.decode(SessionEndRequest.self).flatMap(to: HTTPStatus.self) { sessionEndRequest in
//            return Session.query(on: req).filter(\.plate == sessionEndRequest.plate).filter(\.isActive == true).all().flatMap(to: HTTPStatus.self) { sessions in
//
//                // Update the active session
//                let session = sessions[0]
//                session.exitTimestamp = sessionEndRequest.timestamp
//                session.save(on: req)
//
////                let user = User.find(session.plate, on: req)
//
//                let amount = session.exitTimestamp!.timeIntervalSince1970 - session.entryTimestamp.timeIntervalSince1970
//
//                let stripe = try req.make(StripeClient.self)
//                let futureCharge = try stripe.charge.create(amount: amount, currency: .usd, description: "TODO", customer: "1234asdf")
//            }
//        }
//    }

}
