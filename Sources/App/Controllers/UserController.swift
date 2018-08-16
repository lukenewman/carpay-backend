//
//  UserController.swift
//  App
//
//  Created by Luke Newman on 7/14/18.
//

import Vapor
import Stripe

final class UserController {

    func index(_ req: Request) throws -> Future<[User]> {
        return User.query(on: req).all()
    }

    func plates(_ req: Request) throws -> Future<[Plate]> {
        return try req.content.decode(User.PlatesRequest.self).flatMap { platesRequest in
            return User.find(platesRequest.userID, on: req).unwrap(or: Abort(.notFound, reason: "No User with id \(platesRequest.userID)")).flatMap { user in
                return try user.plates.query(on: req).all()
            }
        }
    }

    func create(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.content.decode(User.CreateRequest.self).flatMap { userRequest in
            let stripeClient = try req.make(StripeClient.self)
            return try stripeClient.customer.create(email: userRequest.email, source: userRequest.stripeToken).flatMap() { stripeCustomer in
                let newUser = User(email: userRequest.email,
                                   password: userRequest.password,
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

}
