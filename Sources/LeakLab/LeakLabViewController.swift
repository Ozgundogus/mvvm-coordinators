import UIKit

final class LeakLabViewController: UITableViewController, LeakReporting {
    private weak var coordinator: LeakLabCoordinator?
    private var lastReport: String?
    private let flowScenarios: [LeakScenario] = [.forgetChild, .closureCycle, .retainedSlot]

    private enum Section: Int, CaseIterable { case flows, detector, tree }

    init(coordinator: LeakLabCoordinator) {
        self.coordinator = coordinator
        super.init(style: .insetGrouped)
        title = "Leak Lab"
    }

    required init?(coder: NSCoder) { fatalError("not used") }

    // MARK: LeakReporting

    func report(_ message: String) {
        lastReport = message
        tableView.reloadSections(IndexSet(integer: Section.detector.rawValue), with: .automatic)
    }

    // MARK: Table

    override func numberOfSections(in tableView: UITableView) -> Int { Section.allCases.count }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Section(rawValue: section) == .flows ? flowScenarios.count : 1
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
            configure(&content, cell, for: flowScenarios[indexPath.row])
        case .tree:
            configure(&content, cell, for: .signOut)
        case .detector:
            let leaked = lastReport != nil
            content.text = lastReport ?? "No leak reported"
            content.textProperties.color = leaked ? .systemRed : .secondaryLabel
            content.textProperties.font = .preferredFont(forTextStyle: .callout)
            content.image = UIImage(systemName: leaked ? "exclamationmark.triangle.fill" : "checkmark.seal")
            content.imageProperties.tintColor = leaked ? .systemRed : .systemGreen
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
        toggle.isOn = coordinator?.enabled.contains(scenario) ?? false
        toggle.addAction(UIAction { [weak self] action in
            guard let s = action.sender as? UISwitch else { return }
            self?.coordinator?.setEnabled(s.isOn, for: scenario)
        }, for: .valueChanged)
        cell.accessoryView = toggle
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard Section(rawValue: indexPath.section) == .flows else { return }
        lastReport = nil
        tableView.reloadSections(IndexSet(integer: Section.detector.rawValue), with: .none)
        coordinator?.run(flowScenarios[indexPath.row])
    }
}
