import Fluent
import Vapor

typealias APIResourceModel = Model & Content & Parameter

protocol APIResourceRepresentable {
    associatedtype T: APIResourceModel
    func makeAPIResource() -> APIResource<T>
}

extension APIResourceRepresentable {
    func register(router: Router) {
        makeAPIResource().register(router: router)
    }
}

struct APIResource<T> where T: APIResourceModel {
    let path: String

    typealias All = (Request) throws -> Future<[T]>
    typealias Single = (Request) throws -> Future<T>
    let all: All?
    let single: Single?
    let create: Single?
    let replace: Single?
    let update: Single?
    let delete: Single?

    init(
        path: String = T.entity,
        all: All? = nil,
        single: Single? = nil,
        create: Single? = nil,
        replace: Single? = nil,
        update: Single? = nil,
        delete: Single? = nil
    ) {
        self.path = path
        self.all = all
        self.single = single
        self.create = create
        self.replace = replace
        self.update = update
        self.delete = delete
    }

    func register(router: Router) {
        let group = router.grouped(path.makePathComponent())

        if let all = all {
            group.get(use: all)
        }

        if let single = single {
            group.get(use: single)
        }

        if let create = create {
            group.post { [path] req in
                try create(req)
                    .flatMap(to: Response.self) { model in
                        let id = try model.requireID()
                        return try model.encode(for: req).do {
                            $0.http.status = .created
                            $0.http.headers[.location] = "/\(path)/\(id)"
                        }
                }
            }
        }

        if let replace = replace {
            group.put(T.parameter, use: replace)
        }

        if let update = update {
            group.patch(T.parameter, use: update)
        }

        if let delete = delete {
            group.delete(T.parameter) {
                try delete($0).transform(to: HTTPStatus.noContent)
            }
        }
    }
}
