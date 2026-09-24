import UIKit

extension AvatarColor {
    var uiColor: UIColor {
        switch self {
        case .indigo: return .systemIndigo
        case .teal: return .systemTeal
        case .orange: return .systemOrange
        case .pink: return .systemPink
        case .green: return .systemGreen
        }
    }
}
