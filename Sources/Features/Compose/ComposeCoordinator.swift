import UIKit

final class ComposeCoordinator: BaseCoordinator, Coordinator {
    private let presenter: Routing
    private let navigation = UINavigationController()
    private lazy var router: Routing = Router(navigationController: navigation)
    private let replyingTo: Post?
    private var viewModel: ComposeViewModel?

    init(presenter: Routing, replyingTo: Post?) {
        self.presenter = presenter
        self.replyingTo = replyingTo
        super.init()
    }

    func start() {
        let viewModel = ComposeViewModel(replyingTo: replyingTo,
                                         draft: "The router's onPop is the part I always forget. Writing it down this time.")
        viewModel.onDone = { [weak self] in self?.dismiss() }
        viewModel.onAttach = { [weak self] in self?.showMediaPicker() }
        self.viewModel = viewModel
        navigation.viewControllers = [ComposeViewController(viewModel: viewModel)]
        navigation.sheetPresentationController?.detents = [.large()]
        presenter.present(navigation, onDismiss: { [weak self] in self?.finish() })
    }

    func childDidFinish(_ child: Coordinator) {
        removeChild(child)
        LeakDetector.shared.expectDeallocation(of: child)
    }

    func showMediaPicker() {
        let picker = MediaPickerCoordinator(router: router)
        picker.onPicked = { [weak self] seed in self?.viewModel?.attach(seed: seed) }
        addChild(picker)
        picker.start()
    }

    func dismiss() {
        presenter.dismiss(navigation)
    }
}
