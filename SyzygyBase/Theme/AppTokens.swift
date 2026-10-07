import SwiftUI

// MARK: - App colour tokens
// Thin semantic wrappers over system colours.
// Replace with SyzygyTheme token lookups once syzygy-ui-ios is wired.

enum AppColors {
    static let background = Color(.systemBackground)
    static let surface    = Color(.secondarySystemBackground)
    static let primary    = Color.accentColor
    static let text       = Color(.label)
    static let secondaryText = Color(.secondaryLabel)
    static let success    = Color.green
    static let error      = Color.red
    static let disabled   = Color(.systemGray3)
    static let border     = Color(.separator)
}

// MARK: - App font tokens

enum AppFonts {
    static let title   = Font.title2.bold()
    static let body    = Font.body
    static let caption = Font.caption
    static let button  = Font.headline
}
