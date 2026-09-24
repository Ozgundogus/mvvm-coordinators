import UIKit

final class MediaPickerViewController: UICollectionViewController {
    private let viewModel: MediaPickerViewModel
    private static let reuseIdentifier = "MediaCell"

    init(viewModel: MediaPickerViewModel) {
        self.viewModel = viewModel
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 110, height: 110)
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        super.init(collectionViewLayout: layout)
        title = "Choose a photo"
    }

    required init?(coder: NSCoder) { fatalError("not used") }

    deinit { LeakDetector.shared.didDeinit(self) }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .systemBackground
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: Self.reuseIdentifier)
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { viewModel.seeds.count }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Self.reuseIdentifier, for: indexPath)
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        let image = PostImageView()
        image.configure(seed: viewModel.seeds[indexPath.item])
        cell.contentView.addSubview(image)
        NSLayoutConstraint.activate([
            image.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
            image.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
            image.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
            image.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
        ])
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.pick(at: indexPath.item)
    }
}
