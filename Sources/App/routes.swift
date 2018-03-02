import Vapor

func routes(_ router: Router) throws {
    PostController().register(router: router)
}
