import UIKit

final class ProfileViewController: UITableViewController {
    var onSelectPost: ((Post) -> Void)?
    var onSignOut: (() -> Void)?
    private let user: User
    private let posts: [Post]
    private let showsSignOut: Bool

    init(user: User, posts: [Post], showsSignOut: Bool) {
        self.user = user
        self.posts = posts
        self.showsSignOut = showsSignOut
        super.init(style: .plain)
        title = showsSignOut ? "Profile" : user.name
        navigationItem.largeTitleDisplayMode = showsSignOut ? .always : .never
        if showsSignOut {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "rectangle.portrait.and.arrow.right"),
                primaryAction: UIAction { [weak self] _ in self?.onSignOut?() })
        }
    }

    required init?(coder: NSCoder) { fatalError("not used") }

    deinit { LeakDetector.shared.didDeinit(self) }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        tableView.separatorStyle = .none
        tableView.register(PostCell.self, forCellReuseIdentifier: PostCell.reuseIdentifier)
        tableView.tableHeaderView = makeHeader()
    }

    private func makeHeader() -> UIView {
        let avatar = AvatarView(size: 72)
        avatar.configure(with: user)
        let name = UILabel()
        name.text = user.name
        name.font = .systemFont(ofSize: 22, weight: .bold)
        let handle = UILabel()
        handle.text = "@\(user.handle)"
        handle.textColor = .secondaryLabel
        let bio = UILabel()
        bio.text = user.bio
        bio.numberOfLines = 0
        bio.font = .preferredFont(forTextStyle: .body)
        bio.textAlignment = .center
        let stats = UILabel()
        stats.text = "\(posts.count) posts · \(posts.reduce(0) { $0 + $1.likes }) likes"
        stats.font = .preferredFont(forTextStyle: .footnote)
        stats.textColor = .secondaryLabel

        let stack = UIStackView(arrangedSubviews: [avatar, name, handle, bio, stats])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 6
        stack.setCustomSpacing(12, after: avatar)
        stack.setCustomSpacing(12, after: handle)
        stack.translatesAutoresizingMaskIntoConstraints = false

        let container = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 240))
        container.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -24),
        ])
        return container
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { posts.count }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PostCell.reuseIdentifier, for: indexPath) as! PostCell
        cell.card.configure(with: posts[indexPath.row])
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onSelectPost?(posts[indexPath.row])
    }
}
