import UIKit

final class AvatarView: UIView {
    private let label = UILabel()
    var onTap: (() -> Void)?

    init(size: CGFloat) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = size / 2
        clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: size * 0.38, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        addSubview(label)
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: size),
            heightAnchor.constraint(equalToConstant: size),
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
    }

    required init?(coder: NSCoder) { fatalError("not used") }

    func configure(with user: User) {
        backgroundColor = user.avatar.uiColor
        label.text = user.initials
    }

    @objc private func tapped() { onTap?() }
}
