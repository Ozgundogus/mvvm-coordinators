import UIKit

final class CommentsViewController: UITableViewController {
    var onReply: (() -> Void)?
    var onSelectAuthor: ((User) -> Void)?
    private let post: Post
    private let comments: [Comment]

    init(post: Post, comments: [Comment]) {
        self.post = post
        self.comments = comments
        super.init(style: .plain)
        title = "Comments"
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrowshape.turn.up.left"),
            primaryAction: UIAction { [weak self] _ in self?.onReply?() })
    }

    required init?(coder: NSCoder) { fatalError("not used") }

    deinit { LeakDetector.shared.didDeinit(self) }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(CommentCell.self, forCellReuseIdentifier: CommentCell.reuseIdentifier)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 0)
        let header = UILabel()
        header.text = "  On “\(post.text.prefix(48))…”"
        header.font = .preferredFont(forTextStyle: .footnote)
        header.textColor = .secondaryLabel
        header.frame = CGRect(x: 0, y: 0, width: 0, height: 36)
        tableView.tableHeaderView = header
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { comments.count }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CommentCell.reuseIdentifier, for: indexPath) as! CommentCell
        cell.configure(with: comments[indexPath.row])
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        onSelectAuthor?(comments[indexPath.row].author)
    }
}
