import Foundation

/// Debug-only: after a flow ends, the objects that made it up should be gone. If one
/// is still alive a moment later, say so loudly. This catches the class of bug that
/// Memory Graph shows you — without opening Memory Graph.
protocol LeakReporting: AnyObject {
    func report(_ message: String)
}

final class LeakDetector {
    static let shared = LeakDetector()

    /// Whoever wants to show leaks on screen (the Leak Lab does). Weak, so the
    /// detector never keeps a screen alive — that would be a joke at its own expense.
    weak var reporter: LeakReporting?

    private init() {}

    func expectDeallocation(of object: AnyObject,
                           after delay: TimeInterval = 1.0,
                           file: StaticString = #fileID,
                           line: UInt = #line) {
        #if DEBUG
        let name = "\(type(of: object))"
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self, weak object] in
            guard object != nil else { return }
            let message = "LEAK: \(name) is still alive \(delay)s after its flow finished (\(file):\(line))"
            print(message)
            self?.reporter?.report(message)
        }
        #endif
    }

    func didDeinit(_ object: AnyObject) {
        #if DEBUG
        print("♻️ deinit \(type(of: object))")
        #endif
    }
}
