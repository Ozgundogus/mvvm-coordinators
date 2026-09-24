import Foundation

/// coordinators://post/103
/// coordinators://post/103/comments
/// coordinators://profile
enum DeepLink: Equatable {
    case post(id: Int)
    case comments(postID: Int)
    case profile

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
