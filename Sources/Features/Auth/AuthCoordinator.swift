import UIKit

protocol AuthCoordinatorDelegate: AnyObject {
    func authCoordinator(_ coordinator: AuthCoordinator, didSignIn session: Session)
}

final class AuthCoordinator: BaseCoordinator, Coordinator {
    weak var delegate: AuthCoordinatorDelegate?
    private let router: Routing
    private let auth: AuthService

    init(router: Routing, auth: AuthService) {
        self.router = router
        self.auth = auth
        super.init()
    }

    func start() {
        let viewModel = WelcomeViewModel()
        viewModel.onContinue = { [weak self] in self?.showSignIn() }
        router.setStack([WelcomeViewController(viewModel: viewModel)], animated: false)
    }

    private func showSignIn() {
        let viewModel = SignInViewModel(auth: auth)
        viewModel.onSignedIn = { [weak self] session in
            guard let self else { return }
            self.delegate?.authCoordinator(self, didSignIn: session)
        }
        router.push(SignInViewController(viewModel: viewModel))
    }
}
