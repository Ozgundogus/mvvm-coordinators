import Foundation

enum AuthError: LocalizedError, Equatable {
    case accountLocked(handle: String)

    var errorDescription: String? {
        switch self {
        case .accountLocked(let handle): return "@\(handle) is locked. Try another account."
        }
    }
}

protocol AuthService: AnyObject {
    var accounts: [User] { get }
    func signIn(as user: User) async throws -> Session
    func signOut(_ session: Session) async
}

/// Takes a moment like a network call; one account always fails.
final class FakeAuthService: AuthService {
    let accounts: [User]
    private let lockedHandle: String?
    private let delay: Duration

    init(accounts: [User], lockedHandle: String? = "dmr", delay: Duration = .milliseconds(600)) {
        self.accounts = accounts
        self.lockedHandle = lockedHandle
        self.delay = delay
    }

    func signIn(as user: User) async throws -> Session {
        try await Task.sleep(for: delay)
        if user.handle == lockedHandle { throw AuthError.accountLocked(handle: user.handle) }
        return Session(user: user, token: UUID().uuidString)
    }

    func signOut(_ session: Session) async {
        try? await Task.sleep(for: delay / 2)
    }
}
