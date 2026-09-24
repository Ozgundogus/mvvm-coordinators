import UIKit

/// A child of the compose flow. Pushed onto the sheet's own stack; finished when
/// its screen pops — whether the user picked something or hit back.
final class MediaPickerCoordinator: BaseCoordinator, Coordinator {
    var onPicked: ((Int) -> Void)?
    private let router: Routing

    init(router: Routing) {
        self.router = router
        super.init()
    }

    func start() {
        let picker = MediaPickerViewController()
        picker.onPick = { [weak self] seed in
            self?.onPicked?(seed)
            self?.router.popToRoot()
        }
        router.push(picker, onPop: { [weak self] in self?.finish() })
    }
}
