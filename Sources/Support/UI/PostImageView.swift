import UIKit

/// A gradient stand-in for a photo, so the demo needs no image assets.
final class PostImageView: UIView {
    private let gradient = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 14
        clipsToBounds = true
        layer.addSublayer(gradient)
        let icon = UIImageView(image: UIImage(systemName: "photo.on.rectangle.angled"))
        icon.tintColor = UIColor.white.withAlphaComponent(0.85)
        icon.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 34, weight: .light)
        icon.translatesAutoresizingMaskIntoConstraints = false
        addSubview(icon)
        NSLayoutConstraint.activate([
            icon.centerXAnchor.constraint(equalTo: centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    required init?(coder: NSCoder) { fatalError("not used") }

    func configure(seed: Int) {
        let hue = CGFloat((seed * 47) % 360) / 360
        gradient.colors = [
            UIColor(hue: hue, saturation: 0.55, brightness: 0.85, alpha: 1).cgColor,
            UIColor(hue: (hue + 0.12).truncatingRemainder(dividingBy: 1), saturation: 0.6, brightness: 0.6, alpha: 1).cgColor,
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = bounds
    }
}
