import UIKit

/// What a coordinator wants to happen when the user leaves a post screen. The
/// factory wires the view models; the coordinator decides where each intent goes.
struct PostScreenActions {
    var showComments: (Post) -> Void
    var showAuthor: (User) -> Void
    var reply: (Post) -> Void
}

/// The post and comments screens are reached from the feed and from a profile.
/// One factory, two owners.
struct PostScreenFactory {
    let repository: PostRepository

    func makeDetail(for post: Post, actions: PostScreenActions) -> UIViewController {
        let viewModel = PostDetailViewModel(post: post)
        viewModel.onShowComments = { actions.showComments(post) }
        viewModel.onSelectAuthor = actions.showAuthor
        viewModel.onReply = { actions.reply(post) }
        return PostDetailViewController(viewModel: viewModel)
    }

    func makeComments(for post: Post, actions: PostScreenActions) -> UIViewController {
        let viewModel = CommentsViewModel(post: post, repository: repository)
        viewModel.onReply = { actions.reply(post) }
        viewModel.onSelectAuthor = actions.showAuthor
        return CommentsViewController(viewModel: viewModel)
    }
}
