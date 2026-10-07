import SwiftUI
// import SyzygyUI // uncomment after adding SPM packages via Xcode

// TODO: Implement ThemeSetup
// SyzygyThemeProvider wraps the WindowGroup content so all descendant views can
// read the active theme via @Environment(\.syzygyTheme).
//
// Usage (after adding syzygy-ui-ios via Xcode → File → Add Package Dependencies):
//
//   import SyzygyUI
//
//   WindowGroup {
//       SyzygyThemeProvider(theme: .default) { _ in
//           LoginView(viewModel: AppDependencies.makeLoginViewModel())
//       }
//   }
enum ThemeSetup {
    // Add theme customisation helpers here, e.g. custom colour tokens or font overrides.
}
