import Foundation
import SwiftData

@Model
final class PublishLog: Identifiable {
    @Attribute(.unique) var id: UUID
    var postId: UUID
    var platformRawValue: String
    var attemptDate: Date
    var success: Bool
    var message: String
    var externalPostId: String?

    var platform: SocialPlatform {
        get { SocialPlatform(rawValue: platformRawValue) ?? .facebook }
        set { platformRawValue = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        postId: UUID,
        platform: SocialPlatform,
        attemptDate: Date = .now,
        success: Bool,
        message: String,
        externalPostId: String? = nil
    ) {
        self.id = id
        self.postId = postId
        self.platformRawValue = platform.rawValue
        self.attemptDate = attemptDate
        self.success = success
        self.message = message
        self.externalPostId = externalPostId
    }
}
