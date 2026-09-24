import Foundation

/// Debug-only. After a flow ends, checks that its objects are actually gone.
protocol LeakReporting: AnyObject {
    func report(_ message: String)
}

final class LeakDetector {
    static let shared = LeakDetector()

    /// Weak, so the detector cannot itself keep a screen alive.
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
