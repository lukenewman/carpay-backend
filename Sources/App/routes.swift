import Vapor

public func routes(_ router: Router) throws {

    router.get() { req in
        return "Hello, world!"
    }

    let userController = UserController()
    try router.register(collection: userController)

    let sessionController = SessionController()
    try router.register(collection: sessionController)

}
