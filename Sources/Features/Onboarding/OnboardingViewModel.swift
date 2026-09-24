import Combine
import Foundation

struct OnboardingPage: Equatable {
    let symbol: String
    let title: String
    let body: String
}

final class OnboardingViewModel {
    let pages: [OnboardingPage] = [
        OnboardingPage(symbol: "point.3.connected.trianglepath.dotted",
                       title: "Every flow has one owner",
                       body: "A coordinator lives exactly as long as its parent lists it. No parent, no coordinator."),
        OnboardingPage(symbol: "arrow.uturn.backward.circle",
                       title: "The router watches the screen",
                       body: "Back, swipe, popToRoot, a sheet dragged down — one closure fires, whichever way the screen left."),
        OnboardingPage(symbol: "flask",
                       title: "Then break it on purpose",
                       body: "The Leak Lab reproduces the leaks that ownership rules prevent, and a detector names the object that stayed behind."),
    ]

    @Published private(set) var currentIndex = 0

    var onFinish: (() -> Void)?

    var isLastPage: Bool { currentIndex == pages.count - 1 }
    var buttonTitle: String { isLastPage ? "Get started" : "Next" }

    func showPage(at index: Int) {
        guard pages.indices.contains(index) else { return }
        currentIndex = index
    }

    func advance() {
        if isLastPage {
            onFinish?()
        } else {
            currentIndex += 1
        }
    }

    func skip() {
        onFinish?()
    }
}
