import Foundation
import SwiftData

@MainActor
enum SampleDataSeeder {
    static func seedIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<PostItem>()
        let postCount = (try? context.fetchCount(descriptor)) ?? 0
        guard postCount == 0 else { return }

        let now = Date()
        let drafts = PostItem(
            title: "Spring campaign draft",
            bodyText: "Short teaser copy for the upcoming campaign.",
            scheduledDate: Calendar.current.date(byAdding: .day, value: 2, to: now) ?? now,
            status: .draft,
            targetPlatforms: [.instagram, .facebook]
        )

        let scheduled = PostItem(
            title: "Weekly product tip",
            bodyText: "A practical post prepared for scheduled mock publishing.",
            scheduledDate: Calendar.current.date(byAdding: .hour, value: 3, to: now) ?? now,
            status: .scheduled,
            targetPlatforms: [.linkedIn, .twitter]
        )

        let publishedLog = PublishLog(
            postId: UUID(),
            platform: .facebook,
            success: true,
            message: "Mock publish completed during sample seeding.",
            externalPostId: "mock-facebook-sample"
        )
        let published = PostItem(
            id: publishedLog.postId,
            title: "Already published sample",
            bodyText: "This shows how successful publish history appears.",
            scheduledDate: Calendar.current.date(byAdding: .day, value: -1, to: now) ?? now,
            status: .published,
            targetPlatforms: [.facebook],
            publishLogs: [publishedLog]
        )

        let failedLog = PublishLog(
            postId: UUID(),
            platform: .tikTok,
            success: false,
            message: "Mock failure example. No official API call was made.",
            externalPostId: nil
        )
        let failed = PostItem(
            id: failedLog.postId,
            title: "[fail] Failed sample",
            bodyText: "This sample demonstrates error logs.",
            scheduledDate: Calendar.current.date(byAdding: .hour, value: -5, to: now) ?? now,
            status: .failed,
            targetPlatforms: [.tikTok],
            publishLogs: [failedLog]
        )

        let demoAccount = SocialAccount(
            platform: .facebook,
            accountName: "Demo Facebook Page",
            accessToken: "mock_access_facebook",
            refreshToken: "mock_refresh_facebook",
            tokenExpiryDate: Calendar.current.date(byAdding: .day, value: 30, to: now),
            isConnected: true
        )

        [drafts, scheduled, published, failed].forEach(context.insert)
        context.insert(demoAccount)
        try? context.save()
    }
}
