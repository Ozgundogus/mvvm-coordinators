import Combine
import UIKit

final class ComposeViewController: UIViewController {
    private let viewModel: ComposeViewModel
    private var cancellables = Set<AnyCancellable>()
    private let textView = UITextView()
    private let attachment = PostImageView()
    private let counter = UILabel()
    private let postButton: UIBarButtonItem

    init(viewModel: ComposeViewModel) {
        self.viewModel = viewModel
        self.postButton = UIBarButtonItem(title: "Post")
        super.init(nibName: nil, bundle: nil)
        title = viewModel.title
        navigationItem.leftBarButtonItem = UIBarButtonItem(systemItem: .cancel, primaryAction: UIAction { [weak self] _ in self?.viewModel.cancel() })
        postButton.style = .done
        postButton.primaryAction = UIAction(title: "Post") { [weak self] _ in self?.viewModel.post() }
        navigationItem.rightBarButtonItem = postButton
    }

    required init?(coder: NSCoder) { fatalError("not used") }

    deinit { LeakDetector.shared.didDeinit(self) }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let context = UILabel()
        context.font = .preferredFont(forTextStyle: .footnote)
        context.textColor = .secondaryLabel
        context.numberOfLines = 2
        context.text = viewModel.context

        textView.font = .preferredFont(forTextStyle: .title3)
        textView.delegate = self
        textView.text = viewModel.text
        attachment.isHidden = true
        counter.font = .preferredFont(forTextStyle: .caption1)
        counter.textColor = .secondaryLabel

        let attach = UIButton.tinted("Add photo", symbol: "photo") { [weak self] in self?.viewModel.attachTapped() }
        let bar = UIStackView(arrangedSubviews: [attach, UIView(), counter])
        bar.alignment = .center

        let stack = UIStackView(arrangedSubviews: [context, textView, attachment, bar])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.heightAnchor.constraint(equalToConstant: 160),
            attachment.heightAnchor.constraint(equalToConstant: 160),
        ])

        viewModel.$text
            .sink { [weak self] _ in
                guard let self else { return }
                self.counter.text = self.viewModel.counter
                self.postButton.isEnabled = self.viewModel.canPost
            }
            .store(in: &cancellables)
        viewModel.$attachmentSeed
            .sink { [weak self] seed in
                guard let self else { return }
                if let seed { self.attachment.configure(seed: seed) }
                self.attachment.isHidden = seed == nil
            }
            .store(in: &cancellables)
    }
}

extension ComposeViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        viewModel.text = textView.text
    }
}
