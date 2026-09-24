import UIKit

/// The same flow lives in two places: as a tab (root of its own stack) and as a child
/// pushed from the feed. Same coordinator, different parent, different `embedded`.
final class ProfileCoordinator: BaseCoordinator, Coordinator {
    var onSignOut: (() -> Void)?
    private let user: User
    private let router: Routing
    private let store: PostProviding
    private let embedded: Bool

    var navigationController: UINavigationController { (router as! Router).navigationController }

    init(user: User, router: Routing, store: PostProviding, embedded: Bool) {
        self.user = user
        self.router = router
        self.store = store
        self.embedded = embedded
        super.init()
    }

    func start() {
        let profile = ProfileViewController(user: user, posts: store.posts(by: user), showsSignOut: !embedded)
        profile.onSelectPost = { [weak self] post in self?.showPost(post) }
        profile.onSignOut = { [weak self] in self?.onSignOut?() }
        if embedded {
            // Pushed as a child: when this screen pops, the flow is over.
            router.push(profile, onPop: { [weak self] in self?.finish() })
        } else {
            router.setStack([profile], animated: false)
        }
    }

    private func showPost(_ post: Post) {
        let detail = PostDetailViewController(post: post)
        detail.onShowComments = { [weak self] in
            guard let self else { return }
            self.router.push(CommentsViewController(post: post, comments: self.store.comments(for: post)))
        }
        router.push(detail)
    }
}
