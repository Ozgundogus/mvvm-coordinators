import XCTest
@testable import CoordinatorsDemo

final class AppCoordinatorTests: XCTestCase {

    func testFirstLaunchStartsWithOnboardingThenAuth() {
        let dependencies = AppDependencies.test(onboardingDone: false)
        let window = UIWindow()
        let app = AppCoordinator(window: window, dependencies: dependencies, launch: LaunchArguments())
        app.start()
        XCTAssertTrue(app.children.first is OnboardingCoordinator)

        let navigation = window.rootViewController as! UINavigationController
        let onboarding = navigation.viewControllers.first as! OnboardingViewController
        onboarding.viewModel.skip()

        XCTAssertTrue(dependencies.preferences.hasCompletedOnboarding)
        XCTAssertTrue(app.children.first is AuthCoordinator)
        XCTAssertEqual(app.children.count, 1)
    }

    func testSignInSwapsAuthForMain() {
        let dependencies = AppDependencies.test()
        let app = AppCoordinator(window: UIWindow(), dependencies: dependencies, launch: LaunchArguments())
        app.start()
        let auth = app.children.first as! AuthCoordinator

        auth.delegate?.authCoordinator(auth, didSignIn: Session(user: dependencies.posts.users[0], token: "t"))

        XCTAssertEqual(app.children.count, 1)
        XCTAssertTrue(app.children.first is MainCoordinator)
    }

    func testSignOutTearsDownTheWholeTree() {
        let dependencies = AppDependencies.test(signedInAs: SamplePostRepository().users[0])
        let app = AppCoordinator(window: UIWindow(), dependencies: dependencies, launch: LaunchArguments())
        app.start()
        weak var main = app.children.first as? MainCoordinator
        XCTAssertNotNil(main)

        dependencies.session.end()

        XCTAssertEqual(app.children.count, 1)
        XCTAssertTrue(app.children.first is AuthCoordinator)
        XCTAssertNil(main, "nothing should hold the retired tree")
    }

    func testDeepLinkOnColdStartWaitsForSignIn() {
        let dependencies = AppDependencies.test()
        let app = AppCoordinator(window: UIWindow(), dependencies: dependencies, launch: LaunchArguments())
        app.start()
        app.handle(.comments(postID: 103))
        XCTAssertTrue(app.children.first is AuthCoordinator, "link is parked, not handled")

        dependencies.session.start(Session(user: dependencies.posts.users[0], token: "t"))

        let main = app.children.first as! MainCoordinator
        XCTAssertEqual(main.tabBar.selectedIndex, 0)
        let feedNav = main.tabBar.viewControllers?.first as! UINavigationController
        RunLoop.current.run(until: Date().addingTimeInterval(0.1))
        XCTAssertEqual(feedNav.viewControllers.count, 3, "feed, post, comments")
        XCTAssertTrue(feedNav.viewControllers.last is CommentsViewController)
    }
}
