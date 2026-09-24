import Combine
import Foundation

final class LeakLabViewModel: LeakReporting {
    let flows = LeakScenario.flows
    let tree = LeakScenario.signOut
    @Published private(set) var lastReport: String?

    var onRun: ((LeakScenario) -> Void)?

    private let settings: LeakSettings

    init(settings: LeakSettings) {
        self.settings = settings
    }

    deinit { LeakDetector.shared.didDeinit(self) }

    func isEnabled(_ scenario: LeakScenario) -> Bool {
        settings.isEnabled(scenario)
    }

    func setEnabled(_ on: Bool, for scenario: LeakScenario) {
        settings.set(scenario, enabled: on)
    }

    func run(_ scenario: LeakScenario) {
        lastReport = nil
        onRun?(scenario)
    }

    func report(_ message: String) {
        lastReport = message
    }
}
