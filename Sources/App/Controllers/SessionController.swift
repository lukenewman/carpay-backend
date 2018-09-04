//
//  SessionController.swift
//  App
//
//  Created by Luke Newman on 7/14/18.
//

import Vapor
import Fluent
import Stripe

final class SessionController: RouteCollection {

    func boot(router: Router) throws {
        router.get("sessions", use: list)
        router.get("active_sessions", use: listActive)
        router.get("inactive_sessions", use: listInactive)
        router.post("start", use: start)
        router.post("stop", use: stop)

//        let basicAuthMiddleware = User.basicAuthMiddleware(using: BCryptDigest())
//        let guardAuthMiddleware = User.guardAuthMiddleware()
//        let protected = router.grouped(basicAuthMiddleware, guardAuthMiddleware)
//        protected.get("sessions", use: list)
    }

    func list(_ req: Request) throws -> Future<[Session]> {
        return Session.query(on: req).all()
    }

    func listActive(_ req: Request) throws -> Future<[Session]> {
        return Session.query(on: req).filter(\.state == .active).all()
    }

    func listInactive(_ req: Request) throws -> Future<[Session]> {
        return Session.query(on: req).filter(\.state == .finished).all()
    }

    /*
     TODO:
      - check if the user has a valid payment source
     */
    func start(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.content.decode(Session.Request.self).flatMap() { startRequest in
            return User.query(on: req)
                       .join(\Plate.userID, to: \User.id)
                       .filter(\Plate.value == startRequest.plate)
                       .first()
                       .flatMap() { potentialUser in

                            guard let user = potentialUser else {
                                throw Abort(.forbidden, reason: "User doesn't exist")
                            }
                            guard let id = user.id else {
                                throw Abort(.internalServerError, reason: "Expected User with ID")
                            }
                            let newSession = Session(userID: id, lotID: startRequest.lotID, entryTimestamp: startRequest.timestamp)
                            return newSession.create(on: req).map { session in
                                return HTTPStatus.created
                            }

            }
        }
    }

    func stop(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.content.decode(Session.Request.self).flatMap() { endRequest in
            return User.query(on: req)
                .join(\Plate.userID, to: \User.id)
                .filter(\Plate.value == endRequest.plate)
                .first()
                .flatMap() { user in

                    guard let user = user else {
                        throw Abort(.forbidden, reason: "User doesn't exist")
                    }

                    return try user.sessions.query(on: req).filter(\Session.state == .finished).first().flatMap() { session in
                        guard let session = session else {
                            throw Abort(.forbidden, reason: "Session doesn't exist")
                        }
                        session.exitTimestamp = endRequest.timestamp
                        return session.save(on: req).flatMap() { session in
                            let amount = session.calculateCharge()
                            let stripe = try req.make(StripeClient.self)

                            return try stripe.charge.create(amount: amount, currency: .usd, description: "TESTING", customer: user.stripeCustomerID).map() { charge in
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
