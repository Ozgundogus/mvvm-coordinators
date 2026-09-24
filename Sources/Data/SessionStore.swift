import Combine
import Foundation

/// Who is signed in. `AppCoordinator` observes this and swaps the root.
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
