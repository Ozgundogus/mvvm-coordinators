import Combine
import UIKit

/// With `strongSubscription` the `sink` captures `self` and the screen never deinits.
final class DetailFlowViewController: UIViewController {
    private let viewModel: DetailFlowViewModel
    private let strongSubscription: Bool
    private var cancellables = Set<AnyCancellable>()
    private var likeButton: UIButton!

    init(viewModel: DetailFlowViewModel, strongSubscription: Bool) {
        self.viewModel = viewModel
        self.strongSubscription = strongSubscription
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
        likeButton = UIButton.tinted("Like", symbol: "heart") { [weak self] in self?.viewModel.toggleLike() }
        let comments = UIButton.filled("Comments", symbol: "bubble.left.and.bubble.right") { [weak self] in self?.viewModel.showCommentsTapped() }
        let actions = UIStackView(arrangedSubviews: [likeButton, comments])
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

        if strongSubscription {
            viewModel.$likes
                .sink { _ in self.render() }
                .store(in: &cancellables)
        } else {
            viewModel.$likes
                .sink { [weak self] _ in self?.render() }
                .store(in: &cancellables)
        }
    }

    private func render() {
        likeButton.configuration?.title = viewModel.isLiked ? "Liked · \(viewModel.likes)" : "Like · \(viewModel.likes)"
        likeButton.configuration?.image = UIImage(systemName: viewModel.isLiked ? "heart.fill" : "heart")
    }
}
