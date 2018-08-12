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

    func create(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.content.decode(User.CreateRequest.self).flatMap { userRequest in
            let stripeClient = try req.make(StripeClient.self)
            return try stripeClient.customer.create(email: userRequest.email, source: userRequest.stripeToken)
                .flatMap(to: HTTPStatus.self) { stripeCustomer in
                    let newUser = User(email: userRequest.email,
                                       password: userRequest.password,
                                       plate: userRequest.plate,
                                       stripeCustomerID: stripeCustomer.id)
                    return newUser.save(on: req).map { user in
                        return HTTPStatus.created
                    }
            }
        }
    }

}
