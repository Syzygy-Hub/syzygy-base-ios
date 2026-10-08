// MARK: - AppDependencies
// Wires all 5 Syzygy layers into the Core DI Container.
// Add your own feature registrations below the layer registrations.

import Foundation
import SyzygyFoundation
import SyzygyCore
import SyzygyServices
import SyzygyAI
import syzygy_ui_ios

/// Shared root DI container for the app.
///
/// Registration order:
/// 1. Infrastructure (Logger, Scheduler, ConfigRegistry)
/// 2. Networking & Storage (NetworkClient, StorageProvider)
/// 3. Auth (AuthProvider)
/// 4. Core machinery (StateStore placeholder, EventBus, Router, AppLifecycleTracker, FeatureFlagProvider)
@MainActor
enum AppDependencies {

    // MARK: - Shared container

    static let container: Container = {
        let newContainer = Container()
        Task { await registerAll(in: newContainer) }
        return newContainer
    }()

    // MARK: - Registration

    static func registerAll(in container: Container) async {

        // ── Layer 1: Logging ──────────────────────────────────────────────────────
        await container.register(Logger.self, lifetime: .singleton) { _ in
            let logger = Logger()
            logger.addDestination(ConsoleLogDestination(), minLevel: .debug)
            return logger
        }

        // ── Layer 1: Scheduling ───────────────────────────────────────────────────
        await container.register(DefaultScheduler.self, lifetime: .singleton) { _ in
            DefaultScheduler()
        }

        // ── Layer 1: Configuration ────────────────────────────────────────────────
        await container.register(ConfigRegistry.self, lifetime: .singleton) { _ in
            #if DEBUG
            return ConfigRegistry(environment: .debug)
            #else
            return ConfigRegistry(environment: .production)
            #endif
        }

        // ── Layer 2: Networking ───────────────────────────────────────────────────
        await container.register(URLSessionNetworkClient.self, lifetime: .singleton) { resolver in
            let logger = try await resolver.resolve(Logger.self)
            return URLSessionNetworkClient(logger: logger)
        }

        // ── Layer 2: Storage (UserDefaults for non-sensitive data) ────────────────
        await container.register(UserDefaultsStorageProvider.self, lifetime: .singleton) { _ in
            UserDefaultsStorageProvider()
        }

        // ── Layer 2: Storage (Keychain for sensitive data) ────────────────────────
        await container.register(KeychainStorageProvider.self, lifetime: .singleton) { _ in
            KeychainStorageProvider()
        }

        // ── Layer 3: Auth ─────────────────────────────────────────────────────────
        await container.register(SyzygyAuthProvider.self, lifetime: .singleton) { resolver in
            let keychain = try await resolver.resolve(KeychainStorageProvider.self)
            let network = try await resolver.resolve(URLSessionNetworkClient.self)
            return SyzygyAuthProvider(storage: keychain, networkClient: network)
        }

        // ── Layer 4: Event Bus ────────────────────────────────────────────────────
        await container.register(EventBus.self, lifetime: .singleton) { _ in
            EventBus()
        }

        // ── Layer 4: Router ───────────────────────────────────────────────────────
        await container.register(Router.self, lifetime: .singleton) { _ in
            Router()
        }

        // ── Layer 4: App Lifecycle ────────────────────────────────────────────────
        await container.register(AppLifecycleTracker.self, lifetime: .singleton) { _ in
            AppLifecycleTracker.fromNotificationCenter()
        }

        // ── Layer 4: Feature Flags ────────────────────────────────────────────────
        await container.register(InMemoryFeatureFlagProvider.self, lifetime: .singleton) { _ in
            InMemoryFeatureFlagProvider()
        }

        // ── StateStore (register once you define AppState and AppAction) ─────────────
        // StateStore<State, Action> is generic — you must define your own state/action types.
        //
        // Example:
        //
        //   struct AppState { var isLoggedIn = false; var user: User? = nil }
        //   enum AppAction { case login(User); case logout }
        //   func appReducer(state: AppState, action: AppAction) -> AppState {
        //       var next = state
        //       switch action {
        //       case .login(let user): next.isLoggedIn = true; next.user = user
        //       case .logout:          next.isLoggedIn = false; next.user = nil
        //       }
        //       return next
        //   }
        //
        //   await container.register(StateStore<AppState, AppAction>.self, lifetime: .singleton) { _ in
        //       StateStore(initial: AppState(), reducer: appReducer)
        //   }
        //
        // See syzygy-core-ios Sources/SyzygyCore/State/StateStore.swift for the full API.

        // ── AI Layer registrations ────────────────────────────────────────────────
        // SyzygyAI exports protocols only; concrete implementations must be provided
        // by the consumer. Register your own types here once you have implementations:
        //
        //   await container.register(LLMProvider.self, lifetime: .singleton) { _ in
        //       MyLLMProvider(apiKey: "...")
        //   }
        //   await container.register(EmbeddingProvider.self, lifetime: .singleton) { _ in
        //       MyEmbeddingProvider()
        //   }
        //   await container.register(MemoryManager.self, lifetime: .singleton) { _ in
        //       MyMemoryManager()
        //   }
    }

    // MARK: - Convenience resolvers
    // Add typed accessors here to avoid spelling out resolve() at call sites.

    static func makeLoginViewModel() -> LoginViewModel {
        // Feature view models are still constructed synchronously via the legacy
        // pattern until the Auth feature is migrated to layer types. Update this
        // method once AuthRepository is updated to depend on SyzygyAuthProvider.
        let authRepository: AuthRepositoryProtocol = AuthRepository(
            networkClient: LegacyNetworkClientAdapter(),
            keychainManager: KeychainManagerLegacyShim()
        )
        let authUseCase: AuthUseCaseProtocol = AuthUseCase(repository: authRepository)
        return LoginViewModel(authUseCase: authUseCase)
    }
}

// MARK: - Legacy shims
// Thin adapters that let the existing feature layer compile while NetworkClient
// and KeychainManager shadow files are removed. Replace these with direct use of
// URLSessionNetworkClient / KeychainStorageProvider once AuthRepository is migrated.

/// Wraps URLSessionNetworkClient to satisfy the legacy NetworkClientProtocol shape.
private final class LegacyNetworkClientAdapter: LegacyNetworkClientProtocol, Sendable {
    func request<T: Decodable>(_ endpoint: any Endpoint) async throws -> T {
        throw LegacyError.notMigrated
    }
    func request(_ endpoint: any Endpoint) async throws {
        throw LegacyError.notMigrated
    }
}

/// Satisfies AuthRepository's KeychainManager dependency during migration.
final class KeychainManagerLegacyShim: Sendable {
    func save<T: Encodable>(_ value: T, for key: String) throws {}
    func retrieve<T: Decodable>(for key: String, as type: T.Type) throws -> T {
        throw LegacyError.notMigrated
    }
    func delete(for key: String) throws {}
}

private enum LegacyError: Error {
    case notMigrated
}
