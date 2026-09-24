import UIKit

final class CommentCell: UITableViewCell {
    static let reuseIdentifier = "CommentCell"
    private let avatar = AvatarView(size: 32)
    private let nameLabel = UILabel()
    private let bodyLabel = UILabel()
    private let timeLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        nameLabel.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .subheadline).pointSize, weight: .semibold)
        timeLabel.font = .preferredFont(forTextStyle: .caption1)
        timeLabel.textColor = .secondaryLabel
        bodyLabel.font = .preferredFont(forTextStyle: .body)
        bodyLabel.numberOfLines = 0
        let header = UIStackView(arrangedSubviews: [nameLabel, timeLabel])
        header.spacing = 8
        header.alignment = .firstBaseline
        let text = UIStackView(arrangedSubviews: [header, bodyLabel])
        text.axis = .vertical
        text.spacing = 4
        let row = UIStackView(arrangedSubviews: [avatar, text])
        row.alignment = .top
        row.spacing = 12
        row.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(row)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            row.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            row.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            row.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
        ])
    }

    required init?(coder: NSCoder) { fatalError("not used") }

    func configure(with comment: Comment) {
        avatar.configure(with: comment.author)
        nameLabel.text = comment.author.name
        timeLabel.text = "\(comment.minutesAgo)m"
        bodyLabel.text = comment.text
    }
}
