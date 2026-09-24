import XCTest
@testable import CoordinatorsDemo

/// Coordinators depend on `Routing`, not on UIKit navigation, so these tests run
/// the real flows with a fake router: no simulator screen, every pop a function call.
final class CoordinatorTests: XCTestCase {
    private var dependencies: AppDependencies!

    override func setUp() {
        super.setUp()
        dependencies = .test()
    }

    private func makeFeed(router: FakeRouter) -> FeedCoordinator {
        FeedCoordinator(router: router, repository: dependencies.posts, session: dependencies.session, auth: dependencies.auth)
    }

    // MARK: Ownership

    func testChildIsRemovedWhenItsScreenPops() {
        let router = FakeRouter()
        let feed = makeFeed(router: router)
        feed.start()

        router.tapFirstAvatar()
        XCTAssertEqual(feed.children.count, 1)
        XCTAssertTrue(feed.children.first is ProfileCoordinator)

        router.popTop()
        XCTAssertEqual(feed.children.count, 0, "child must be removed when its screen leaves the stack")
    }

    func testModalChildIsRemovedWhenSheetIsSwipedDown() {
        let router = FakeRouter()
        let feed = makeFeed(router: router)
        feed.start()

        let screen = router.stack.first as! FeedViewController
        screen.loadViewIfNeeded()
        screen.viewModel.composeTapped()
        XCTAssertTrue(feed.children.first is ComposeCoordinator)
        XCTAssertNotNil(router.presented)

        router.swipeDownPresented()
        XCTAssertEqual(feed.children.count, 0, "swipe-to-dismiss must end the flow like Cancel does")
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
        let feed = makeFeed(router: router)
        feed.start()

        feed.handle(.comments(postID: 103))

        XCTAssertEqual(router.setStackCalls, 2, "start + one deep link")
        XCTAssertEqual(router.stack.count, 3, "feed, post, comments")
        XCTAssertTrue(router.stack[1] is PostDetailViewController)
        XCTAssertTrue(router.stack[2] is CommentsViewController)
        XCTAssertEqual(router.pushCalls, 0, "no chained pushes, no delays")
    }
}
