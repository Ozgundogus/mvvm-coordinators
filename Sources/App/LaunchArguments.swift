import Foundation

///   -autoLogin YES
///   -onboarding YES
///   -deeplink coordinators://post/103/comments
///   -screen compose | picker
///   -leak forgetChild | closureCycle | subscriptionCycle | retainedSlot | signOut
struct LaunchArguments {
    enum Screen: String { case compose, picker }

    var autoLogin: Bool
    var forceOnboarding: Bool
    var deepLink: DeepLink?
    var screen: Screen?
    var leak: LeakScenario?

    init(autoLogin: Bool = false, forceOnboarding: Bool = false, deepLink: DeepLink? = nil, screen: Screen? = nil, leak: LeakScenario? = nil) {
        self.autoLogin = autoLogin
        self.forceOnboarding = forceOnboarding
        self.deepLink = deepLink
        self.screen = screen
        self.leak = leak
    }

    init(defaults: UserDefaults) {
        deepLink = defaults.string(forKey: "deeplink").flatMap(URL.init(string:)).flatMap(DeepLink.init(url:))
        screen = defaults.string(forKey: "screen").flatMap(Screen.init(rawValue:))
        leak = defaults.string(forKey: "leak").flatMap(LeakScenario.init(rawValue:))
        forceOnboarding = defaults.bool(forKey: "onboarding")
        autoLogin = defaults.bool(forKey: "autoLogin") || screen != nil || leak != nil
    }
}
