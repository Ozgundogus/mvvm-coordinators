@testable import CoordinatorsDemo

extension AppDependencies {
    /// Everything in memory, sign-in instant, nothing locked.
    static func test(signedInAs user: User? = nil, onboardingDone: Bool = true) -> AppDependencies {
        let posts = SamplePostRepository()
        return AppDependencies(
            posts: posts,
            auth: FakeAuthService(accounts: posts.users, lockedHandle: nil, delay: .zero),
            session: SessionStore(session: user.map { Session(user: $0, token: "test") }),
            preferences: InMemoryPreferences(hasCompletedOnboarding: onboardingDone),
            leakSettings: LeakSettings()
        )
    }
}
