import Foundation

/// Which Leak Lab scenarios are switched on. Shared between the lab (which flips
/// them) and the coordinators that misbehave when they are on.
final class LeakSettings {
    private(set) var enabled: Set<LeakScenario> = []

    func set(_ scenario: LeakScenario, enabled on: Bool) {
        if on { enabled.insert(scenario) } else { enabled.remove(scenario) }
    }

    func isEnabled(_ scenario: LeakScenario) -> Bool {
        enabled.contains(scenario)
    }
}
