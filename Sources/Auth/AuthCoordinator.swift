import UIKit

protocol AuthCoordinatorDelegate: AnyObject {
    func authCoordinator(_ coordinator: AuthCoordinator, didSignIn user: User)
}

/// Welcome → pick an account → signed in. The coordinator reports the result to its
/// delegate and is then removed by the parent; it never removes itself.
final class AuthCoordinator: BaseCoordinator, Coordinator {
    weak var delegate: AuthCoordinatorDelegate?
    private let router: Routing
    private let store: PostProviding

    var rootViewController: UIViewController { (router as? Router)?.navigationController ?? UIViewController() }

    init(router: Routing, store: PostProviding) {
        self.router = router
        self.store = store
        super.init()
    }

    func start() {
        let welcome = WelcomeViewController()
        welcome.onContinue = { [weak self] in self?.showAccountPicker() }
        router.setStack([welcome], animated: false)
    }

    private func showAccountPicker() {
        let picker = AccountPickerViewController(users: store.users)
        picker.onPick = { [weak self] user in
            guard let self else { return }
            self.delegate?.authCoordinator(self, didSignIn: user)
        }
        router.push(picker)
    }
}
