import Foundation

struct AuthenticationResult {
    let accessToken: String
    let refreshToken: String
    let expiryDate: Date
}

struct PublishResult {
    let success: Bool
    let message: String
    let externalPostId: String?
}

protocol SocialPlatformConnector {
    var platform: SocialPlatform { get }

    func authenticate() async throws -> AuthenticationResult
    func refreshToken(account: SocialAccount) async throws -> AuthenticationResult
    func publishPost(post: PostItem, account: SocialAccount?) async -> PublishResult
    func validateConnection(account: SocialAccount) async -> Bool
}

// Shared mock base used until official platform API clients are wired in.
// TODO: Replace subclasses with real OAuth and API clients per platform.
class MockSocialPlatformConnector: SocialPlatformConnector {
    let platform: SocialPlatform

    init(platform: SocialPlatform) {
        self.platform = platform
    }

    func authenticate() async throws -> AuthenticationResult {
        try await Task.sleep(nanoseconds: 150_000_000)
        return AuthenticationResult(
            accessToken: "mock_access_\(platform.rawValue)",
            refreshToken: "mock_refresh_\(platform.rawValue)",
            expiryDate: Calendar.current.date(byAdding: .day, value: 30, to: .now) ?? .now
        )
    }

    func refreshToken(account: SocialAccount) async throws -> AuthenticationResult {
        try await Task.sleep(nanoseconds: 100_000_000)
        return AuthenticationResult(
            accessToken: "mock_refreshed_access_\(platform.rawValue)",
            refreshToken: account.refreshToken.isEmpty ? "mock_refresh_\(platform.rawValue)" : account.refreshToken,
            expiryDate: Calendar.current.date(byAdding: .day, value: 30, to: .now) ?? .now
        )
    }

    func publishPost(post: PostItem, account: SocialAccount?) async -> PublishResult {
        try? await Task.sleep(nanoseconds: 250_000_000)

        guard account?.isConnected == true else {
            return PublishResult(
                success: false,
                message: "\(platform.displayName): no connected account. Official API credentials are required.",
                externalPostId: nil
            )
        }

        if post.title.localizedCaseInsensitiveContains("[fail]") {
            return PublishResult(
                success: false,
                message: "\(platform.displayName): mock failure triggered by post title.",
                externalPostId: nil
            )
        }

        return PublishResult(
            success: true,
            message: "\(platform.displayName): mock publish completed. No real social API call was made.",
            externalPostId: "mock-\(platform.rawValue)-\(UUID().uuidString.prefix(8))"
        )
    }

    func validateConnection(account: SocialAccount) async -> Bool {
        try? await Task.sleep(nanoseconds: 100_000_000)
        return account.isConnected && !account.accessToken.isEmpty
    }
}
