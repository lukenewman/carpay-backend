//
//  UserController.swift
//  App
//
//  Created by Luke Newman on 7/14/18.
//

import Vapor
import Stripe
import Crypto
import Authentication

final class UserController: RouteCollection {

    func boot(router: Router) throws {
//        let group = router.grouped("api", "users")
//        group.post(User.self, use: create)

        router.get("users", use: index)
        router.get("plates", use: plates)
        router.post("users", use: create)

        let basicAuthMiddleware = User.basicAuthMiddleware(using: BCryptDigest())
        let basicAuthGroup = router.grouped(basicAuthMiddleware)
        basicAuthGroup.post("login", use: login)
    }

    func index(_ req: Request) throws -> Future<[User.Public]> {
        return User.query(on: req).decode(data: User.Public.self).all()
    }

    func plates(_ req: Request) throws -> Future<[Plate]> {
        return try req.content.decode(User.PlatesRequest.self).flatMap { platesRequest in
            return User.find(platesRequest.userID, on: req).unwrap(or: Abort(.notFound, reason: "No User with id \(platesRequest.userID)")).flatMap { user in
                return try user.plates.query(on: req).all()
            }
        }
    }

    func sessions(_ req: Request) throws -> Future<[Session]> {
        let userID = try req.parameters.next(Int.self)
        return User.find(userID, on: req).unwrap(or: Abort(.notFound, reason: "No User with id \(userID)")).flatMap { user in
            return try user.sessions.query(on: req).all()
        }
    }

    func create(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.content.decode(User.CreateRequest.self).flatMap { userRequest in
            let stripeClient: StripeClient
            do {
                stripeClient = try req.make(StripeClient.self)
            } catch {
                throw Abort(.internalServerError, reason: "Unable to create StripeClient")
            }
            return try stripeClient.customer.create(email: userRequest.email, source: userRequest.stripeToken).flatMap() { stripeCustomer in
                let digest = try req.make(BCryptDigest.self)
                let hashedPassword = try digest.hash(userRequest.password)
                let newUser = User(email: userRequest.email,
                                   password: hashedPassword,
                                   stripeCustomerID: stripeCustomer.id)
                return newUser.save(on: req).flatMap { user in
                    guard let id = user.id else {
                        throw Abort(.internalServerError, reason: "Could not get ID from newly-saved User")
                    }
                    let newPlate = Plate(userID: id, value: userRequest.plate)
                    return newPlate.save(on: req).map { plate in
                        return .created
                    }
                }
            }
        }
    }

    func login(_ req: Request) throws -> Future<Token> {
        return try req.content.decode(User.LoginRequest.self).flatMap { loginRequest in
            return User.authenticate(using: .init(username: loginRequest.email, password: loginRequest.password), verifier: BCryptDigest(), on: req).flatMap { potentialUser in
                guard let loggedInUser = potentialUser else {
                    throw Abort(.notFound, reason: "No user with those credentials")
                }
                let token = try Token.generate(for: loggedInUser)
                return token.save(on: req)
            }
        }
    }

}
