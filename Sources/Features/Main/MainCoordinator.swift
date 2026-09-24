import UIKit

final class MainCoordinator: BaseCoordinator, Coordinator {
    let tabBar = UITabBarController()

    private let feed: FeedCoordinator
    private let profile: ProfileCoordinator
    private let leakLab: LeakLabCoordinator
    private let navigations: [UINavigationController]

    init(session: Session, dependencies: AppDependencies) {
        let feedNav = Self.makeNavigation("Feed", "rectangle.stack")
        let profileNav = Self.makeNavigation("Profile", "person.crop.circle")
        let labNav = Self.makeNavigation("Leak Lab", "flask")
        navigations = [feedNav, profileNav, labNav]

        feed = FeedCoordinator(router: Router(navigationController: feedNav),
                               repository: dependencies.posts,
                               session: dependencies.session,
                               auth: dependencies.auth)
        profile = ProfileCoordinator(user: session.user,
                                     router: Router(navigationController: profileNav),
                                     repository: dependencies.posts,
                                     session: dependencies.session,
                                     auth: dependencies.auth,
                                     embedded: false)
        leakLab = LeakLabCoordinator(router: Router(navigationController: labNav),
                                     repository: dependencies.posts,
                                     settings: dependencies.leakSettings)
        super.init()
    }

    func start() {
        for child in [feed, profile, leakLab] as [Coordinator] {
            addChild(child)
            child.start()
        }
        tabBar.viewControllers = navigations
    }

    func handle(_ link: DeepLink, animated: Bool) {
        switch link {
        case .post, .comments:
            tabBar.selectedIndex = 0
            feed.handle(link, animated: animated)
        case .profile:
            tabBar.selectedIndex = 1
        }
    }

    func reproduce(_ scenario: LeakScenario) {
        tabBar.selectedIndex = 2
        leakLab.reproduce(scenario)
    }

    func open(_ screen: LaunchArguments.Screen) {
        switch screen {
        case .compose: feed.openCompose(showPicker: false)
        case .picker: feed.openCompose(showPicker: true)
        }
    }

    private static func makeNavigation(_ title: String, _ symbol: String) -> UINavigationController {
        let nav = UINavigationController()
        nav.navigationBar.prefersLargeTitles = true
        nav.tabBarItem = UITabBarItem(title: title, image: UIImage(systemName: symbol), tag: 0)
        return nav
    }
}
