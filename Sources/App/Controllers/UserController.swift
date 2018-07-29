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
        return try req.content.decode(UserRequest.self).flatMap { userRequest in
            let stripeClient = try req.make(StripeClient.self)
            return try stripeClient.customer.create(accountBalance: nil,
                                                    businessVatId: nil,
                                                    coupon: nil,
                                                    defaultSource: nil,
                                                    description: nil,
                                                    email: userRequest.email,
                                                    metadata: nil,
                                                    shipping: nil,
                                                    source: userRequest.stripeToken).flatMap(to: HTTPStatus.self) { stripeCustomer in
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

    //    func loginUser(_ request: Request) throws -> Future<AuthenticatedUser> {
    //        return try request.content.decode(User.LoginRequest.self).flatMap(to: AuthenticatedUser.self) { user in // 1
    //            let passwordVerifier = try request.make(BCryptDigest.self)
    //
    //            return User.authenticate(username: user.email, password: user.password, using: passwordVerifier, on: request).unwrap(or: Abort.init(HTTPResponseStatus.unauthorized)).flatMap(to: AuthenticatedUser.self) { authedUser in // 2
    //
    //                let newAccessKey = try AccessToken.generateAccessToken(for: authedUser) // 3
    //                return newAccessKey.save(on: request).map(to: AuthenticatedUser.self) { newKey in // 4
    //                    return try AuthenticatedUser(email: authedUser.email, id: authedUser.requireID(), displayName: authedUser.displayName, token: newKey.token) // 5
    //                }
    //
    //            }
    //        }
    //    }

}
