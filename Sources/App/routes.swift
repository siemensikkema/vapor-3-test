import Vapor

func routes(_ router: Router) throws {
    let postsGroup = router.grouped("posts")
    let postController = PostController()

    postsGroup.get(use: postController.all)
    postsGroup.get(Post.parameter, use: postController.single)
    postsGroup.post(use: postController.create)
    postsGroup.put(Post.parameter, use: postController.replace)
    postsGroup.patch(Post.parameter, use: postController.update)
    postsGroup.delete(Post.parameter, use: postController.delete)
}
