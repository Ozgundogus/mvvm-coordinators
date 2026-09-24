import UIKit
import UserNotifications

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default", sessionRole: connectingSceneSession.role)
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    /// A notification tap is a deep link with extra steps. It goes to the same
    /// place a URL does.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse) async {
        guard let link = DeepLink(userInfo: response.notification.request.content.userInfo) else { return }
        let scene = UIApplication.shared.connectedScenes.first { $0.activationState == .foregroundActive } ?? UIApplication.shared.connectedScenes.first
        (scene?.delegate as? SceneDelegate)?.handle(link)
    }
}
