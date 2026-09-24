import Foundation

/// Does not conform to `Coordinator` on purpose: each subclass declares the
/// conformance itself, so a missing `start()` is a compile error.
class BaseCoordinator {
    var children: [Coordinator] = []
    weak var parent: Coordinator?

    init() {}

    deinit {
        LeakDetector.shared.didDeinit(self)
    }
}
