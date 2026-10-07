[![iOS](https://img.shields.io/badge/iOS-Swift-7F77DD?style=flat)](https://developer.apple.com/ios/) [![Swift](https://img.shields.io/badge/Swift-6.0-1D9E75?logo=swift&logoColor=white&style=flat)](https://swift.org) [![CI](https://img.shields.io/github/actions/workflow/status/Syzygy-Hub/syzygy-base-ios/ci.yml?label=ci&style=flat)](https://github.com/Syzygy-Hub/syzygy-base-ios/actions/workflows/ci.yml) [![Version](https://img.shields.io/badge/version-3.0.0-D85A30?style=flat)](https://github.com/Syzygy-Hub/syzygy-base-ios/releases) [![License](https://img.shields.io/badge/License-MIT-green?style=flat)](LICENSE)

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/Syzygy-Hub/.github/main/brand/assets/banners/syzygy-banner-dark-1200.png">
  <img src="https://raw.githubusercontent.com/Syzygy-Hub/.github/main/brand/assets/banners/syzygy-banner-light-1200.png" alt="Syzygy" width="600">
</picture>

# syzygy-base-ios

A template iOS app that wires all 5 Syzygy layers via the Core DI Container.

## About

syzygy-base-ios is a template iOS application that connects every Syzygy layer — Foundation, Core, Services, AI, and UI — through a single Core DI Container. All registrations live in `AppDependencies.swift`, so the wiring is visible in one place. Clone the repo, run `setup.sh`, and the project is ready to rename and extend with your own features.

## Platforms

| Platform | Dependency management | Status |
|---|---|---|
| iOS 16.0+ | SPM (Syzygy dependencies) | ✅ Supported |

## Requirements

- iOS 16.0+
- Swift 6.0+
- Xcode 16.0+

## Installation

1. Clone the repo:
   ```sh
   git clone https://github.com/Syzygy-Hub/syzygy-base-ios.git
   cd syzygy-base-ios
   ```
2. Run the setup script (PascalCase, no spaces):
   ```sh
   ./setup.sh YourAppName
   ```
   This renames bundle IDs, the app name, class names, and all references throughout the project. Commit all changes before running `setup.sh`.
3. Open `SyzygyBase.xcodeproj` in Xcode.
4. Add SPM dependencies via **Xcode → File → Add Package Dependencies**, then add each URL with version rule **Up to Next Major Version from 3.0.0**:
   - https://github.com/Syzygy-Hub/syzygy-foundation-ios
   - https://github.com/Syzygy-Hub/syzygy-core-ios
   - https://github.com/Syzygy-Hub/syzygy-services-ios
   - https://github.com/Syzygy-Hub/syzygy-ai-ios
   - https://github.com/Syzygy-Hub/syzygy-ui-ios

## Architecture

**Depends on:** all 5 Syzygy layers via SPM.

**DI wiring:** `AppDependencies.swift` uses `SyzygyCore.Container` (actor-isolated, singleton/transient/scoped lifetimes) to register Logger, URLSessionNetworkClient, SyzygyAuthProvider, KeychainStorageProvider, UserDefaultsStorageProvider, EventBus, Router, AppLifecycleTracker, InMemoryFeatureFlagProvider, ConfigRegistry, and DefaultScheduler.

**Entry point:** `SyzygyBaseApp.swift`

## Contents

```
SyzygyBase/
├── App/            Entry point, AppDependencies DI container, and app-level configuration
├── Core/           Shared extensions and utilities used across all features
├── DesignSystem/   Colours, typography tokens, and reusable UI components
├── Features/       Feature modules (Auth, Home); add your own features here
├── Navigation/     Router configuration and navigation helpers
├── Network/        Networking shims and endpoint definitions
├── Storage/        Keychain and UserDefaults storage wrappers
├── Theme/          SyzygyThemeProvider setup and theme token definitions
└── Utils/          General-purpose helpers (formatters, constants, etc.)
```

## Usage

Resolve view models through `AppDependencies`:

```swift
// In SyzygyBaseApp.swift:
SyzygyThemeProvider(theme: .default) { _ in
    LoginView(viewModel: AppDependencies.makeLoginViewModel())
}
```

`AppDependencies.makeLoginViewModel()` assembles the full dependency graph (repository → use case → view model) from the Core Container. `SyzygyThemeProvider` wraps the root view and injects theme tokens into the SwiftUI environment.

## Contributing

Follow the [Syzygy engineering standards](https://github.com/Syzygy-Hub/.github/blob/main/docs/CONTRIBUTING.md). Open a branch, make your changes, and submit a pull request against `main`.

## Releases

1. Merge all changes to `main`.
2. Update `syzygy.yml` — bump `version`.
3. Update the Version badge in this file.
4. Create and push a tag: `git tag 3.x.x && git push origin 3.x.x`.
5. GitHub Actions publishes the release automatically.
6. Verify the release appears at https://github.com/Syzygy-Hub/syzygy-base-ios/releases.

## License

MIT — see [LICENSE](LICENSE).
