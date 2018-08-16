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

    /*
     TODO:
      - check if the user has a valid payment source
     */
    func start(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.content.decode(Session.StartRequest.self).flatMap() { startRequest in
            return User.query(on: req)
                       .join(\Plate.userID, to: \User.id)
                       .filter(\Plate.value == startRequest.plate)
                       .first()
                       .flatMap() { potentialUser in

                            guard let user = potentialUser else {
                                throw Abort(.noContent, reason: "User doesn't exist")
                            }
                            guard let id = user.id else {
                                throw Abort(.internalServerError, reason: "Expected User with ID")
                            }
                            let newSession = Session(userID: id, lotID: startRequest.lotID, entryTimestamp: startRequest.timestamp)
                            return newSession.create(on: req).map { _ in
                                return HTTPStatus.created
                            }

            }
        }
    }

    func stop(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.content.decode(Session.EndRequest.self).flatMap() { endRequest in
            return User.query(on: req)
                .join(\Plate.userID, to: \User.id)
                .filter(\Plate.value == endRequest.plate)
                .first()
                .flatMap() { user in

                    guard let user = user else {
                        throw Abort(.noContent, reason: "User doesn't exist")
                    }
                    return try user.sessions.query(on: req).filter(\Session.isActive == true).first().flatMap() { session in
                        guard let session = session else {
                            throw Abort(.noContent, reason: "Session doesn't exist")
                        }
                        session.exitTimestamp = endRequest.timestamp
                        return session.save(on: req).flatMap() { session in
                            let amount = 1234
                            let stripe = try req.make(StripeClient.self)

                            return try stripe.charge.create(amount: amount, currency: .usd, description: "TODO", customer: "124asdf").map() { charge in
                                /*

                                 For the future:

                                  - charge.description -> "useful for displaying to users"
                                  - failure_code
                                  - failure_message
                                  - outcome -> "Details about whether the payment was accepted, and why."

                                 */
                                return HTTPStatus.created
                            }
                        }
                    }

            }
        }
    }

}
