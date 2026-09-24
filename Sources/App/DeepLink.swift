import Foundation

/// coordinators://post/103
/// coordinators://post/103/comments
/// coordinators://profile
enum DeepLink: Equatable {
    case post(id: Int)
    case comments(postID: Int)
    case profile

    /// A push notification carries the same thing under a key.
    init?(userInfo: [AnyHashable: Any]) {
        guard let raw = userInfo["link"] as? String, let url = URL(string: raw) else { return nil }
        self.init(url: url)
    }

    init?(url: URL) {
        guard url.scheme == "coordinators" else { return nil }
        let parts = url.pathComponents.filter { $0 != "/" }
        switch url.host {
        case "profile":
            self = .profile
        case "post":
            guard let first = parts.first, let id = Int(first) else { return nil }
            switch parts.dropFirst().first {
            case nil: self = .post(id: id)
            case "comments": self = .comments(postID: id)
            default: return nil
            }
        default:
            return nil
        }
    }
}
