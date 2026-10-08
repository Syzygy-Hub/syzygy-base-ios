//
//  AuthUseCase.swift
//  SyzygyBase
//
//  Created by Ayush Kumar Sethi on 27/07/26.
//

import Foundation

/// Default implementation of ``AuthUseCaseProtocol``.
///
/// Owns validation rules that must hold regardless of data source, then delegates
/// the actual work to the injected repository.
final class AuthUseCase: AuthUseCaseProtocol, Sendable {

    private let repository: AuthRepositoryProtocol

    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }

    func login(credentials: AuthCredentials) async throws -> User {
        guard !credentials.email.isBlank else {
            throw ValidationError.invalidEmail
        }

        guard !credentials.password.isBlank else {
            throw ValidationError.invalidPassword
        }

        return try await repository.login(
            email: credentials.email.trimmed,
            password: credentials.password
        )
    }

    func logout() async throws {
        try await repository.logout()
    }

    func getCurrentUser() async throws -> User? {
        try await repository.getCurrentUser()
    }

    func isAuthenticated() async -> Bool {
        await repository.isAuthenticated()
    }
}
