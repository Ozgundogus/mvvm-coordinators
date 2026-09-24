import UIKit

final class AccountPickerViewController: UITableViewController {
    var onPick: ((User) -> Void)?
    private let users: [User]

    init(users: [User]) {
        self.users = users
        super.init(style: .insetGrouped)
        title = "Choose an account"
    }

    required init?(coder: NSCoder) { fatalError("not used") }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { users.count }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = users[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        var content = cell.defaultContentConfiguration()
        content.text = user.name
        content.secondaryText = "@\(user.handle)"
        content.image = UIImage(systemName: "person.crop.circle.fill")
        content.imageProperties.tintColor = user.color
        content.imageProperties.preferredSymbolConfiguration = .init(pointSize: 28)
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        onPick?(users[indexPath.row])
    }
}
