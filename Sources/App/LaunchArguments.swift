import Foundation

///   -autoLogin YES
///   -deeplink coordinators://post/103/comments
///   -screen compose | picker
///   -leak forgetChild | closureCycle | retainedSlot | signOut
struct LaunchArguments {
    let autoLogin: Bool
    let deepLink: DeepLink?
    let screen: Screen?
    let leak: LeakScenario?

    enum Screen: String { case compose, picker }

    init(defaults: UserDefaults = .standard) {
        deepLink = defaults.string(forKey: "deeplink").flatMap(URL.init(string:)).flatMap(DeepLink.init(url:))
        screen = defaults.string(forKey: "screen").flatMap(Screen.init(rawValue:))
        leak = defaults.string(forKey: "leak").flatMap(LeakScenario.init(rawValue:))
        autoLogin = defaults.bool(forKey: "autoLogin") || deepLink != nil || screen != nil || leak != nil
    }
}
