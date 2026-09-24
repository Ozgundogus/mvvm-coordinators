import Combine
import Foundation

final class ComposeViewModel {
    static let limit = 280

    let replyingTo: Post?
    @Published var text: String
    @Published private(set) var attachmentSeed: Int?

    var onDone: (() -> Void)?
    var onAttach: (() -> Void)?

    init(replyingTo: Post?, draft: String = "") {
        self.replyingTo = replyingTo
        self.text = draft
    }

    deinit { LeakDetector.shared.didDeinit(self) }

    var title: String { replyingTo == nil ? "New post" : "Reply" }

    var context: String {
        replyingTo.map { "Replying to @\($0.author.handle): “\($0.text.prefix(60))…”" } ?? "Share something with the feed"
    }

    var counter: String { "\(text.count) / \(Self.limit)" }
    var canPost: Bool { !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && text.count <= Self.limit }

    func attach(seed: Int) { attachmentSeed = seed }
    func attachTapped() { onAttach?() }
    func cancel() { onDone?() }

    func post() {
        guard canPost else { return }
        onDone?()
    }
}
