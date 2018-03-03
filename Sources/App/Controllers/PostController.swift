import Vapor

extension PostController: RESTResourceRepresentable {
    func makeAPIResource() -> RESTResource<Post> {
        return RESTResource(
            all: all,
            single: single,
            create: create,
            replace: replace,
            update: update,
            delete: delete
        )
    }
}

final class PostController {
    func all(req: Request) throws -> Future<[Post]> {
        return Post.query(on: req).all()
    }

    func single(req: Request) throws -> Future<Post> {
        return try req.parameter(Post.self)
    }

    func create(req: Request) throws -> Future<Post> {
        return try req
            .content
            .decode(Post.self)
            .save(on: req)
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

    func delete(req: Request) throws -> Future<Post> {
        return try single(req: req).delete(on: req)
    }
}
