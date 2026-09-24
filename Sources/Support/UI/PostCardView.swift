import UIKit

final class PostCardView: UIView {
    var onAvatarTap: (() -> Void)? {
        get { avatar.onTap }
        set { avatar.onTap = newValue }
    }

    private let avatar = AvatarView(size: 40)
    private let nameLabel = UILabel()
    private let metaLabel = UILabel()
    private let bodyLabel = UILabel()
    private let image = PostImageView()
    private let statsLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .secondarySystemGroupedBackground
        layer.cornerRadius = 18
        layer.cornerCurve = .continuous

        nameLabel.font = .preferredFont(forTextStyle: .headline)
        metaLabel.font = .preferredFont(forTextStyle: .subheadline)
        metaLabel.textColor = .secondaryLabel
        bodyLabel.font = .preferredFont(forTextStyle: .body)
        bodyLabel.numberOfLines = 0
        statsLabel.font = .preferredFont(forTextStyle: .footnote)
        statsLabel.textColor = .secondaryLabel

        let nameStack = UIStackView(arrangedSubviews: [nameLabel, metaLabel])
        nameStack.axis = .vertical
        nameStack.spacing = 1
        let header = UIStackView(arrangedSubviews: [avatar, nameStack])
        header.alignment = .center
        header.spacing = 12

        let stack = UIStackView(arrangedSubviews: [header, bodyLabel, image, statsLabel])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            image.heightAnchor.constraint(equalToConstant: 180),
        ])
    }

    required init?(coder: NSCoder) { fatalError("not used") }

    func configure(with post: Post) {
        avatar.configure(with: post.author)
        nameLabel.text = post.author.name
        metaLabel.text = "@\(post.author.handle) · \(post.relativeTime)"
        bodyLabel.text = post.text
        image.isHidden = !post.hasImage
        image.configure(seed: post.id)
        statsLabel.text = "♥ \(post.likes) likes  ·  \(post.comments) comments  ·  Share"
    }
}
