import UIKit

struct User: Hashable {
    let id: Int
    let name: String
    let handle: String
    let color: UIColor
    let bio: String

    var initials: String {
        name.split(separator: " ").compactMap(\.first).map(String.init).joined()
    }
}

struct Post: Hashable {
    let id: Int
    let author: User
    let text: String
    let minutesAgo: Int
    let likes: Int
    let comments: Int
    let hasImage: Bool

    var relativeTime: String {
        minutesAgo < 60 ? "\(minutesAgo)m" : "\(minutesAgo / 60)h"
    }
}

struct Comment: Hashable {
    let id: Int
    let author: User
    let text: String
    let minutesAgo: Int
}
