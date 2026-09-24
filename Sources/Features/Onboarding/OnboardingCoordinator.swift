import UIKit

protocol OnboardingCoordinatorDelegate: AnyObject {
    func onboardingDidFinish(_ coordinator: OnboardingCoordinator)
}

final class OnboardingCoordinator: BaseCoordinator, Coordinator {
    weak var delegate: OnboardingCoordinatorDelegate?
    private let router: Routing
    private let preferences: Preferences

    init(router: Routing, preferences: Preferences) {
        self.router = router
        self.preferences = preferences
        super.init()
    }

    func start() {
        let viewModel = OnboardingViewModel()
        viewModel.onFinish = { [weak self] in self?.complete() }
        router.setStack([OnboardingViewController(viewModel: viewModel)], animated: false)
    }

    private func complete() {
        preferences.hasCompletedOnboarding = true
        delegate?.onboardingDidFinish(self)
    }
}
