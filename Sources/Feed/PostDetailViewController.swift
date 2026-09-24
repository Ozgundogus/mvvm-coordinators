import UIKit

final class PostDetailViewController: UIViewController {
    var onShowComments: (() -> Void)?
    var onSelectAuthor: (() -> Void)?
    var onReply: (() -> Void)?
    private let post: Post

    init(post: Post) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
        title = "Post"
        navigationItem.largeTitleDisplayMode = .never
    }

    required init?(coder: NSCoder) { fatalError("not used") }

    deinit { LeakDetector.shared.didDeinit(self) }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground

        let card = PostCardView()
        card.configure(with: post)
        card.onAvatarTap = { [weak self] in self?.onSelectAuthor?() }

        let comments = UIButton.filled("\(post.comments) comments", symbol: "bubble.left.and.bubble.right") { [weak self] in self?.onShowComments?() }
        let reply = UIButton.tinted("Reply", symbol: "arrowshape.turn.up.left") { [weak self] in self?.onReply?() }
        let actions = UIStackView(arrangedSubviews: [comments, reply])
        actions.spacing = 12
        actions.distribution = .fillEqually

        let stack = UIStackView(arrangedSubviews: [card, actions])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
}
