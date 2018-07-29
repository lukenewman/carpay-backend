import Vapor

public func routes(_ router: Router) throws {

    router.get() { req in
        return "Hello, world!"
    }

    let userController = UserController()
    router.get("users", use: userController.index)
    router.post("users", use: userController.create)
//
//    let sessionController = SessionController()
//    router.post("start", use: sessionController.start)
//    router.post("stop", use: sessionController.stop)
    
}
