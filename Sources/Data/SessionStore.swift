import Combine
import Foundation

/// The single source of truth for "who is signed in". `AppCoordinator` observes it
/// and swaps the root when it changes; nobody else touches the window.
final class SessionStore {
    @Published private(set) var session: Session?

    init(session: Session? = nil) {
        self.session = session
    }

    func start(_ session: Session) {
        self.session = session
    }

    func end() {
        session = nil
    }
}
