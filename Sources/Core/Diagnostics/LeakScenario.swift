import Foundation

enum LeakScenario: String, CaseIterable {
    /// The child is added but never removed when its flow ends.
    case forgetChild
    /// The view model's closure captures the coordinator strongly.
    case closureCycle
    /// A Combine `sink` captures the screen strongly and the screen stores the cancellable.
    case subscriptionCycle
    /// A parentless coordinator held by a static slot.
    case retainedSlot
    /// The retired tree is still referenced after sign-out.
    case signOut

    static let flows: [LeakScenario] = [.forgetChild, .closureCycle, .subscriptionCycle, .retainedSlot]

    var symbol: String {
        switch self {
        case .forgetChild: return "person.2.slash"
        case .closureCycle: return "arrow.triangle.2.circlepath"
        case .subscriptionCycle: return "antenna.radiowaves.left.and.right"
        case .retainedSlot: return "tray.full"
        case .signOut: return "tree"
        }
    }

    var title: String {
        switch self {
        case .forgetChild: return "Forget to remove the child"
        case .closureCycle: return "Strong closure cycle"
        case .subscriptionCycle: return "Subscription without [weak self]"
        case .retainedSlot: return "Parentless coordinator in a retained slot"
        case .signOut: return "Keep the old tree on sign-out"
        }
    }

    var subtitle: String {
        switch self {
        case .forgetChild: return "The child stays in `children` after its screen is popped."
        case .closureCycle: return "The view model's closure captures the coordinator strongly."
        case .subscriptionCycle: return "The screen's `sink` captures the screen; the screen stores the cancellable."
        case .retainedSlot: return "Held by a static var that nobody clears."
        case .signOut: return "AppCoordinator holds the retired MainCoordinator."
        }
    }
}
