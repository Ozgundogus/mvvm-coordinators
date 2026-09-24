import Foundation

final class LeakSettings {
    private(set) var enabled: Set<LeakScenario> = []

    func set(_ scenario: LeakScenario, enabled on: Bool) {
        if on { enabled.insert(scenario) } else { enabled.remove(scenario) }
    }

    func isEnabled(_ scenario: LeakScenario) -> Bool {
        enabled.contains(scenario)
    }
}
