import Combine
import Foundation

final class FeedViewModel {
    @Published private(set) var posts: [Post] = []

    var onSelectPost: ((Post) -> Void)?
    var onSelectAuthor: ((User) -> Void)?
    var onCompose: (() -> Void)?

    private let repository: PostRepository

    init(repository: PostRepository) {
        self.repository = repository
    }

    deinit { LeakDetector.shared.didDeinit(self) }

    func load() {
        posts = repository.posts
    }

    func selectPost(at index: Int) {
        guard posts.indices.contains(index) else { return }
        onSelectPost?(posts[index])
    }

    func selectAuthor(at index: Int) {
        guard posts.indices.contains(index) else { return }
        onSelectAuthor?(posts[index].author)
    }

    func composeTapped() { onCompose?() }
}
