import UIKit

final class AppCoordinator: BaseCoordinator, Coordinator {
    private let window: UIWindow
    private let store: PostProviding
    private let launch: LaunchArguments
    private var main: MainCoordinator?
    private var pendingLink: DeepLink?

    /// Leak scenario: keep a reference to the retired tree on sign-out.
    private var keepOldTreeOnSignOut = false
    private var retiredTrees: [MainCoordinator] = []

    init(window: UIWindow, store: PostProviding, launch: LaunchArguments) {
        self.window = window
        self.store = store
        self.launch = launch
        super.init()
    }

    func start() {
        if launch.autoLogin {
            showMain(as: store.users[0])
            applyLaunchArguments()
        } else {
            showAuth(animated: false)
        }
    }

    func handle(_ link: DeepLink) {
        if let main {
            main.handle(link)
        } else {
            pendingLink = link      // cold start into auth: park it, deliver after sign-in
        }
    }

    // MARK: Root switching

    private func showAuth(animated: Bool) {
        let auth = AuthCoordinator(router: Router(navigationController: UINavigationController()), store: store)
        auth.delegate = self
        addChild(auth)
        auth.start()
        setRoot(auth.rootViewController, animated: animated)
    }

    private func showMain(as user: User) {
        let main = MainCoordinator(user: user, store: store)
        main.delegate = self
        main.leakLab.onKeepOldTreeToggled = { [weak self] keep in self?.keepOldTreeOnSignOut = keep }
        addChild(main)
        main.start()
        self.main = main
        setRoot(main.tabBar, animated: true)
        if let link = pendingLink {
            pendingLink = nil
            main.handle(link)
        }
    }

    private func setRoot(_ viewController: UIViewController, animated: Bool) {
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        if animated {
            UIView.transition(with: window, duration: 0.35, options: .transitionCrossDissolve, animations: nil)
        }
    }

    // MARK: Launch arguments (screenshots & leak reproduction)

    private func applyLaunchArguments() {
        if let link = launch.deepLink { handle(link) }
        if let screen = launch.screen { main?.feed.openComposeForScreenshot(showPicker: screen == .picker) }
        if let scenario = launch.leak { reproduce(scenario) }
    }

    private func reproduce(_ scenario: LeakScenario) {
        switch scenario {
        case .signOut:
            keepOldTreeOnSignOut = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                guard let self, let main = self.main else { return }
                self.mainDidSignOut(main)
            }
        default:
            main?.tabBar.selectedIndex = 2
            main?.leakLab.reproduce(scenario)
        }
    }
}

extension AppCoordinator: AuthCoordinatorDelegate {
    func authCoordinator(_ coordinator: AuthCoordinator, didSignIn user: User) {
        removeChild(coordinator)
        LeakDetector.shared.expectDeallocation(of: coordinator)
        showMain(as: user)
    }
}

extension AppCoordinator: MainCoordinatorDelegate {
    func mainDidSignOut(_ coordinator: MainCoordinator) {
        removeChild(coordinator)
        main = nil
        if keepOldTreeOnSignOut { retiredTrees.append(coordinator) }   // the leak
        LeakDetector.shared.expectDeallocation(of: coordinator)
        showAuth(animated: true)
    }
}
