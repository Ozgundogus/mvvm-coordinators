# Coordinators

A small UIKit app where every flow has exactly one owner — and a **Leak Lab** that shows what happens when it doesn't.

It exists to back a two-part article on MVVM-C ownership and lifetime. Every snippet in the articles is lifted from this project; every screenshot was taken from it.

## What's in it

```
AppCoordinator                    owns the window; swaps the root
├─ AuthCoordinator                welcome → choose account → signed in
└─ MainCoordinator                tab bar; the whole subtree dies on sign-out
   ├─ FeedCoordinator             feed → post → comments; avatar → profile
   │  ├─ ComposeCoordinator       modal sheet; Post / Cancel / swipe-down → one finish()
   │  │  └─ MediaPickerCoordinator   a child of a child
   │  └─ ProfileCoordinator       same class as the tab, different parent
   ├─ ProfileCoordinator          tab root; sign out
   └─ LeakLabCoordinator          four leaks behind switches
```

- `Coordinator` — the protocol and its three rules (`Sources/Coordinators/Coordinator.swift`)
- `Routing` / `Router` — the only object that touches `UINavigationController`. A coordinator's lifetime follows the *screen*, by any exit: back, swipe, `popToRoot`, sheet dragged down.
- `LeakDetector` — after a flow finishes, asserts the objects are gone.
- `Tests/` — coordinators driven with a `FakeRouter`, no simulator screen involved.

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
| `-leak retainedSlot` | a parentless coordinator is kept in a static slot |
| `-leak signOut` | sign out, but the retired tree is still referenced |

Then **Debug → Debug Memory Graph** in Xcode. The Leak Lab tab also shows the detector's message on screen.

Other arguments: `-autoLogin YES`, `-deeplink coordinators://post/103/comments`, `-screen compose|picker`.

## Tests

```
xcodebuild -scheme CoordinatorsDemo -destination 'platform=iOS Simulator,name=iPhone 16' test
```
