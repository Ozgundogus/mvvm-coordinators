import Combine
import Foundation

final class ProfileViewModel {
    let user: User
    let showsSignOut: Bool
    @Published private(set) var posts: [Post] = []
    @Published private(set) var isSigningOut = false

    var onSelectPost: ((Post) -> Void)?

    private let repository: PostRepository
    private let session: SessionStore
    private let auth: AuthService
    private var task: Task<Void, Never>?

    init(user: User, repository: PostRepository, session: SessionStore, auth: AuthService, showsSignOut: Bool) {
        self.user = user
        self.repository = repository
        self.session = session
        self.auth = auth
        self.showsSignOut = showsSignOut
    }

    deinit {
        task?.cancel()
        LeakDetector.shared.didDeinit(self)
    }

    var title: String { showsSignOut ? "Profile" : user.name }
    var handle: String { "@\(user.handle)" }
    var stats: String { "\(posts.count) posts · \(posts.reduce(0) { $0 + $1.likes }) likes" }

    func load() {
        posts = repository.posts(by: user)
    }

    func selectPost(at index: Int) {
        guard posts.indices.contains(index) else { return }
        onSelectPost?(posts[index])
    }

    /// Ends the session. Nobody here touches navigation: `AppCoordinator` sees the
    /// session go nil and swaps the root.
    func signOut() {
        guard !isSigningOut, let current = session.session else { return }
        isSigningOut = true
        task = Task { [weak self] in
            guard let self else { return }
            await self.auth.signOut(current)
            await MainActor.run {
                self.isSigningOut = false
                self.session.end()
            }
        }
    }
}
