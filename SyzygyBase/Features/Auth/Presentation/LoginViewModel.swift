//
//  LoginViewModel.swift
//  SyzygyBase
//
//  Created by Ayush Kumar Sethi on 27/07/26.
//

import Foundation
import Observation

/// Presentation-layer state and actions for the login screen.
///
/// Uses the Swift `Observation` framework's `@Observable` macro rather than
/// `ObservableObject`/`@Published`, and is pinned to `@MainActor` since it drives UI.
@MainActor
@Observable
final class LoginViewModel {

    // MARK: - Form State

    var email: String = ""
    var password: String = ""

    // MARK: - View State

    private(set) var isLoading: Bool = false
    private(set) var isAuthenticated: Bool = false
    private(set) var currentUser: User?
    var error: Error?

    // MARK: - Dependencies

    private let authUseCase: AuthUseCaseProtocol

    // MARK: - Computed Properties

    var isFormValid: Bool {
        !email.isBlank && !password.isBlank
    }

    var errorMessage: String? {
        error?.localizedDescription
    }

    // MARK: - Init

    init(authUseCase: AuthUseCaseProtocol) {
        self.authUseCase = authUseCase
    }

    // MARK: - Actions

    func login() async {
        guard isFormValid else { return }

        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            let credentials = AuthCredentials(email: email, password: password)
            currentUser = try await authUseCase.login(credentials: credentials)
            isAuthenticated = true
        } catch {
            self.error = error
        }
    }

    func logout() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await authUseCase.logout()
            isAuthenticated = false
            currentUser = nil
            email = ""
            password = ""
        } catch {
            self.error = error
        }
    }

    func checkAuthenticationStatus() async {
        isAuthenticated = await authUseCase.isAuthenticated()
        if isAuthenticated {
            currentUser = try? await authUseCase.getCurrentUser()
        }
    }

    func clearError() {
        error = nil
    }
}
