@testable import CoordinatorsDemo

final class SpyCoordinator: BaseCoordinator, Coordinator {
    var childDidFinishCalled = false
    func start() {}
    func childDidFinish(_ child: Coordinator) {
        childDidFinishCalled = true
        removeChild(child)
    }
}
