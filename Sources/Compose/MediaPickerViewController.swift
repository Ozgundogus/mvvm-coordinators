import UIKit

final class MediaPickerViewController: UICollectionViewController {
    var onPick: ((Int) -> Void)?
    private static let reuseIdentifier = "MediaCell"

    init() {
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

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { 12 }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Self.reuseIdentifier, for: indexPath)
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        let image = PostImageView()
        image.configure(seed: Self.seed(for: indexPath))
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
        onPick?(Self.seed(for: indexPath))
    }

    private static func seed(for indexPath: IndexPath) -> Int { indexPath.item * 3 + 1 }
}
