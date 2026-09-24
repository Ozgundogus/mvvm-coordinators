import UIKit

/// The only object that touches UIKit navigation. One completion per screen,
/// fired when that screen leaves the stack by any route.
final class Router: NSObject, Routing {
    let navigationController: UINavigationController
    private var completions: [ObjectIdentifier: () -> Void] = [:]

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init()
        navigationController.delegate = self
    }

    var rootViewController: UIViewController? { navigationController.viewControllers.first }

    // MARK: Routing

    func push(_ viewController: UIViewController, animated: Bool, onPop: (() -> Void)?) {
        if let onPop { completions[ObjectIdentifier(viewController)] = onPop }
        navigationController.pushViewController(viewController, animated: animated)
    }

    func setStack(_ viewControllers: [UIViewController], animated: Bool) {
        navigationController.setViewControllers(viewControllers, animated: animated)
    }

    func popToRoot(animated: Bool) {
        navigationController.popToRootViewController(animated: animated)
    }

    func present(_ viewController: UIViewController, animated: Bool, onDismiss: (() -> Void)?) {
        if let onDismiss {
            completions[ObjectIdentifier(viewController)] = onDismiss
            viewController.presentationController?.delegate = self
        }
        navigationController.present(viewController, animated: animated)
    }

    func dismiss(_ viewController: UIViewController, animated: Bool) {
        viewController.dismiss(animated: animated) { [weak self] in
            self?.runCompletion(for: viewController)
        }
    }

    // MARK: Completion bookkeeping

    private func runCompletion(for viewController: UIViewController) {
        completions.removeValue(forKey: ObjectIdentifier(viewController))?()
    }

    private func runCompletionsForRemovedControllers() {
        let live = Set(navigationController.viewControllers.map(ObjectIdentifier.init))
        for id in completions.keys where !live.contains(id) {
            completions.removeValue(forKey: id)?()
        }
    }
}

extension Router: UINavigationControllerDelegate {
    /// One pop, popToRoot, or a replaced stack all look the same here.
    func navigationController(_ navigationController: UINavigationController,
                              didShow viewController: UIViewController,
                              animated: Bool) {
        runCompletionsForRemovedControllers()
    }
}

extension Router: UIAdaptivePresentationControllerDelegate {
    /// Swipe-to-dismiss never calls `dismiss`; this does.
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        runCompletion(for: presentationController.presentedViewController)
    }
}
