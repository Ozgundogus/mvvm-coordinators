import UIKit

protocol Routing: AnyObject {
    /// `onPop` runs once, whenever the screen leaves the stack.
    func push(_ viewController: UIViewController, animated: Bool, onPop: (() -> Void)?)

    func setStack(_ viewControllers: [UIViewController], animated: Bool)

    func popToRoot(animated: Bool)

    /// `onDismiss` runs once, including when the sheet is dragged down.
    func present(_ viewController: UIViewController, animated: Bool, onDismiss: (() -> Void)?)

    func dismiss(_ viewController: UIViewController, animated: Bool)

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
