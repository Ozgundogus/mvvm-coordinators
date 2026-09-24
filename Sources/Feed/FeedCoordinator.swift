import UIKit

final class FeedCoordinator: BaseCoordinator, Coordinator {
    private let router: Routing
    private let store: PostProviding

    var navigationController: UINavigationController { (router as! Router).navigationController }

    init(router: Routing, store: PostProviding) {
        self.router = router
        self.store = store
        super.init()
    }

    func start() {
        let feed = FeedViewController(posts: store.posts)
        feed.onSelectPost = { [weak self] post in self?.showPost(post) }
        feed.onSelectAuthor = { [weak self] user in self?.showProfile(of: user) }
        feed.onCompose = { [weak self] in self?.startCompose(replyingTo: nil) }
        router.setStack([feed], animated: false)
    }

    func childDidFinish(_ child: Coordinator) {
        removeChild(child)
        LeakDetector.shared.expectDeallocation(of: child)
    }

    // MARK: Screens this coordinator owns directly

    private func showPost(_ post: Post) {
        router.push(makeDetail(for: post))
    }

    private func showComments(for post: Post) {
        router.push(makeComments(for: post))
    }

    private func showProfile(of user: User) {
        let profile = ProfileCoordinator(user: user, router: router, store: store, embedded: true)
        addChild(profile)
        profile.start()
    }

    // MARK: A modal child flow

    private func startCompose(replyingTo post: Post?) {
        let compose = ComposeCoordinator(presenter: router, replyingTo: post)
        addChild(compose)
        compose.start()
    }

    /// `-screen compose|picker` launch argument.
    func openComposeForScreenshot(showPicker: Bool) {
        let compose = ComposeCoordinator(presenter: router, replyingTo: store.posts[1])
        addChild(compose)
        compose.start()
        guard showPicker else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { compose.showMediaPicker() }
    }

    // MARK: Deep links

    /// One `setStack`, one transition; no chained pushes.
    func handle(_ link: DeepLink) {
        guard let root = router.rootViewController else { return }
        switch link {
        case .post(let id):
            guard let post = store.post(id: id) else { return }
            router.setStack([root, makeDetail(for: post)], animated: true)
        case .comments(let id):
            guard let post = store.post(id: id) else { return }
            router.setStack([root, makeDetail(for: post), makeComments(for: post)], animated: true)
        case .profile:
            break
        }
    }

    // MARK: Screen factories

    private func makeDetail(for post: Post) -> UIViewController {
        let detail = PostDetailViewController(post: post)
        detail.onShowComments = { [weak self] in self?.showComments(for: post) }
        detail.onSelectAuthor = { [weak self] in self?.showProfile(of: post.author) }
        detail.onReply = { [weak self] in self?.startCompose(replyingTo: post) }
        return detail
    }

    private func makeComments(for post: Post) -> UIViewController {
        let comments = CommentsViewController(post: post, comments: store.comments(for: post))
        comments.onReply = { [weak self] in self?.startCompose(replyingTo: post) }
        comments.onSelectAuthor = { [weak self] user in self?.showProfile(of: user) }
        return comments
    }
}
