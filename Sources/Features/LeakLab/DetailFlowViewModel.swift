import Combine
import Foundation

final class DetailFlowViewModel {
    let post: Post
    @Published private(set) var likes: Int
    @Published private(set) var isLiked = false

    var onShowComments: (() -> Void)?

    init(post: Post) {
        self.post = post
        self.likes = post.likes
    }

    deinit { LeakDetector.shared.didDeinit(self) }

    func toggleLike() {
        isLiked.toggle()
        likes += isLiked ? 1 : -1
    }

    func showCommentsTapped() { onShowComments?() }
}
