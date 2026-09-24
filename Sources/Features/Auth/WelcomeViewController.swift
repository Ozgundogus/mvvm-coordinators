import UIKit

final class WelcomeViewController: UIViewController {
    private let viewModel: WelcomeViewModel

    init(viewModel: WelcomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("not used") }

    deinit { LeakDetector.shared.didDeinit(self) }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationController?.setNavigationBarHidden(true, animated: false)

        let mark = UIImageView(image: UIImage(systemName: "point.3.connected.trianglepath.dotted"))
        mark.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 64, weight: .thin)
        mark.tintColor = .tintColor

        let title = UILabel()
        title.text = viewModel.title
        title.font = .systemFont(ofSize: 34, weight: .bold)

        let subtitle = UILabel()
        subtitle.text = viewModel.subtitle
        subtitle.font = .preferredFont(forTextStyle: .body)
        subtitle.textColor = .secondaryLabel
        subtitle.numberOfLines = 0
        subtitle.textAlignment = .center

        let button = UIButton.filled(viewModel.buttonTitle, symbol: "arrow.right") { [weak self] in self?.viewModel.continueTapped() }

        let stack = UIStackView(arrangedSubviews: [mark, title, subtitle, button])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 18
        stack.setCustomSpacing(36, after: subtitle)
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
        ])
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}
