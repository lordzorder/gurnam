import Foundation

enum PostStatus: String, Codable, CaseIterable, Identifiable, Hashable {
    case draft
    case scheduled
    case published
    case failed

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .draft: "Draft"
        case .scheduled: "Scheduled"
        case .published: "Published"
        case .failed: "Failed"
        }
    }
}
