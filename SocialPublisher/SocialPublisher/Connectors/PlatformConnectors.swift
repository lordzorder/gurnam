import Foundation

final class FacebookConnector: MockSocialPlatformConnector {
    init() { super.init(platform: .facebook) }
}

final class InstagramConnector: MockSocialPlatformConnector {
    init() { super.init(platform: .instagram) }
}

final class LinkedInConnector: MockSocialPlatformConnector {
    init() { super.init(platform: .linkedIn) }
}

final class TwitterConnector: MockSocialPlatformConnector {
    init() { super.init(platform: .twitter) }
}

final class TikTokConnector: MockSocialPlatformConnector {
    init() { super.init(platform: .tikTok) }
}

final class YouTubeConnector: MockSocialPlatformConnector {
    init() { super.init(platform: .youtube) }
}
