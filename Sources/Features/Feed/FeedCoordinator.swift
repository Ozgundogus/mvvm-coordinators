import UIKit

final class FeedCoordinator: BaseCoordinator, Coordinator {
    private let router: Routing
    private let repository: PostRepository
    private let session: SessionStore
    private let auth: AuthService
    private let screens: PostScreenFactory

    init(router: Routing, repository: PostRepository, session: SessionStore, auth: AuthService) {
        self.router = router
        self.repository = repository
        self.session = session
        self.auth = auth
        self.screens = PostScreenFactory(repository: repository)
        super.init()
    }

    func start() {
        let viewModel = FeedViewModel(repository: repository)
        viewModel.onSelectPost = { [weak self] post in self?.showPost(post) }
        viewModel.onSelectAuthor = { [weak self] user in self?.showProfile(of: user) }
        viewModel.onCompose = { [weak self] in self?.startCompose(replyingTo: nil) }
        router.setStack([FeedViewController(viewModel: viewModel)], animated: false)
    }

    func childDidFinish(_ child: Coordinator) {
        removeChild(child)
        LeakDetector.shared.expectDeallocation(of: child)
    }

    // MARK: Screens this coordinator owns directly

    private var postActions: PostScreenActions {
        PostScreenActions(
            showComments: { [weak self] post in self?.showComments(for: post) },
            showAuthor: { [weak self] user in self?.showProfile(of: user) },
            reply: { [weak self] post in self?.startCompose(replyingTo: post) }
        )
    }

    private func showPost(_ post: Post) {
        router.push(screens.makeDetail(for: post, actions: postActions))
    }

    private func showComments(for post: Post) {
        router.push(screens.makeComments(for: post, actions: postActions))
    }

    // MARK: Child flows

    private func showProfile(of user: User) {
        let profile = ProfileCoordinator(user: user, router: router, repository: repository, session: session, auth: auth, embedded: true)
        addChild(profile)
        profile.start()
    }

    private func startCompose(replyingTo post: Post?) {
        let compose = ComposeCoordinator(presenter: router, replyingTo: post)
        addChild(compose)
        compose.start()
    }

    // MARK: Deep links

    /// One `setStack`, one transition; no chained pushes. Anything this tab had
    /// open ends first: a sheet is dismissed, a pushed child flow is popped by the
    /// stack replacement, and both come back through `childDidFinish`.
    func handle(_ link: DeepLink, animated: Bool) {
        guard let root = router.rootViewController else { return }
        children.compactMap { $0 as? ComposeCoordinator }.forEach { $0.dismiss() }
        switch link {
        case .post(let id):
            guard let post = repository.post(id: id) else { return }
            let detail = screens.makeDetail(for: post, actions: postActions)
            router.setStack([root, detail], animated: animated)
        case .comments(let id):
            guard let post = repository.post(id: id) else { return }
            let detail = screens.makeDetail(for: post, actions: postActions)
            let comments = screens.makeComments(for: post, actions: postActions)
            router.setStack([root, detail, comments], animated: animated)
        case .profile:
            break
        }
    }

    // MARK: Screenshot helper (`-screen compose|picker`)

    func openCompose(showPicker: Bool) {
        let compose = ComposeCoordinator(presenter: router, replyingTo: repository.posts[1])
        addChild(compose)
        compose.start()
        guard showPicker else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { compose.showMediaPicker() }
    }
}
