import Combine
import Foundation

final class CommentsViewModel {
    let post: Post
    @Published private(set) var comments: [Comment] = []

    var onReply: (() -> Void)?
    var onSelectAuthor: ((User) -> Void)?

    private let repository: PostRepository

    init(post: Post, repository: PostRepository) {
        self.post = post
        self.repository = repository
    }

    deinit { LeakDetector.shared.didDeinit(self) }

    var header: String { "On “\(post.text.prefix(48))…”" }

    func load() {
        comments = repository.comments(for: post)
    }

    func replyTapped() { onReply?() }

    func selectComment(at index: Int) {
        guard comments.indices.contains(index) else { return }
        onSelectAuthor?(comments[index].author)
    }
}
