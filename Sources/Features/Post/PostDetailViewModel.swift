import Foundation

final class PostDetailViewModel {
    let post: Post

    var onShowComments: (() -> Void)?
    var onSelectAuthor: ((User) -> Void)?
    var onReply: (() -> Void)?

    init(post: Post) {
        self.post = post
    }

    deinit { LeakDetector.shared.didDeinit(self) }

    var commentsButtonTitle: String { "\(post.comments) comments" }

    func showCommentsTapped() { onShowComments?() }
    func authorTapped() { onSelectAuthor?(post.author) }
    func replyTapped() { onReply?() }
}
