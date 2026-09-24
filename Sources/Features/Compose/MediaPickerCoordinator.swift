import UIKit

final class MediaPickerCoordinator: BaseCoordinator, Coordinator {
    var onPicked: ((Int) -> Void)?
    private let router: Routing

    init(router: Routing) {
        self.router = router
        super.init()
    }

    func start() {
        let viewModel = MediaPickerViewModel()
        viewModel.onPick = { [weak self] seed in
            self?.onPicked?(seed)
            self?.router.popToRoot()
        }
        router.push(MediaPickerViewController(viewModel: viewModel), onPop: { [weak self] in self?.finish() })
    }
}
