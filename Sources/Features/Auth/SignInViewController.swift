import Combine
import UIKit

final class SignInViewController: UITableViewController {
    private let viewModel: SignInViewModel
    private var cancellables = Set<AnyCancellable>()
    private var signingIn: User?

    init(viewModel: SignInViewModel) {
        self.viewModel = viewModel
        super.init(style: .insetGrouped)
        title = "Choose an account"
    }

    required init?(coder: NSCoder) { fatalError("not used") }

    deinit { LeakDetector.shared.didDeinit(self) }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.$state
            .sink { [weak self] state in self?.render(state) }
            .store(in: &cancellables)
    }

    private func render(_ state: SignInViewModel.State) {
        switch state {
        case .idle:
            signingIn = nil
            tableView.reloadData()
        case .signingIn(let user):
            signingIn = user
            tableView.reloadData()
        case .failed(let message):
            signingIn = nil
            tableView.reloadData()
            let alert = UIAlertController(title: "Couldn't sign in", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in self?.viewModel.dismissError() })
            present(alert, animated: true)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { viewModel.accounts.count }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        "Sign-in takes a moment, like a real one. One of these accounts is locked."
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = viewModel.accounts[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        var content = cell.defaultContentConfiguration()
        content.text = user.name
        content.secondaryText = "@\(user.handle)"
        content.image = UIImage(systemName: "person.crop.circle.fill")
        content.imageProperties.tintColor = user.avatar.uiColor
        content.imageProperties.preferredSymbolConfiguration = .init(pointSize: 28)
        cell.contentConfiguration = content
        if signingIn == user {
            let spinner = UIActivityIndicatorView(style: .medium)
            spinner.startAnimating()
            cell.accessoryView = spinner
        } else {
            cell.accessoryType = .disclosureIndicator
        }
        cell.isUserInteractionEnabled = signingIn == nil
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.signIn(as: viewModel.accounts[indexPath.row])
    }
}
