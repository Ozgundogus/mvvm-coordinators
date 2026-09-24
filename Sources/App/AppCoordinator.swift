import Combine
import UIKit

/// Owns the window and one child at a time; the session decides which.
final class AppCoordinator: BaseCoordinator, Coordinator {
    private let window: UIWindow
    private let dependencies: AppDependencies
    private let launch: LaunchArguments
    private var main: MainCoordinator?
    private var pendingLink: DeepLink?
    private var cancellables = Set<AnyCancellable>()

    private var retiredTrees: [MainCoordinator] = []

    init(window: UIWindow, dependencies: AppDependencies, launch: LaunchArguments) {
        self.window = window
        self.dependencies = dependencies
        self.launch = launch
        super.init()
    }

    func start() {
        if launch.autoLogin {
            dependencies.preferences.hasCompletedOnboarding = true
            dependencies.session.start(Session(user: dependencies.posts.users[0], token: "launch-argument"))
        }
        dependencies.session.$session
            .map { $0 }
            .removeDuplicates()
            .sink { [weak self] session in self?.route(for: session) }
            .store(in: &cancellables)
        applyLaunchArguments()
    }

    /// The one entry point for anything that arrives from outside: a URL, a
    /// notification tap, a launch argument. Warm app: routed now, animated. No
    /// signed-in app yet: parked, delivered once there is one.
    func handle(_ link: DeepLink) {
        if let main {
            main.handle(link, animated: true)
        } else {
            pendingLink = link
        }
    }

    // MARK: Root switching

    private func route(for session: Session?) {
        if let session {
            showMain(session)
        } else if launch.forceOnboarding || !dependencies.preferences.hasCompletedOnboarding {
            showOnboarding()
        } else {
            showAuth(animated: !children.isEmpty)
        }
    }

    private func showOnboarding() {
        let navigation = UINavigationController()
        navigation.isNavigationBarHidden = true
        let onboarding = OnboardingCoordinator(router: Router(navigationController: navigation),
                                               preferences: dependencies.preferences)
        onboarding.delegate = self
        swapRoot(to: onboarding, showing: navigation, animated: false)
    }

    private func showAuth(animated: Bool) {
        let navigation = UINavigationController()
        let auth = AuthCoordinator(router: Router(navigationController: navigation), auth: dependencies.auth)
        auth.delegate = self
        swapRoot(to: auth, showing: navigation, animated: animated)
    }

    private func showMain(_ session: Session) {
        let main = MainCoordinator(session: session, dependencies: dependencies)
        swapRoot(to: main, showing: main.tabBar, animated: true)
        self.main = main
        if let link = pendingLink {
            pendingLink = nil
            main.handle(link, animated: false)
        }
    }

    private func swapRoot(to child: Coordinator, showing root: UIViewController, animated: Bool) {
        let retired = children
        retired.forEach(removeChild)
        main = nil
        for old in retired {
            if let tree = old as? MainCoordinator, dependencies.leakSettings.isEnabled(.signOut) {
                retiredTrees.append(tree)   // the leak
            }
            LeakDetector.shared.expectDeallocation(of: old)
        }
        addChild(child)
        child.start()
        setRoot(root, animated: animated)
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
        if let screen = launch.screen { main?.open(screen) }
        if let scenario = launch.leak { reproduce(scenario) }
    }

    private func reproduce(_ scenario: LeakScenario) {
        switch scenario {
        case .signOut:
            dependencies.leakSettings.set(.signOut, enabled: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.dependencies.session.end()
            }
        default:
            main?.reproduce(scenario)
        }
    }
}

extension AppCoordinator: OnboardingCoordinatorDelegate {
    func onboardingDidFinish(_ coordinator: OnboardingCoordinator) {
        showAuth(animated: true)
    }
}

extension AppCoordinator: AuthCoordinatorDelegate {
    func authCoordinator(_ coordinator: AuthCoordinator, didSignIn session: Session) {
        dependencies.session.start(session)
    }
}
