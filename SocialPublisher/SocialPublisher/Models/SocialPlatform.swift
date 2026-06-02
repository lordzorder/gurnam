import Foundation

enum SocialPlatform: String, Codable, CaseIterable, Identifiable, Hashable {
    case facebook
    case instagram
    case linkedIn
    case twitter
    case tikTok
    case youtube

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .facebook: "Facebook Page"
        case .instagram: "Instagram Business"
        case .linkedIn: "LinkedIn"
        case .twitter: "X / Twitter"
        case .tikTok: "TikTok"
        case .youtube: "YouTube"
        }
    }

    var systemImage: String {
        switch self {
        case .facebook: "person.2.crop.square.stack"
        case .instagram: "camera"
        case .linkedIn: "briefcase"
        case .twitter: "text.bubble"
        case .tikTok: "music.note"
        case .youtube: "play.rectangle"
        }
    }
}
