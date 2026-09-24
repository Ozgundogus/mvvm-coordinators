import Foundation

protocol PostRepository: AnyObject {
    var users: [User] { get }
    var posts: [Post] { get }
    func post(id: Int) -> Post?
    func posts(by user: User) -> [Post]
    func comments(for post: Post) -> [Comment]
}

final class SamplePostRepository: PostRepository {
    let users: [User] = [
        User(id: 1, name: "Ada Lovelace", handle: "ada", avatar: .indigo, bio: "Writes programs for machines that don't exist yet."),
        User(id: 2, name: "Grace Hopper", handle: "grace", avatar: .teal, bio: "Nanoseconds, compilers, and one very famous moth."),
        User(id: 3, name: "Alan Turing", handle: "alan", avatar: .orange, bio: "Morphogenesis, machines, and long-distance running."),
        User(id: 4, name: "Margaret Hamilton", handle: "margaret", avatar: .pink, bio: "Priority scheduling, before it was called that."),
        User(id: 5, name: "Dennis Ritchie", handle: "dmr", avatar: .green, bio: "Made a language. Then made an OS in it."),
    ]

    private(set) lazy var posts: [Post] = [
        Post(id: 101, author: users[0], text: "The Analytical Engine weaves algebraic patterns just as the Jacquard loom weaves flowers and leaves. Shipping the loom part first.", minutesAgo: 4, likes: 128, comments: 12, hasImage: true),
        Post(id: 102, author: users[1], text: "If it's a good idea, go ahead and do it. It's much easier to apologize than it is to get permission.", minutesAgo: 22, likes: 341, comments: 27, hasImage: false),
        Post(id: 103, author: users[2], text: "We can only see a short distance ahead, but we can see plenty there that needs to be done. Starting with this retain cycle.", minutesAgo: 51, likes: 96, comments: 8, hasImage: true),
        Post(id: 104, author: users[3], text: "There was no choice but to be pioneers. Also no choice but to write the error handling nobody asked for.", minutesAgo: 90, likes: 210, comments: 19, hasImage: false),
        Post(id: 105, author: users[4], text: "UNIX is basically a simple operating system, but you have to be a genius to understand the simplicity.", minutesAgo: 180, likes: 402, comments: 33, hasImage: true),
        Post(id: 106, author: users[0], text: "Coordinators are like engines: the interesting part is who holds the crank.", minutesAgo: 240, likes: 57, comments: 4, hasImage: false),
        Post(id: 107, author: users[2], text: "A weak reference is a promise to let go. Most leaks are promises nobody made.", minutesAgo: 300, likes: 188, comments: 15, hasImage: false),
        Post(id: 108, author: users[1], text: "Humans are allergic to change. They love to say, 'We've always done it this way.' I try to fight that.", minutesAgo: 420, likes: 275, comments: 21, hasImage: true),
    ]

    private let commentLines = [
        "Pushed this to the detail flow and it came back clean. deinit fired.",
        "Does the child get removed if the sheet is swiped down? Asking for a coordinator.",
        "The router handling popToRoot is the part I always forget.",
        "Bookmarking this. Also, the moth story is true.",
        "Strong closure, strong opinions. One of them leaks.",
        "Deep link straight into comments worked on a cold start for me.",
    ]

    func post(id: Int) -> Post? { posts.first { $0.id == id } }

    func posts(by user: User) -> [Post] { posts.filter { $0.author.id == user.id } }

    func comments(for post: Post) -> [Comment] {
        let others = users.filter { $0.id != post.author.id }
        return commentLines.enumerated().map { index, line in
            Comment(id: post.id * 10 + index, author: others[index % others.count], text: line, minutesAgo: (index + 1) * 7)
        }
    }
}
