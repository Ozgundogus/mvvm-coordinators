import Combine
import UIKit

final class OnboardingViewController: UIViewController {
    let viewModel: OnboardingViewModel
    private var cancellables = Set<AnyCancellable>()

    private let pageControl = UIPageControl()
    private var nextButton: UIButton!
    private var collectionView: UICollectionView!

    init(viewModel: OnboardingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("not used") }

    deinit { LeakDetector.shared.didDeinit(self) }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        buildLayout()
        bind()
    }

    private func bind() {
        viewModel.$currentIndex
            .sink { [weak self] index in self?.render(index: index) }
            .store(in: &cancellables)
    }

    private func render(index: Int) {
        pageControl.currentPage = index
        nextButton.configuration?.title = viewModel.buttonTitle
        nextButton.configuration?.image = UIImage(systemName: viewModel.isLastPage ? "checkmark" : "arrow.right")
        let visible = collectionView.indexPathsForVisibleItems.first?.item
        if visible != index {
            collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
        }
    }

    private func buildLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(OnboardingPageCell.self, forCellWithReuseIdentifier: OnboardingPageCell.reuseIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        pageControl.numberOfPages = viewModel.pages.count
        pageControl.pageIndicatorTintColor = .tertiaryLabel
        pageControl.currentPageIndicatorTintColor = .tintColor
        pageControl.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.viewModel.showPage(at: self.pageControl.currentPage)
        }, for: .valueChanged)

        nextButton = UIButton.filled("Next", symbol: "arrow.right") { [weak self] in self?.viewModel.advance() }
        let skip = UIButton(configuration: .plain(), primaryAction: UIAction(title: "Skip") { [weak self] _ in self?.viewModel.skip() })

        let footer = UIStackView(arrangedSubviews: [pageControl, nextButton, skip])
        footer.axis = .vertical
        footer.alignment = .center
        footer.spacing = 12
        footer.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(collectionView)
        view.addSubview(footer)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: footer.topAnchor, constant: -16),
            footer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            footer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            nextButton.widthAnchor.constraint(equalToConstant: 200),
        ])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize = collectionView.bounds.size
    }
}

extension OnboardingViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.pages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnboardingPageCell.reuseIdentifier, for: indexPath) as! OnboardingPageCell
        cell.configure(with: viewModel.pages[indexPath.item])
        return cell
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(round(scrollView.contentOffset.x / max(scrollView.bounds.width, 1)))
        viewModel.showPage(at: index)
    }
}

final class OnboardingPageCell: UICollectionViewCell {
    static let reuseIdentifier = "OnboardingPageCell"
    private let symbol = UIImageView()
    private let titleLabel = UILabel()
    private let bodyLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        symbol.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 72, weight: .thin)
        symbol.tintColor = .tintColor
        symbol.contentMode = .scaleAspectFit
        titleLabel.font = .systemFont(ofSize: 30, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        bodyLabel.font = .preferredFont(forTextStyle: .body)
        bodyLabel.textColor = .secondaryLabel
        bodyLabel.textAlignment = .center
        bodyLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [symbol, titleLabel, bodyLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 20
        stack.setCustomSpacing(36, after: symbol)
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -40),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 36),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -36),
        ])
    }

    required init?(coder: NSCoder) { fatalError("not used") }

    func configure(with page: OnboardingPage) {
        symbol.image = UIImage(systemName: page.symbol)
        titleLabel.text = page.title
        bodyLabel.text = page.body
    }
}
