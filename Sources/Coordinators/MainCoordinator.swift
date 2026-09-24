import UIKit

protocol MainCoordinatorDelegate: AnyObject {
    func mainDidSignOut(_ coordinator: MainCoordinator)
}

final class MainCoordinator: BaseCoordinator, Coordinator {
    let tabBar = UITabBarController()
    weak var delegate: MainCoordinatorDelegate?

    let feed: FeedCoordinator
    let profile: ProfileCoordinator
    let leakLab: LeakLabCoordinator

    init(user: User, store: PostProviding) {
        feed = FeedCoordinator(router: Router(navigationController: Self.makeNavigation("Feed", "rectangle.stack")), store: store)
        profile = ProfileCoordinator(user: user, router: Router(navigationController: Self.makeNavigation("Profile", "person.crop.circle")), store: store, embedded: false)
        leakLab = LeakLabCoordinator(router: Router(navigationController: Self.makeNavigation("Leak Lab", "flask")), store: store)
        super.init()
    }

    func start() {
        profile.onSignOut = { [weak self] in
            guard let self else { return }
            self.delegate?.mainDidSignOut(self)
        }
        for child in [feed, profile, leakLab] as [Coordinator] {
            addChild(child)
            child.start()
        }
        tabBar.viewControllers = [feed.navigationController, profile.navigationController, leakLab.navigationController]
    }

    func handle(_ link: DeepLink) {
        switch link {
        case .post, .comments:
            tabBar.selectedIndex = 0
            feed.handle(link)
        case .profile:
            tabBar.selectedIndex = 1
        }
    }

    private static func makeNavigation(_ title: String, _ symbol: String) -> UINavigationController {
        let nav = UINavigationController()
        nav.navigationBar.prefersLargeTitles = true
        nav.tabBarItem = UITabBarItem(title: title, image: UIImage(systemName: symbol), tag: 0)
        return nav
    }
}
