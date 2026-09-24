# Changelog

## 1.0.0 — 2026-09-24

Companion release for *Who Owns a Coordinator? MVVM-C on iOS, Part 1*.

- `Coordinator` protocol with `addChild` / `finish()` / `childDidFinish`, and a `BaseCoordinator` that deliberately does not conform
- `Routing` protocol and `Router`: one completion per screen, fired on any exit (back, swipe, `popToRoot`, replaced stack, sheet dismissed)
- Flows: Auth, Main (tab bar), Feed → Post → Comments, Profile (as tab root and as pushed child), Compose (modal) with a nested Media Picker
- `AppCoordinator` root swap on sign-out
- Leak Lab: `forgetChild`, `closureCycle`, `retainedSlot`, `signOut` scenarios behind switches and `-leak` launch arguments
- `LeakDetector.expectDeallocation` for debug builds
- Four unit tests driving real coordinators through a `FakeRouter`
