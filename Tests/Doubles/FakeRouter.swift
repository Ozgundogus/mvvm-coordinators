import UIKit
import XCTest
@testable import CoordinatorsDemo

/// Records what a coordinator asks for and lets the test "pop" screens by hand.
final class FakeRouter: Routing {
    private(set) var stack: [UIViewController] = []
    private(set) var presented: UIViewController?
    private var completions: [ObjectIdentifier: () -> Void] = [:]
    private(set) var pushCalls = 0
    private(set) var setStackCalls = 0

    var rootViewController: UIViewController? { stack.first }

    func push(_ viewController: UIViewController, animated: Bool, onPop: (() -> Void)?) {
        pushCalls += 1
        stack.append(viewController)
        if let onPop { completions[ObjectIdentifier(viewController)] = onPop }
    }

    func setStack(_ viewControllers: [UIViewController], animated: Bool) {
        setStackCalls += 1
        stack = viewControllers
    }

    func popToRoot(animated: Bool) {
        while stack.count > 1 { popTop() }
    }

    func present(_ viewController: UIViewController, animated: Bool, onDismiss: (() -> Void)?) {
        presented = viewController
        if let onDismiss { completions[ObjectIdentifier(viewController)] = onDismiss }
    }

    func dismiss(_ viewController: UIViewController, animated: Bool) {
        presented = nil
        completions.removeValue(forKey: ObjectIdentifier(viewController))?()
    }

    // Test helpers

    func popTop() {
        guard let top = stack.popLast() else { return }
        completions.removeValue(forKey: ObjectIdentifier(top))?()
    }

    func swipeDownPresented() {
        guard let presented else { return }
        self.presented = nil
        completions.removeValue(forKey: ObjectIdentifier(presented))?()
    }

    func tapFirstAvatar() {
        guard let feed = stack.first as? FeedViewController else { return XCTFail("feed not at root") }
        feed.loadViewIfNeeded()
        let cell = feed.tableView(feed.tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as! PostCell
        cell.card.onAvatarTap?()
    }
}
