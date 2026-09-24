import Foundation

/// A coordinator owns a flow: it decides which screen comes next and who owns whom.
///
/// Ownership is the whole game. A coordinator lives exactly as long as its parent
/// holds it in `children`, and not one reference longer. The three rules:
///
/// 1. A parent adds a child with `addChild`, which sets `child.parent`.
/// 2. A child ends its flow with `finish()`, which only *tells* the parent.
/// 3. The parent removes the child in `childDidFinish`. Nobody else touches
///    anybody else's `children`.
protocol Coordinator: AnyObject {
    var children: [Coordinator] { get set }
    var parent: Coordinator? { get set }

    func start()

    /// Called by a child when its flow is over. Implement it to react — refresh,
    /// present the next step — and call `removeChild` when you do.
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

    /// Default: just drop the child. Because `childDidFinish` is a protocol
    /// *requirement*, a conforming type's own implementation wins even when the
    /// call goes through the `Coordinator` existential — which is exactly how
    /// `finish()` calls it.
    func childDidFinish(_ child: Coordinator) {
        removeChild(child)
    }

    /// The one way a flow ends. Never remove yourself from someone else's array;
    /// never hold a strong pointer to the parent.
    func finish() {
        parent?.childDidFinish(self)
    }
}
