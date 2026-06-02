import Foundation

enum ConnectorFactory {
    static func connector(for platform: SocialPlatform) -> SocialPlatformConnector {
        switch platform {
        case .facebook: FacebookConnector()
        case .instagram: InstagramConnector()
        case .linkedIn: LinkedInConnector()
        case .twitter: TwitterConnector()
        case .tikTok: TikTokConnector()
        case .youtube: YouTubeConnector()
        }
    }
}
