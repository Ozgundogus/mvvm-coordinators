import XCTest
@testable import CoordinatorsDemo

/// Coordinators depend on `Routing`, not on UIKit navigation. That's what lets these
/// tests run the real flows with a fake router: no simulator screen, no animation,
/// and every pop is a function call we control.
final class CoordinatorTests: XCTestCase {

    // MARK: Ownership

    func testChildIsRemovedWhenItsScreenPops() {
        let router = FakeRouter()
        let feed = FeedCoordinator(router: router, store: SampleStore())
        feed.start()

        // Simulate the user tapping an avatar: a ProfileCoordinator child is pushed.
        router.tapFirstAvatar()
        XCTAssertEqual(feed.children.count, 1)
        XCTAssertTrue(feed.children.first is ProfileCoordinator)

        // Simulate the back button on that screen.
        router.popTop()
        XCTAssertEqual(feed.children.count, 0, "child must be removed when its screen leaves the stack")
    }

    func testFinishOnlyTellsTheParent() {
        let parent = SpyCoordinator()
        let child = SpyCoordinator()
        parent.addChild(child)

        child.finish()

        XCTAssertTrue(parent.childDidFinishCalled)
        XCTAssertEqual(parent.children.count, 0)
        XCTAssertNil(child.parent)
    }

    func testCoordinatorDeallocatesAfterFinish() {
        let parent = SpyCoordinator()
        weak var weakChild: SpyCoordinator?
        autoreleasepool {
            let child = SpyCoordinator()
            parent.addChild(child)
            weakChild = child
            child.finish()
        }
        XCTAssertNil(weakChild, "nothing should hold a finished coordinator")
    }

    // MARK: Deep links

    func testDeepLinkBuildsTheWholeStackInOneCall() {
        let router = FakeRouter()
        let feed = FeedCoordinator(router: router, store: SampleStore())
        feed.start()

        feed.handle(.comments(postID: 103))

        XCTAssertEqual(router.setStackCalls, 2, "start + one deep link")
        XCTAssertEqual(router.stack.count, 3, "feed, post, comments")
        XCTAssertTrue(router.stack[1] is PostDetailViewController)
        XCTAssertTrue(router.stack[2] is CommentsViewController)
        XCTAssertEqual(router.pushCalls, 0, "no chained pushes, no delays")
    }
}

// MARK: - Test doubles

final class SpyCoordinator: BaseCoordinator, Coordinator {
    var childDidFinishCalled = false
    func start() {}
    func childDidFinish(_ child: Coordinator) {
        childDidFinishCalled = true
        removeChild(child)
    }
}

/// Records what a coordinator asks for and lets the test "pop" screens by hand.
final class FakeRouter: Routing {
    private(set) var stack: [UIViewController] = []
    private var completions: [ObjectIdentifier: () -> Void] = [:]
    private(set) var pushCalls = 0
    private(set) var setStackCalls = 0

    var rootViewController: UIViewController? { stack.first }

    func push(_ viewController: UIViewController, animated: Bool, onPop: (() -> Void)?) {
        pushCalls += 1
        stack.append(viewController)
        if let onPop { completions[ObjectIdentifier(viewController)] = onPop }
    }

    func setStack(_ viewControllers: [UIViewController], animated: Bool) {
        setStackCalls += 1
        stack = viewControllers
    }

    func popToRoot(animated: Bool) {
        while stack.count > 1 { popTop() }
    }

    func present(_ viewController: UIViewController, animated: Bool, onDismiss: (() -> Void)?) {
        if let onDismiss { completions[ObjectIdentifier(viewController)] = onDismiss }
    }

    func dismiss(_ viewController: UIViewController, animated: Bool) {
        completions.removeValue(forKey: ObjectIdentifier(viewController))?()
    }

    // Test helpers

    func popTop() {
        guard let top = stack.popLast() else { return }
        completions.removeValue(forKey: ObjectIdentifier(top))?()
    }

    func tapFirstAvatar() {
        guard let feed = stack.first as? FeedViewController else { return XCTFail("feed not at root") }
        feed.loadViewIfNeeded()
        let cell = feed.tableView(feed.tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as! PostCell
        cell.card.onAvatarTap?()
    }
}
