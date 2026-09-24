import Combine
import Foundation

final class SignInViewModel {
    enum State: Equatable {
        case idle
        case signingIn(User)
        case failed(String)
    }

    let accounts: [User]
    @Published private(set) var state: State = .idle

    var onSignedIn: ((Session) -> Void)?

    private let auth: AuthService
    private var task: Task<Void, Never>?

    init(auth: AuthService) {
        self.auth = auth
        self.accounts = auth.accounts
    }

    deinit { task?.cancel() }

    func signIn(as user: User) {
        guard case .idle = state else { return }
        state = .signingIn(user)
        task = Task { [weak self] in
            guard let self else { return }
            do {
                let session = try await self.auth.signIn(as: user)
                await MainActor.run {
                    self.state = .idle
                    self.onSignedIn?(session)
                }
            } catch {
                await MainActor.run {
                    self.state = .failed(error.localizedDescription)
                }
            }
        }
    }

    func dismissError() {
        if case .failed = state { state = .idle }
    }
}
