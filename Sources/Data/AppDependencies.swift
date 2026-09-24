import Foundation

struct AppDependencies {
    let posts: PostRepository
    let auth: AuthService
    let session: SessionStore
    let preferences: Preferences
    let leakSettings: LeakSettings

    static func live() -> AppDependencies {
        let posts = SamplePostRepository()
        return AppDependencies(
            posts: posts,
            auth: FakeAuthService(accounts: posts.users),
            session: SessionStore(),
            preferences: UserDefaultsPreferences(),
            leakSettings: LeakSettings()
        )
    }
}
