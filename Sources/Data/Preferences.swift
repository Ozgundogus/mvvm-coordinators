import Foundation

protocol Preferences: AnyObject {
    var hasCompletedOnboarding: Bool { get set }
}

final class UserDefaultsPreferences: Preferences {
    private let defaults: UserDefaults
    private let onboardingKey = "hasCompletedOnboarding"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var hasCompletedOnboarding: Bool {
        get { defaults.bool(forKey: onboardingKey) }
        set { defaults.set(newValue, forKey: onboardingKey) }
    }
}

final class InMemoryPreferences: Preferences {
    var hasCompletedOnboarding: Bool

    init(hasCompletedOnboarding: Bool = false) {
        self.hasCompletedOnboarding = hasCompletedOnboarding
    }
}
