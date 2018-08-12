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

    func list(_ req: Request) throws -> Future<[Session]> {
        return Session.query(on: req).all()
    }

    func start(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.content.decode(Session.StartRequest.self).flatMap(to: HTTPStatus.self) { startRequest in

            // TODO: Find user with startRequest.plate
//            User.query(on: req).filter(\User.plates, in: [sessionStartRequest.plate])
//            return User.find(sessionStartRequest.plate, on: req).unwrap(or: Abort(HTTPStatus.badRequest, reason: "Invalid plate.")).flatMap(to: HTTPStatus.self) { user in

            let newSession = Session(userID: 1, plate: startRequest.plate, lotID: startRequest.lotID, entryTimestamp: startRequest.timestamp)
            return newSession.create(on: req).map { _ in
                return HTTPStatus.created
            }
        }
    }

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
