import Combine
import UIKit

final class LeakLabViewController: UITableViewController {
    private let viewModel: LeakLabViewModel
    private var cancellables = Set<AnyCancellable>()

    private enum Section: Int, CaseIterable { case flows, detector, tree }

    init(viewModel: LeakLabViewModel) {
        self.viewModel = viewModel
        super.init(style: .insetGrouped)
        title = "Leak Lab"
    }

    required init?(coder: NSCoder) { fatalError("not used") }

    deinit { LeakDetector.shared.didDeinit(self) }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.$lastReport
            .dropFirst()
            .sink { [weak self] _ in
                self?.tableView.reloadSections(IndexSet(integer: Section.detector.rawValue), with: .automatic)
            }
            .store(in: &cancellables)
    }

    override func numberOfSections(in tableView: UITableView) -> Int { Section.allCases.count }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Section(rawValue: section) == .flows ? viewModel.flows.count : 1
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(rawValue: section)! {
        case .flows: return "Turn a leak on, tap the row, then pop back"
        case .detector: return "Detector"
        case .tree: return "Whole tree"
        }
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch Section(rawValue: section)! {
        case .flows: return "Then Debug → Memory Graph in Xcode. Purple markers are the leaks."
        case .tree: return "Sign out from the Profile tab. Every coordinator under Main should deinit; with this on, none of them do."
        case .detector: return nil
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        var content = cell.defaultContentConfiguration()
        content.secondaryTextProperties.color = .secondaryLabel
        switch Section(rawValue: indexPath.section)! {
        case .flows:
            configure(&content, cell, for: viewModel.flows[indexPath.row])
        case .tree:
            configure(&content, cell, for: viewModel.tree)
        case .detector:
            let report = viewModel.lastReport
            content.text = report ?? "No leak reported"
            content.textProperties.color = report == nil ? .secondaryLabel : .systemRed
            content.textProperties.font = .preferredFont(forTextStyle: .callout)
            content.image = UIImage(systemName: report == nil ? "checkmark.seal" : "exclamationmark.triangle.fill")
            content.imageProperties.tintColor = report == nil ? .systemGreen : .systemRed
        }
        cell.contentConfiguration = content
        return cell
    }

    private func configure(_ content: inout UIListContentConfiguration, _ cell: UITableViewCell, for scenario: LeakScenario) {
        content.text = scenario.title
        content.secondaryText = scenario.subtitle
        content.image = UIImage(systemName: scenario.symbol)
        content.imageProperties.tintColor = .systemRed
        let toggle = UISwitch()
        toggle.isOn = viewModel.isEnabled(scenario)
        toggle.addAction(UIAction { [weak self] action in
            guard let toggle = action.sender as? UISwitch else { return }
            self?.viewModel.setEnabled(toggle.isOn, for: scenario)
        }, for: .valueChanged)
        cell.accessoryView = toggle
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard Section(rawValue: indexPath.section) == .flows else { return }
        viewModel.run(viewModel.flows[indexPath.row])
    }
}
