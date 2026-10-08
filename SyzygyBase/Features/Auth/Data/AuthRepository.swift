//
//  AuthRepository.swift
//  SyzygyBase
//
//  Created by Ayush Kumar Sethi on 27/07/26.
//

import Foundation
// import SyzygyServices  // uncomment after adding SPM packages via Xcode

// MARK: - Legacy network types
// These thin local protocols mirror the shape expected by AuthRepository's mock
// implementation. Replace with direct use of SyzygyFoundation.NetworkClientProtocol
// (which uses NetworkRequest/NetworkResponse) once SyzygyServices is wired up.

protocol LegacyNetworkClientProtocol: Sendable {
    func request<T: Decodable>(_ endpoint: any Endpoint) async throws -> T
    func request(_ endpoint: any Endpoint) async throws
}

protocol Endpoint: Sendable {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var body: Data? { get }
}

enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

// MARK: - Repository Protocol

/// Data-layer abstraction for authentication. Hides whether a given operation is
/// served from the network, the Keychain, or a combination of both.
protocol AuthRepositoryProtocol: Sendable {
    func login(email: String, password: String) async throws -> User
    func logout() async throws
    func getCurrentUser() async throws -> User?
    func isAuthenticated() async -> Bool
}

// MARK: - Repository Implementation

/// Concrete auth repository that wraps ``SyzygyAuthProvider`` from SyzygyServices.
///
/// This is the domain boundary: feature-layer code calls ``AuthRepository``,
/// never ``SyzygyAuthProvider`` directly.
///
/// Migration steps:
/// 1. Add syzygy-services-ios via Xcode → File → Add Package Dependencies.
/// 2. Uncomment the `import SyzygyServices` line above.
/// 3. Remove the legacy shims (``LegacyNetworkClientAdapter``, ``KeychainManagerLegacyShim``)
///    from AppDependencies.swift once the DI container supplies SyzygyAuthProvider here.
final class AuthRepository: AuthRepositoryProtocol, Sendable {

    // ── Injected dependencies ────────────────────────────────────────────────
    // SyzygyAuthProvider is resolved from AppDependencies.container at construction.
    // The networkClient is retained separately to issue the remote login call;
    // SyzygyAuthProvider itself only stores/manages the resulting token.

    private let networkClient: any LegacyNetworkClientProtocol
    private let keychainManager: KeychainManagerLegacyShim

    // ── SyzygyAuthProvider wiring (uncomment after adding SPM package) ───────
    // private let authProvider: SyzygyAuthProvider
    //
    // init(authProvider: SyzygyAuthProvider) {
    //     self.authProvider = authProvider
    // }

    private enum StorageKey {
        static let token = "auth_token"
        static let user = "current_user"
    }

    init(networkClient: any LegacyNetworkClientProtocol, keychainManager: KeychainManagerLegacyShim) {
        self.networkClient = networkClient
        self.keychainManager = keychainManager
    }

    // MARK: - Login
    //
    // Intended live flow (uncomment after wiring SyzygyAuthProvider):
    //
    //   func login(email: String, password: String) async throws -> User {
    //       // 1. Make the remote call to obtain a token.
    //       let endpoint = AuthEndpoint.login(email: email, password: password)
    //       let response: LoginResponse = try await networkClient.request(endpoint)
    //
    //       // 2. Hand the token to SyzygyAuthProvider for persistence.
    //       //    authenticate(token:) stores the token in the Keychain and transitions
    //       //    authProvider.state to .authenticated.
    //       authProvider.authenticate(token: response.token)
    //
    //       return response.user
    //   }
    //
    // Until SyzygyAuthProvider is linked the implementation below uses a local mock:
    func login(email: String, password: String) async throws -> User {
        // Mocked authentication — replace with the live flow above once
        // syzygy-services-ios is added as an SPM dependency.
        try await Task.sleep(nanoseconds: 400_000_000)

        let name = email.components(separatedBy: "@").first?.capitalizedFirstLetter ?? "User"
        let user = User(id: UUID().uuidString, email: email, name: name)
        let token = AuthToken(accessToken: UUID().uuidString, refreshToken: UUID().uuidString, expiresIn: 3600)

        try keychainManager.save(token, for: StorageKey.token)
        try keychainManager.save(user, for: StorageKey.user)

        return user
    }

    // MARK: - Logout
    //
    // Intended live flow (uncomment after wiring SyzygyAuthProvider):
    //
    //   func logout() async throws {
    //       // signOut() removes the token from the Keychain and transitions
    //       // authProvider.state to .unauthenticated.
    //       authProvider.signOut()
    //   }
    //
    func logout() async throws {
        try keychainManager.delete(for: StorageKey.token)
        try keychainManager.delete(for: StorageKey.user)
    }

    // MARK: - Token Refresh
    //
    // Intended live flow (uncomment after wiring SyzygyAuthProvider):
    //
    //   func refreshToken() async throws -> AuthToken {
    //       // refresh() calls the configured refreshEndpoint via the network client,
    //       // decodes the new token, persists it via Keychain, and transitions
    //       // authProvider.state back to .authenticated.
    //       return try await authProvider.refresh()
    //   }

    func getCurrentUser() async throws -> User? {
        do {
            return try keychainManager.retrieve(for: StorageKey.user, as: User.self)
        } catch {
            return nil
        }
    }

    func isAuthenticated() async -> Bool {
        (try? keychainManager.retrieve(for: StorageKey.token, as: AuthToken.self)) != nil
        // Live equivalent using SyzygyAuthProvider:
        //   authProvider.state == .authenticated(token:)  — compare via pattern match
    }
}

// MARK: - Endpoints

enum AuthEndpoint: Endpoint {
    case login(email: String, password: String)
    case logout

    var baseURL: String {
        AppEnvironment.current.baseURL
    }

    var path: String {
        switch self {
        case .login:
            return "/auth/login"
        case .logout:
            return "/auth/logout"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .login, .logout:
            return .post
        }
    }

    var body: Data? {
        switch self {
        case .login(let email, let password):
            let payload = LoginRequest(email: email, password: password)
            return try? JSONEncoder().encode(payload)
        case .logout:
            return nil
        }
    }
}

// MARK: - Data Transfer Objects

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct LoginResponse: Decodable {
    let user: User
    let token: AuthToken
}

// MARK: - Environment

/// The set of backend environments the app can target. Replace `baseURL` values with
/// your real endpoints, and switch `current` per build configuration/scheme as needed.
enum AppEnvironment {
    case development
    case staging
    case production

    var baseURL: String {
        switch self {
        case .development:
            return "https://dev.api.example.com"
        case .staging:
            return "https://staging.api.example.com"
        case .production:
            return "https://api.example.com"
        }
    }

    static let current: AppEnvironment = {
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }()
}
