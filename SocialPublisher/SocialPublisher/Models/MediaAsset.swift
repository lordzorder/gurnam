import Foundation
import SwiftData

@Model
final class MediaAsset: Identifiable {
    @Attribute(.unique) var id: UUID
    var fileName: String
    var originalFileName: String
    var localURL: URL
    var fileType: String
    var createdAt: Date
    var fileSize: Int64

    init(
        id: UUID = UUID(),
        fileName: String,
        originalFileName: String,
        localURL: URL,
        fileType: String,
        createdAt: Date = .now,
        fileSize: Int64
    ) {
        self.id = id
        self.fileName = fileName
        self.originalFileName = originalFileName
        self.localURL = localURL
        self.fileType = fileType
        self.createdAt = createdAt
        self.fileSize = fileSize
    }
}
