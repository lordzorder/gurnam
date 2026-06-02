import Foundation
import SwiftData

@Model
final class PostItem: Identifiable {
    @Attribute(.unique) var id: UUID
    var title: String
    var bodyText: String
    var scheduledDate: Date
    var createdAt: Date
    var updatedAt: Date
    var statusRawValue: String
    var targetPlatformRawValues: [String]

    @Relationship(deleteRule: .nullify)
    var mediaFiles: [MediaAsset] = []

    @Relationship(deleteRule: .cascade)
    var publishLogs: [PublishLog] = []

    var status: PostStatus {
        get { PostStatus(rawValue: statusRawValue) ?? .draft }
        set { statusRawValue = newValue.rawValue }
    }

    var targetPlatforms: [SocialPlatform] {
        get { targetPlatformRawValues.compactMap(SocialPlatform.init(rawValue:)) }
        set { targetPlatformRawValues = newValue.map(\.rawValue) }
    }

    init(
        id: UUID = UUID(),
        title: String,
        bodyText: String,
        scheduledDate: Date,
        createdAt: Date = .now,
        updatedAt: Date = .now,
        status: PostStatus = .draft,
        mediaFiles: [MediaAsset] = [],
        targetPlatforms: [SocialPlatform] = [],
        publishLogs: [PublishLog] = []
    ) {
        self.id = id
        self.title = title
        self.bodyText = bodyText
        self.scheduledDate = scheduledDate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.statusRawValue = status.rawValue
        self.mediaFiles = mediaFiles
        self.targetPlatformRawValues = targetPlatforms.map(\.rawValue)
        self.publishLogs = publishLogs
    }
}
