import UIKit

final class FeedViewController: UITableViewController {
    var onSelectPost: ((Post) -> Void)?
    var onSelectAuthor: ((User) -> Void)?
    var onCompose: (() -> Void)?
    private let posts: [Post]

    init(posts: [Post]) {
        self.posts = posts
        super.init(style: .plain)
        title = "Feed"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "square.and.pencil"),
            primaryAction: UIAction { [weak self] _ in self?.onCompose?() })
    }

    required init?(coder: NSCoder) { fatalError("not used") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        tableView.separatorStyle = .none
        tableView.register(PostCell.self, forCellReuseIdentifier: PostCell.reuseIdentifier)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { posts.count }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PostCell.reuseIdentifier, for: indexPath) as! PostCell
        let post = posts[indexPath.row]
        cell.card.configure(with: post)
        cell.card.onAvatarTap = { [weak self] in self?.onSelectAuthor?(post.author) }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onSelectPost?(posts[indexPath.row])
    }
}
