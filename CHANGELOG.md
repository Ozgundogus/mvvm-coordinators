# Changelog

## Unreleased

- Layout: `Core` / `Domain` / `Data` / `Features` / `DesignSystem`; one folder per flow with Coordinator + ViewModel + ViewController
- MVVM: a view model for every screen, bound with Combine; view models never import UIKit (`AvatarColor` replaces `UIColor` in the domain)
- Onboarding flow (first launch), `AuthService` with async sign-in and a locked account, `Session` / `SessionStore`
- `AppCoordinator` owns one child at a time and swaps it when the session changes; sign-out is `session.end()`
- `MainCoordinator` no longer exposes its children; `Router` is created per tab and never cast back from `Routing`
- Leak Lab: flows end with `finish()` / `childDidFinish` like everything else; a fifth scenario, `subscriptionCycle` (a `sink` without `[weak self]`)
- Tests: 15, covering coordinators, `AppCoordinator` root swaps, deep links parked across sign-in, and view models

## 1.0.0 — 2026-09-24

Companion release for *Who Owns a Coordinator? MVVM-C on iOS, Part 1*.

- `Coordinator` protocol with `addChild` / `finish()` / `childDidFinish`, and a `BaseCoordinator` that deliberately does not conform
- `Routing` protocol and `Router`: one completion per screen, fired on any exit (back, swipe, `popToRoot`, replaced stack, sheet dismissed)
- Flows: Auth, Main (tab bar), Feed → Post → Comments, Profile (as tab root and as pushed child), Compose (modal) with a nested Media Picker
- `AppCoordinator` root swap on sign-out
- Leak Lab: `forgetChild`, `closureCycle`, `retainedSlot`, `signOut` scenarios behind switches and `-leak` launch arguments
- `LeakDetector.expectDeallocation` for debug builds
- Four unit tests driving real coordinators through a `FakeRouter`
