import UIKit

final class LeakLabCoordinator: BaseCoordinator, Coordinator {
    private let router: Routing
    private let store: PostProviding
    private(set) var enabled: Set<LeakScenario> = []
    var onKeepOldTreeToggled: ((Bool) -> Void)?

    private static var retainedSlot: Coordinator?

    var navigationController: UINavigationController { (router as! Router).navigationController }

    init(router: Routing, store: PostProviding) {
        self.router = router
        self.store = store
        super.init()
    }

    func start() {
        let lab = LeakLabViewController(coordinator: self)
        LeakDetector.shared.reporter = lab
        router.setStack([lab], animated: false)
    }

    func setEnabled(_ on: Bool, for scenario: LeakScenario) {
        if on { enabled.insert(scenario) } else { enabled.remove(scenario) }
        if scenario == .signOut { onKeepOldTreeToggled?(on) }
    }

    func run(_ scenario: LeakScenario) {
        switch scenario {
        case .forgetChild: runChildFlow()
        case .closureCycle: runClosureCycleFlow()
        case .retainedSlot: runParentlessFlow()
        case .signOut: break   // triggered from the Profile tab's sign-out button
        }
    }

    func reproduce(_ scenario: LeakScenario) {
        setEnabled(true, for: scenario)
        run(scenario)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.router.popToRoot()
        }
    }

    // MARK: Scenarios

    private func runChildFlow() {
        let child = DetailFlowCoordinator(router: router, post: store.posts[2])
        addChild(child)
        child.onFinished = { [weak self, weak child] in
            guard let self, let child else { return }
            if !self.enabled.contains(.forgetChild) { self.removeChild(child) }
            LeakDetector.shared.expectDeallocation(of: child)
        }
        child.start()
    }

    private func runClosureCycleFlow() {
        let child = DetailFlowCoordinator(router: router, post: store.posts[2], strongCycle: enabled.contains(.closureCycle))
        addChild(child)
        child.onFinished = { [weak self, weak child] in
            guard let self, let child else { return }
            self.removeChild(child)
            LeakDetector.shared.expectDeallocation(of: child)
        }
        child.start()
    }

    private func runParentlessFlow() {
        let orphan = DetailFlowCoordinator(router: router, post: store.posts[2])
        if enabled.contains(.retainedSlot) {
            Self.retainedSlot = orphan          // nobody ever clears this
        } else {
            addChild(orphan)
        }
        orphan.onFinished = { [weak self, weak orphan] in
            guard let orphan else { return }
            self?.removeChild(orphan)
            LeakDetector.shared.expectDeallocation(of: orphan)
        }
        orphan.start()
    }
}
