import XCTest
@testable import CoordinatorsDemo

final class LeakLabTests: XCTestCase {
    private func makeLab(_ settings: LeakSettings) -> (LeakLabCoordinator, FakeRouter) {
        let router = FakeRouter()
        let lab = LeakLabCoordinator(router: router, repository: SamplePostRepository(), settings: settings)
        lab.start()
        return (lab, router)
    }

    func testClosureCycleChildIsRemovedButStaysAlive() {
        let settings = LeakSettings()
        settings.set(.closureCycle, enabled: true)
        let (lab, router) = makeLab(settings)
        lab.run(.closureCycle)
        weak var child = lab.children.first
        XCTAssertNotNil(child)

        router.popToRoot()

        XCTAssertEqual(lab.children.count, 0, "parent must remove the child")
        XCTAssertNotNil(child, "the closure cycle keeps it alive anyway")
    }

    func testForgetChildLeavesItInChildren() {
        let settings = LeakSettings()
        settings.set(.forgetChild, enabled: true)
        let (lab, router) = makeLab(settings)
        lab.run(.forgetChild)
        router.popToRoot()
        XCTAssertEqual(lab.children.count, 1)
    }

    func testHealthyFlowIsRemovedAndDeallocated() {
        let (lab, router) = makeLab(LeakSettings())
        lab.run(.closureCycle)
        weak var child = lab.children.first
        router.popToRoot()
        XCTAssertEqual(lab.children.count, 0)
        XCTAssertNil(child)
    }
}
