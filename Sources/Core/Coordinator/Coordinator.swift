import Foundation

/// A parent adds a child with `addChild`; the child ends with `finish()`, which
/// only notifies the parent; the parent removes it in `childDidFinish`.
protocol Coordinator: AnyObject {
    var children: [Coordinator] { get set }
    var parent: Coordinator? { get set }

    func start()

    func childDidFinish(_ child: Coordinator)
}

extension Coordinator {
    func addChild(_ child: Coordinator) {
        child.parent = self
        children.append(child)
    }

    func removeChild(_ child: Coordinator) {
        children.removeAll { $0 === child }
        child.parent = nil
    }

    /// A protocol requirement, so a conformer's own implementation is called even
    /// through the `Coordinator` existential, which is how `finish()` calls it.
    func childDidFinish(_ child: Coordinator) {
        removeChild(child)
    }

    func finish() {
        parent?.childDidFinish(self)
    }
}
