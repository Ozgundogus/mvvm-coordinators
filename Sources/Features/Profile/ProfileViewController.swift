import Combine
import UIKit

final class ProfileViewController: UITableViewController {
    private let viewModel: ProfileViewModel
    private var cancellables = Set<AnyCancellable>()
    private var posts: [Post] = []
    private let statsLabel = UILabel()

    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        super.init(style: .plain)
        title = viewModel.title
        navigationItem.largeTitleDisplayMode = viewModel.showsSignOut ? .always : .never
        if viewModel.showsSignOut {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "rectangle.portrait.and.arrow.right"),
                primaryAction: UIAction { [weak self] _ in self?.viewModel.signOut() })
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

        viewModel.$posts
            .sink { [weak self] posts in
                guard let self else { return }
                self.posts = posts
                self.statsLabel.text = self.viewModel.stats
                self.tableView.reloadData()
            }
            .store(in: &cancellables)
        viewModel.$isSigningOut
            .sink { [weak self] busy in self?.navigationItem.rightBarButtonItem?.isEnabled = !busy }
            .store(in: &cancellables)
        viewModel.load()
    }

    private func makeHeader() -> UIView {
        let avatar = AvatarView(size: 72)
        avatar.configure(with: viewModel.user)
        let name = UILabel()
        name.text = viewModel.user.name
        name.font = .systemFont(ofSize: 22, weight: .bold)
        let handle = UILabel()
        handle.text = viewModel.handle
        handle.textColor = .secondaryLabel
        let bio = UILabel()
        bio.text = viewModel.user.bio
        bio.numberOfLines = 0
        bio.font = .preferredFont(forTextStyle: .body)
        bio.textAlignment = .center
        statsLabel.font = .preferredFont(forTextStyle: .footnote)
        statsLabel.textColor = .secondaryLabel

        let stack = UIStackView(arrangedSubviews: [avatar, name, handle, bio, statsLabel])
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
        viewModel.selectPost(at: indexPath.row)
    }
}
