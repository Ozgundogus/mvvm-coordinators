import Foundation

/// Storage and a `deinit` log, nothing more. It deliberately does *not* conform to
/// `Coordinator`: each concrete coordinator declares the conformance itself, so
/// `start()` has to be written rather than inherited as a `fatalError` stub.
class BaseCoordinator {
    var children: [Coordinator] = []
    weak var parent: Coordinator?

    init() {}

    deinit {
        LeakDetector.shared.didDeinit(self)
    }
}
