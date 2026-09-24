import Combine
import UIKit

final class FeedViewController: UITableViewController {
    let viewModel: FeedViewModel
    private var cancellables = Set<AnyCancellable>()
    private var posts: [Post] = []

    init(viewModel: FeedViewModel) {
        self.viewModel = viewModel
        super.init(style: .plain)
        title = "Feed"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "square.and.pencil"),
            primaryAction: UIAction { [weak self] _ in self?.viewModel.composeTapped() })
    }

    required init?(coder: NSCoder) { fatalError("not used") }

    deinit { LeakDetector.shared.didDeinit(self) }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        tableView.separatorStyle = .none
        tableView.register(PostCell.self, forCellReuseIdentifier: PostCell.reuseIdentifier)

        viewModel.$posts
            .sink { [weak self] posts in
                self?.posts = posts
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        viewModel.load()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { posts.count }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PostCell.reuseIdentifier, for: indexPath) as! PostCell
        cell.card.configure(with: posts[indexPath.row])
        cell.card.onAvatarTap = { [weak self] in self?.viewModel.selectAuthor(at: indexPath.row) }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectPost(at: indexPath.row)
    }
}
