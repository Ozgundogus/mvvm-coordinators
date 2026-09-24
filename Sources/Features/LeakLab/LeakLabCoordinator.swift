import UIKit

final class LeakLabCoordinator: BaseCoordinator, Coordinator {
    private let router: Routing
    private let repository: PostRepository
    private let settings: LeakSettings
    private var viewModel: LeakLabViewModel?

    private static var retainedSlot: Coordinator?

    init(router: Routing, repository: PostRepository, settings: LeakSettings) {
        self.router = router
        self.repository = repository
        self.settings = settings
        super.init()
    }

    func start() {
        let viewModel = LeakLabViewModel(settings: settings)
        viewModel.onRun = { [weak self] scenario in self?.run(scenario) }
        self.viewModel = viewModel
        LeakDetector.shared.reporter = viewModel
        router.setStack([LeakLabViewController(viewModel: viewModel)], animated: false)
    }

    /// With `forgetChild` on, the parent hears the child finish and does nothing.
    func childDidFinish(_ child: Coordinator) {
        if settings.isEnabled(.forgetChild) { return }
        removeChild(child)
    }

    func run(_ scenario: LeakScenario) {
        let post = repository.posts[2]
        switch scenario {
        case .forgetChild:
            startChild(DetailFlowCoordinator(router: router, repository: repository, post: post))
        case .closureCycle:
            let bug: DetailFlowCoordinator.Bug? = settings.isEnabled(.closureCycle) ? .closureCycle : nil
            startChild(DetailFlowCoordinator(router: router, repository: repository, post: post, bug: bug))
        case .subscriptionCycle:
            let bug: DetailFlowCoordinator.Bug? = settings.isEnabled(.subscriptionCycle) ? .subscriptionCycle : nil
            startChild(DetailFlowCoordinator(router: router, repository: repository, post: post, bug: bug))
        case .retainedSlot:
            let orphan = DetailFlowCoordinator(router: router, repository: repository, post: post)
            if settings.isEnabled(.retainedSlot) {
                Self.retainedSlot = orphan
                orphan.start()
            } else {
                startChild(orphan)
            }
        case .signOut:
            break
        }
    }

    func reproduce(_ scenario: LeakScenario) {
        settings.set(scenario, enabled: true)
        run(scenario)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.router.popToRoot()
        }
    }

    private func startChild(_ child: DetailFlowCoordinator) {
        addChild(child)
        child.start()
    }
}
