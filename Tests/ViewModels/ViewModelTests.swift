import Combine
import XCTest
@testable import CoordinatorsDemo

final class ViewModelTests: XCTestCase {

    func testSignInSuccessHandsBackASession() async {
        let repository = SamplePostRepository()
        let auth = FakeAuthService(accounts: repository.users, lockedHandle: nil, delay: .zero)
        let viewModel = SignInViewModel(auth: auth)
        let signedIn = expectation(description: "signed in")
        var session: Session?
        viewModel.onSignedIn = { session = $0; signedIn.fulfill() }

        viewModel.signIn(as: repository.users[1])

        await fulfillment(of: [signedIn], timeout: 1)
        XCTAssertEqual(session?.user, repository.users[1])
        XCTAssertEqual(viewModel.state, .idle)
    }

    func testSignInFailureShowsAMessageAndRecovers() async {
        let repository = SamplePostRepository()
        let auth = FakeAuthService(accounts: repository.users, lockedHandle: "dmr", delay: .zero)
        let viewModel = SignInViewModel(auth: auth)
        let failed = expectation(description: "failed")
        var cancellables = Set<AnyCancellable>()
        viewModel.$state.sink { if case .failed = $0 { failed.fulfill() } }.store(in: &cancellables)

        viewModel.signIn(as: repository.users[4])

        await fulfillment(of: [failed], timeout: 1)
        XCTAssertEqual(viewModel.state, .failed(AuthError.accountLocked(handle: "dmr").localizedDescription))
        viewModel.dismissError()
        XCTAssertEqual(viewModel.state, .idle)
    }

    func testComposeCannotPostEmptyOrOversizedText() {
        let viewModel = ComposeViewModel(replyingTo: nil, draft: "")
        XCTAssertFalse(viewModel.canPost)

        viewModel.text = "Hello"
        XCTAssertTrue(viewModel.canPost)
        XCTAssertEqual(viewModel.counter, "5 / 280")

        viewModel.text = String(repeating: "x", count: 281)
        XCTAssertFalse(viewModel.canPost)
    }

    func testOnboardingAdvancesThenFinishes() {
        let viewModel = OnboardingViewModel()
        var finished = false
        viewModel.onFinish = { finished = true }

        viewModel.advance()
        viewModel.advance()
        XCTAssertTrue(viewModel.isLastPage)
        XCTAssertFalse(finished)

        viewModel.advance()
        XCTAssertTrue(finished)
    }

    func testFeedSelectionReportsThePostNotAnIndex() {
        let repository = SamplePostRepository()
        let viewModel = FeedViewModel(repository: repository)
        var selected: Post?
        viewModel.onSelectPost = { selected = $0 }
        viewModel.load()

        viewModel.selectPost(at: 2)

        XCTAssertEqual(selected, repository.posts[2])
    }

    func testProfileSignOutEndsTheSession() async {
        let dependencies = AppDependencies.test(signedInAs: SamplePostRepository().users[0])
        let viewModel = ProfileViewModel(user: dependencies.posts.users[0],
                                         repository: dependencies.posts,
                                         session: dependencies.session,
                                         auth: dependencies.auth,
                                         showsSignOut: true)
        let ended = expectation(description: "session ended")
        var cancellables = Set<AnyCancellable>()
        dependencies.session.$session.dropFirst().sink { if $0 == nil { ended.fulfill() } }.store(in: &cancellables)

        viewModel.signOut()

        await fulfillment(of: [ended], timeout: 1)
        XCTAssertNil(dependencies.session.session)
    }
}
