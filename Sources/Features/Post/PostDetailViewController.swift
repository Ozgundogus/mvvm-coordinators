import UIKit

final class PostDetailViewController: UIViewController {
    private let viewModel: PostDetailViewModel

    init(viewModel: PostDetailViewModel) {
        self.viewModel = viewModel
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
        card.configure(with: viewModel.post)
        card.onAvatarTap = { [weak self] in self?.viewModel.authorTapped() }

        let comments = UIButton.filled(viewModel.commentsButtonTitle, symbol: "bubble.left.and.bubble.right") { [weak self] in self?.viewModel.showCommentsTapped() }
        let reply = UIButton.tinted("Reply", symbol: "arrowshape.turn.up.left") { [weak self] in self?.viewModel.replyTapped() }
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
