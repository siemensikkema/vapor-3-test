import Vapor

extension Future where Expectation: Content {
    func makeResponse(on req: Request) -> Future<Response> {
        return flatMap(to: Response.self) { exp in
            try exp.encode(for: req)
        }
    }
}

//extension Content {
//    func patch(
//        keyPaths: [PartialKeyPath<Self>],
//        using: Request
//    ) {
//
//    }
//}
//
//extension Post: Patchable {
//    static var patchableKeys: [BasicKey] {
//
//
//
//    }
//}
import Fluent

struct APIResource<T> where T: Model, T: Content {
    let path: String
    let all: ((Request) throws -> Future<[T]>)?

    init(
        path: String = T.entity,
        all: ((Request) throws -> Future<[T]>)? = nil
    ) {
        self.path = path
        self.all = all
    }

    func register(router: Router) {
        let group = router.grouped(path.makePathComponent())
        if let all = all {
            group.get(use: all)
        }
    }
}

extension PostController {
    func makeAPIResource() -> APIResource<Post> {
        return APIResource(all: all)
    }
}

final class PostController {
    func all(req: Request) throws -> Future<[Post]> {
        return Post.query(on: req).all()
    }

    func single(req: Request) throws -> Future<Post> {
        return try req.parameter(Post.self)
    }

    func create(req: Request) throws -> Future<Response> {
        return try req
            .content
            .decode(Post.self)
            .save(on: req)
            .flatMap(to: Response.self) { post in
                let id = try post.requireID()
                return try post.encode(for: req).do {
                    $0.http.status = .created
                    $0.http.headers[.location] = "/posts/\(id)"
                }
        }
    }

    func replace(req: Request) throws -> Future<Post> {
        return try map(
            to: Post.self,
            single(req: req),
            req.content.decode(Post.self)
        ) { (old, new) in
            old.body = new.body
            old.title = new.title
            return old
        }
    }

    func update(req: Request) throws -> Future<Post> {
        return try map(
            to: Post.self,
            single(req: req),
            req.content.decode(Post.Partial.self)
        ) { (old, new) in
            if let body = new.body {
                old.body = body
            }
            if let title = new.title {
                old.title = title
            }
            return old
        }
    }

    func delete(req: Request) throws -> Future<HTTPStatus> {
        return try single(req: req).delete(on: req).transform(to: .noContent)
    }
}
