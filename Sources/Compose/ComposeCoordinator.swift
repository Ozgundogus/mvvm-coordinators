import UIKit

/// A modal flow with its own navigation stack and its own child (the media picker).
/// It ends in three ways — Post, Cancel, or the sheet swiped down — and all three go
/// through the same `finish()`. The picker inside it is a coordinator inside a
/// coordinator: a child of a child, and it is removed the same way.
final class ComposeCoordinator: BaseCoordinator, Coordinator {
    private let presenter: Routing
    private let navigation = UINavigationController()
    private lazy var router: Routing = Router(navigationController: navigation)
    private let replyingTo: Post?
    private weak var composeScreen: ComposeViewController?

    init(presenter: Routing, replyingTo: Post?) {
        self.presenter = presenter
        self.replyingTo = replyingTo
        super.init()
    }

    func start() {
        let compose = ComposeViewController(replyingTo: replyingTo)
        compose.onDone = { [weak self] in self?.close() }
        compose.onAttach = { [weak self] in self?.showMediaPicker() }
        composeScreen = compose
        navigation.viewControllers = [compose]
        navigation.sheetPresentationController?.detents = [.large()]
        presenter.present(navigation, onDismiss: { [weak self] in self?.finish() })
    }

    func childDidFinish(_ child: Coordinator) {
        removeChild(child)
        LeakDetector.shared.expectDeallocation(of: child)
    }

    func showMediaPicker() {
        let picker = MediaPickerCoordinator(router: router)
        picker.onPicked = { [weak self] seed in self?.composeScreen?.attach(seed: seed) }
        addChild(picker)
        picker.start()
    }

    private func close() {
        presenter.dismiss(navigation)   // fires onDismiss above → finish()
    }
}
