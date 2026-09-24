import UIKit

/// The lab's one-screen flow, optionally with a bug switched on.
final class DetailFlowCoordinator: BaseCoordinator, Coordinator {
    enum Bug {
        case closureCycle
        case subscriptionCycle
    }

    private let router: Routing
    private let repository: PostRepository
    private let post: Post
    private let bug: Bug?
    private var viewModel: DetailFlowViewModel?

    init(router: Routing, repository: PostRepository, post: Post, bug: Bug? = nil) {
        self.router = router
        self.repository = repository
        self.post = post
        self.bug = bug
        super.init()
    }

    func start() {
        let viewModel = DetailFlowViewModel(post: post)
        if bug == .closureCycle {
            viewModel.onShowComments = { self.showComments() }
        } else {
            viewModel.onShowComments = { [weak self] in self?.showComments() }
        }
        self.viewModel = viewModel

        let screen = DetailFlowViewController(viewModel: viewModel, strongSubscription: bug == .subscriptionCycle)
        router.push(screen, onPop: { [weak self, weak screen] in
            guard let self else { return }
            self.finish()
            LeakDetector.shared.expectDeallocation(of: self)
            if let screen { LeakDetector.shared.expectDeallocation(of: screen) }
        })
    }

    private func showComments() {
        let comments = CommentsViewModel(post: post, repository: repository)
        router.push(CommentsViewController(viewModel: comments))
    }
}
