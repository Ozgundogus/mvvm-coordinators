import UIKit

extension UIButton {
    static func filled(_ title: String, symbol: String? = nil, action: @escaping () -> Void) -> UIButton {
        make(.filled(), title: title, symbol: symbol, action: action)
    }

    static func tinted(_ title: String, symbol: String? = nil, action: @escaping () -> Void) -> UIButton {
        make(.tinted(), title: title, symbol: symbol, action: action)
    }

    private static func make(_ base: UIButton.Configuration, title: String, symbol: String?, action: @escaping () -> Void) -> UIButton {
        var config = base
        config.title = title
        config.cornerStyle = .large
        config.imagePadding = 8
        if let symbol { config.image = UIImage(systemName: symbol) }
        return UIButton(configuration: config, primaryAction: UIAction { _ in action() })
    }
}
