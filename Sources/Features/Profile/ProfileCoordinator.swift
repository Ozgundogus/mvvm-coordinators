import UIKit

/// Used both as a tab root and as a child pushed from the feed (`embedded`).
final class ProfileCoordinator: BaseCoordinator, Coordinator {
    private let user: User
    private let router: Routing
    private let repository: PostRepository
    private let session: SessionStore
    private let auth: AuthService
    private let embedded: Bool
    private let screens: PostScreenFactory

    init(user: User, router: Routing, repository: PostRepository, session: SessionStore, auth: AuthService, embedded: Bool) {
        self.user = user
        self.router = router
        self.repository = repository
        self.session = session
        self.auth = auth
        self.embedded = embedded
        self.screens = PostScreenFactory(repository: repository)
        super.init()
    }

    func start() {
        let viewModel = ProfileViewModel(user: user, repository: repository, session: session, auth: auth, showsSignOut: !embedded)
        viewModel.onSelectPost = { [weak self] post in self?.showPost(post) }
        let profile = ProfileViewController(viewModel: viewModel)
        if embedded {
            router.push(profile, onPop: { [weak self] in self?.finish() })
        } else {
            router.setStack([profile], animated: false)
        }
    }

    func childDidFinish(_ child: Coordinator) {
        removeChild(child)
        LeakDetector.shared.expectDeallocation(of: child)
    }

    private var postActions: PostScreenActions {
        PostScreenActions(
            showComments: { [weak self] post in
                guard let self else { return }
                self.router.push(self.screens.makeComments(for: post, actions: self.postActions))
            },
            showAuthor: { _ in },
            reply: { [weak self] post in self?.startCompose(replyingTo: post) }
        )
    }

    private func showPost(_ post: Post) {
        router.push(screens.makeDetail(for: post, actions: postActions))
    }

    private func startCompose(replyingTo post: Post) {
        let compose = ComposeCoordinator(presenter: router, replyingTo: post)
        addChild(compose)
        compose.start()
    }
}
