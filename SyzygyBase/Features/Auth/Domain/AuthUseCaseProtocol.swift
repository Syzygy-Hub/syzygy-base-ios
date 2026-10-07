//
//  AuthUseCaseProtocol.swift
//  SyzygyBase
//
//  Created by Ayush Kumar Sethi on 27/07/26.
//

import Foundation

// MARK: - Domain Models

/// The authenticated user, decoded from the API and persisted in the Keychain.
struct User: Codable, Sendable, Equatable, Identifiable {
    let id: String
    let email: String
    let name: String
}

/// Raw credentials supplied by the login form, before validation.
struct AuthCredentials: Sendable {
    let email: String
    let password: String
}

/// The token pair returned by the auth server and persisted in the Keychain.
struct AuthToken: Codable, Sendable, Equatable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: TimeInterval
}

// MARK: - Domain Errors

/// Validation failures raised before a request ever reaches the network layer.
enum ValidationError: LocalizedError, Sendable, Equatable {
    case invalidEmail
    case invalidPassword

    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Please enter your email address."
        case .invalidPassword:
            return "Please enter your password."
        }
    }
}

// MARK: - Use Case Protocol

/// Business logic entry point for authentication. Sits between the presentation layer
/// (view models) and the data layer (``AuthRepositoryProtocol``), owning validation
/// rules that are independent of any particular data source.
protocol AuthUseCaseProtocol: Sendable {
    func login(credentials: AuthCredentials) async throws -> User
    func logout() async throws
    func getCurrentUser() async throws -> User?
    func isAuthenticated() async -> Bool
}
