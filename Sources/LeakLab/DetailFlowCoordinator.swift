import UIKit

final class DetailFlowCoordinator: BaseCoordinator, Coordinator {
    var onFinished: (() -> Void)?
    private let router: Routing
    private let post: Post
    private let strongCycle: Bool
    private var viewModel: DetailFlowViewModel?

    init(router: Routing, post: Post, strongCycle: Bool = false) {
        self.router = router
        self.post = post
        self.strongCycle = strongCycle
        super.init()
    }

    func start() {
        let viewModel = DetailFlowViewModel(post: post)
        if strongCycle {
            viewModel.onShowComments = { self.showComments() }              // captures self
        } else {
            viewModel.onShowComments = { [weak self] in self?.showComments() }
        }
        self.viewModel = viewModel

        let detail = PostDetailViewController(post: post)
        detail.onShowComments = { [weak viewModel] in viewModel?.onShowComments?() }
        router.push(detail, onPop: { [weak self] in self?.onFinished?() })
    }

    private func showComments() {
        router.push(CommentsViewController(post: post, comments: []))
    }
}

final class DetailFlowViewModel {
    let post: Post
    var onShowComments: (() -> Void)?

    init(post: Post) { self.post = post }

    deinit { LeakDetector.shared.didDeinit(self) }
}
