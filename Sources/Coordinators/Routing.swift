import UIKit

/// What a coordinator needs from navigation — and nothing else. Coordinators
/// depend on this protocol, not on `UINavigationController`, which is what makes
/// them testable without a simulator (see `Tests/`).
protocol Routing: AnyObject {
    /// Push a screen. `onPop` runs once, whenever the screen leaves the stack — back
    /// button, swipe, `popToRoot`, anything.
    func push(_ viewController: UIViewController, animated: Bool, onPop: (() -> Void)?)

    /// Replace the whole stack in one transition.
    func setStack(_ viewControllers: [UIViewController], animated: Bool)

    func popToRoot(animated: Bool)

    /// Present modally. `onDismiss` runs once, whether you called `dismiss` or the
    /// user dragged the sheet down.
    func present(_ viewController: UIViewController, animated: Bool, onDismiss: (() -> Void)?)

    func dismiss(_ viewController: UIViewController, animated: Bool)

    /// The root screen of this stack, if any. Deep links rebuild on top of it.
    var rootViewController: UIViewController? { get }
}

extension Routing {
    func push(_ viewController: UIViewController, onPop: (() -> Void)? = nil) {
        push(viewController, animated: true, onPop: onPop)
    }

    func present(_ viewController: UIViewController, onDismiss: (() -> Void)? = nil) {
        present(viewController, animated: true, onDismiss: onDismiss)
    }

    func dismiss(_ viewController: UIViewController) {
        dismiss(viewController, animated: true)
    }

    func popToRoot() {
        popToRoot(animated: true)
    }
}
