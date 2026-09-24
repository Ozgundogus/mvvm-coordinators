import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var appCoordinator: AppCoordinator?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        let coordinator = AppCoordinator(window: window,
                                         dependencies: .live(),
                                         launch: LaunchArguments(defaults: .standard))
        appCoordinator = coordinator
        self.window = window
        coordinator.start()

        if let url = connectionOptions.urlContexts.first?.url, let link = DeepLink(url: url) {
            coordinator.handle(link)
        }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url, let link = DeepLink(url: url) else { return }
        handle(link)
    }

    func handle(_ link: DeepLink) {
        appCoordinator?.handle(link)
    }
}
