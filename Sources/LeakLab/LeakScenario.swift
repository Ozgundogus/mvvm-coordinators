import Foundation

/// The four ways a coordinator outlives its flow that the lab can reproduce.
/// `rawValue` doubles as the `-leak` launch argument.
enum LeakScenario: String, CaseIterable {
    /// The child is added but never removed when its flow ends.
    case forgetChild
    /// The view model captures the coordinator strongly; the coordinator holds the
    /// view model through the screen. A cycle.
    case closureCycle
    /// A coordinator with no parent, kept alive by a static "retained" slot the way
    /// a deep-link manager might do it.
    case retainedSlot
    /// Sign out, but keep a reference to the retired tree. Everything under it lives.
    case signOut

    var symbol: String {
        switch self {
        case .forgetChild: return "person.2.slash"
        case .closureCycle: return "arrow.triangle.2.circlepath"
        case .retainedSlot: return "tray.full"
        case .signOut: return "tree"
        }
    }

    var title: String {
        switch self {
        case .forgetChild: return "Forget to remove the child"
        case .closureCycle: return "Strong closure cycle"
        case .retainedSlot: return "Parentless coordinator in a retained slot"
        case .signOut: return "Keep the old tree on sign-out"
        }
    }

    var subtitle: String {
        switch self {
        case .forgetChild: return "The child stays in `children` after its screen is popped."
        case .closureCycle: return "The view model's closure captures the coordinator strongly."
        case .retainedSlot: return "Held by a static var that nobody clears."
        case .signOut: return "AppCoordinator holds the retired MainCoordinator."
        }
    }
}
