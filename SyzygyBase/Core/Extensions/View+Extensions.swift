//
//  View+Extensions.swift
//  SyzygyBase
//
//  Created by Ayush Kumar Sethi on 27/07/26.
//

import SwiftUI

// MARK: - Conditional Modifiers

extension View {

    /// Applies `transform` only when `condition` is true.
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    /// Applies `transform` only when `value` is non-nil, passing the unwrapped value through.
    @ViewBuilder
    func ifLet<T, Content: View>(_ value: T?, transform: (Self, T) -> Content) -> some View {
        if let value {
            transform(self, value)
        } else {
            self
        }
    }

    /// Hides the view while preserving layout space, based on `shouldHide`.
    @ViewBuilder
    func hidden(_ shouldHide: Bool) -> some View {
        if shouldHide {
            self.hidden()
        } else {
            self
        }
    }
}

// MARK: - Loading & Errors

extension View {

    /// Dims the view and overlays a centered spinner while `isLoading` is true.
    func loadingOverlay(_ isLoading: Bool) -> some View {
        self.overlay {
            if isLoading {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()

                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.5)
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isLoading)
    }

    /// Presents a generic error alert bound to an optional `Error`, clearing it on dismiss.
    func errorAlert(error: Binding<Error?>) -> some View {
        self.alert("Error", isPresented: Binding(
            get: { error.wrappedValue != nil },
            set: { isPresented in
                if !isPresented {
                    error.wrappedValue = nil
                }
            }
        )) {
            Button("OK", role: .cancel) {
                error.wrappedValue = nil
            }
        } message: {
            Text(error.wrappedValue?.localizedDescription ?? "")
        }
    }
}

// MARK: - Shape Helpers

extension View {
    /// Rounds specific corners of the view rather than all four.
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

private struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    nonisolated func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Keyboard

extension View {
    /// Resigns the first responder, dismissing the on-screen keyboard.
    func dismissKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }

    /// Dismisses the keyboard whenever the view is tapped.
    func dismissKeyboardOnTap() -> some View {
        self.onTapGesture(perform: dismissKeyboard)
    }
}
