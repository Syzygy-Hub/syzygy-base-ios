//
//  String+Extensions.swift
//  SyzygyBase
//
//  Created by Ayush Kumar Sethi on 27/07/26.
//

import Foundation

extension String {

    // MARK: - Validation

    /// Whether the string is empty once leading/trailing whitespace is removed.
    var isBlank: Bool {
        trimmed.isEmpty
    }

    /// A lightweight, client-side email format check.
    ///
    /// This is intentionally permissive — it exists to catch obvious typos before a
    /// network round trip, not to fully validate RFC 5322 addresses. The backend
    /// remains the source of truth for whether an address is deliverable.
    var isValidEmail: Bool {
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return range(of: pattern, options: .regularExpression) != nil
    }

    /// Whether the string meets a minimum password length of 8 characters.
    var isValidPassword: Bool {
        count >= 8
    }

    // MARK: - Transformations

    /// The string with leading and trailing whitespace/newlines removed.
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// The string with its first letter capitalized, leaving the rest untouched.
    var capitalizedFirstLetter: String {
        guard let first else { return self }
        return first.uppercased() + dropFirst()
    }

    /// Truncates the string to `length` characters, appending `trailing` when truncated.
    func truncated(to length: Int, trailing: String = "…") -> String {
        guard count > length else { return self }
        return String(prefix(length)) + trailing
    }

    // MARK: - Masking

    /// Masks all but the first and last character, e.g. for displaying stored secrets.
    /// Strings shorter than 3 characters are masked entirely.
    var masked: String {
        guard count > 2 else { return String(repeating: "•", count: count) }
        let first = self[startIndex]
        let last = self[index(before: endIndex)]
        return "\(first)\(String(repeating: "•", count: count - 2))\(last)"
    }
}
