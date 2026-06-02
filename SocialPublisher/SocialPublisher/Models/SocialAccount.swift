import Foundation
import SwiftData

@Model
final class SocialAccount: Identifiable {
    @Attribute(.unique) var id: UUID
    var platformRawValue: String
    var accountName: String
    var accessToken: String
    var refreshToken: String
    var tokenExpiryDate: Date?
    var isConnected: Bool
    var createdAt: Date

    var platform: SocialPlatform {
        get { SocialPlatform(rawValue: platformRawValue) ?? .facebook }
        set { platformRawValue = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        platform: SocialPlatform,
        accountName: String,
        accessToken: String = "",
        refreshToken: String = "",
        tokenExpiryDate: Date? = nil,
        isConnected: Bool = false,
        createdAt: Date = .now
    ) {
        self.id = id
        self.platformRawValue = platform.rawValue
        self.accountName = accountName
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.tokenExpiryDate = tokenExpiryDate
        self.isConnected = isConnected
        self.createdAt = createdAt
    }
}
