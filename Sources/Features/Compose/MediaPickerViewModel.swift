import Foundation

final class MediaPickerViewModel {
    let seeds: [Int] = (0..<12).map { $0 * 3 + 1 }

    var onPick: ((Int) -> Void)?

    deinit { LeakDetector.shared.didDeinit(self) }

    func pick(at index: Int) {
        guard seeds.indices.contains(index) else { return }
        onPick?(seeds[index])
    }
}
