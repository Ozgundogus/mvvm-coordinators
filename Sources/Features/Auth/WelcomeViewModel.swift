import Foundation

final class WelcomeViewModel {
    let title = "Coordinators"
    let subtitle = "A small app where every flow has exactly one owner — and the Leak Lab shows what happens when it doesn't."
    let buttonTitle = "Sign in"

    var onContinue: (() -> Void)?

    func continueTapped() {
        onContinue?()
    }
}
