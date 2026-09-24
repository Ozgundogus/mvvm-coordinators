import UIKit

final class ComposeViewController: UIViewController {
    var onDone: (() -> Void)?
    var onAttach: (() -> Void)?
    private let replyingTo: Post?
    private let textView = UITextView()
    private let attachment = PostImageView()
    private let counter = UILabel()

    init(replyingTo: Post?) {
        self.replyingTo = replyingTo
        super.init(nibName: nil, bundle: nil)
        title = replyingTo == nil ? "New post" : "Reply"
        navigationItem.leftBarButtonItem = UIBarButtonItem(systemItem: .cancel, primaryAction: UIAction { [weak self] _ in self?.onDone?() })
        let post = UIBarButtonItem(title: "Post", primaryAction: UIAction { [weak self] _ in self?.onDone?() })
        post.style = .done
        navigationItem.rightBarButtonItem = post
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
        context.text = replyingTo.map { "Replying to @\($0.author.handle): “\($0.text.prefix(60))…”" } ?? "Share something with the feed"

        textView.font = .preferredFont(forTextStyle: .title3)
        textView.delegate = self
        textView.text = "The router's onPop is the part I always forget. Writing it down this time."
        attachment.isHidden = true
        counter.font = .preferredFont(forTextStyle: .caption1)
        counter.textColor = .secondaryLabel
        updateCounter()

        let attach = UIButton.tinted("Add photo", symbol: "photo") { [weak self] in self?.onAttach?() }
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
    }

    func attach(seed: Int) {
        attachment.configure(seed: seed)
        attachment.isHidden = false
    }

    private func updateCounter() {
        counter.text = "\(textView.text.count) / 280"
    }
}

extension ComposeViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) { updateCounter() }
}
