# mvvm-coordinators

A small UIKit app where every flow has exactly one owner — and a **Leak Lab** that shows what happens when it doesn't.

It backs a series of articles on MVVM-C ownership and lifetime. Every snippet in the articles is lifted from this project; every screenshot was taken from it.

| Article | Tag |
|---|---|
| [Who Owns a Coordinator? MVVM-C on iOS, Part 1](https://medium.com/@canozgundogus/who-owns-a-coordinator-mvvm-c-on-ios-part-1-e98323b5d904) | [`v1.0.0`](https://github.com/Ozgundogus/mvvm-coordinators/tree/v1.0.0) |

## The tree

```
AppCoordinator                    owns the window; one child at a time, chosen by the session
├─ OnboardingCoordinator          first launch only
├─ AuthCoordinator                welcome → sign in (async, one account is locked)
└─ MainCoordinator                tab bar; the whole subtree dies on sign-out
   ├─ FeedCoordinator             feed → post → comments; avatar → profile
   │  ├─ ComposeCoordinator       modal sheet; Post / Cancel / swipe-down → one finish()
   │  │  └─ MediaPickerCoordinator   a child of a child
   │  └─ ProfileCoordinator       same class as the tab, different parent
   ├─ ProfileCoordinator          tab root; sign out ends the session
   └─ LeakLabCoordinator          five leaks behind switches
```

## Layout

```
Sources/
  App/            AppDelegate, SceneDelegate, AppCoordinator, LaunchArguments, DeepLink
  Core/
    Coordinator/  Coordinator protocol, BaseCoordinator
    Routing/      Routing protocol, Router — the only object that touches UINavigationController
    Diagnostics/  LeakDetector, LeakScenario, LeakSettings
  Domain/         User, Post, Comment, Session — Foundation only
  Data/           PostRepository, AuthService, SessionStore, Preferences, AppDependencies
  Features/       one folder per flow: Coordinator + ViewModel + ViewController
  DesignSystem/   cards, cells, avatar, buttons
Tests/
  Coordinators/   flows driven through a FakeRouter, no simulator screen
  ViewModels/     state and intents, no UIKit
  Doubles/        FakeRouter, SpyCoordinator, in-memory dependencies
```

The rules the code follows:

- **Ownership.** A parent adds a child with `addChild`; the child ends with `finish()`, which only tells the parent; the parent removes it in `childDidFinish`. A coordinator's lifetime follows its *screen*: the router fires `onPop` / `onDismiss` on any exit.
- **MVVM.** Every screen has a view model. View models import Foundation and Combine, never UIKit. A view controller binds to `@Published` state and forwards user intents; navigation intents leave the view model as closures the coordinator wires.
- **Session drives the root.** `SessionStore` is the single source of truth for "signed in". `AppCoordinator` observes it and swaps its one child; sign-out is `session.end()` and nothing else.

## Run it

Requires Xcode 26 (iOS 17+). The project is generated with [xcodegen](https://github.com/yonaskolb/XcodeGen):

```
brew install xcodegen
xcodegen generate
open CoordinatorsDemo.xcodeproj
```

## Reproduce a leak

Add a launch argument to the scheme (or pass it with `xcrun simctl launch`):

| Argument | What happens |
|---|---|
| `-leak forgetChild` | a child flow finishes but is never removed from `children` |
| `-leak closureCycle` | a view model's closure captures its coordinator strongly |
| `-leak subscriptionCycle` | a screen's `sink` captures the screen without `[weak self]` |
| `-leak retainedSlot` | a parentless coordinator is kept in a static slot |
| `-leak signOut` | sign out, but the retired tree is still referenced |

Then **Debug → Debug Memory Graph** in Xcode. The Leak Lab tab also shows the detector's message on screen.

Other arguments: `-autoLogin YES`, `-onboarding YES`, `-deeplink coordinators://post/103/comments`, `-screen compose|picker`.

## Tests

```
xcodebuild -scheme CoordinatorsDemo -destination 'platform=iOS Simulator,name=iPhone 16' test
```
