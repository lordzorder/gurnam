import Foundation
import SwiftData

@MainActor
final class SchedulerService: ObservableObject {
    @Published private(set) var isRunning = false
    @Published private(set) var lastCheckDate: Date?

    private var loopTask: Task<Void, Never>?

    func start(context: ModelContext, automaticCheckingEnabled: Bool) {
        stop()

        guard automaticCheckingEnabled else { return }

        isRunning = true
        loopTask = Task { @MainActor [weak self] in
            await self?.checkDuePosts(context: context)

            while Task.isCancelled == false {
                try? await Task.sleep(nanoseconds: 60_000_000_000)
                guard Task.isCancelled == false else { break }
                await self?.checkDuePosts(context: context)
            }
        }
    }

    func stop() {
        loopTask?.cancel()
        loopTask = nil
        isRunning = false
    }

    func checkDuePosts(context: ModelContext) async {
        let now = Date()
        lastCheckDate = now

        let scheduledStatus = PostStatus.scheduled.rawValue
        let descriptor = FetchDescriptor<PostItem>(
            predicate: #Predicate<PostItem> { post in
                post.statusRawValue == scheduledStatus && post.scheduledDate <= now
            },
            sortBy: [SortDescriptor(\PostItem.scheduledDate)]
        )

        guard let duePosts = try? context.fetch(descriptor), duePosts.isEmpty == false else {
            return
        }

        let accounts = (try? context.fetch(FetchDescriptor<SocialAccount>())) ?? []

        for post in duePosts {
            await publish(post: post, accounts: accounts, context: context)
        }

        try? context.save()
    }

    private func publish(post: PostItem, accounts: [SocialAccount], context: ModelContext) async {
        var allSucceeded = true
        let targets = post.targetPlatforms

        guard targets.isEmpty == false else {
            allSucceeded = false
            post.publishLogs.append(
                PublishLog(
                    postId: post.id,
                    platform: .facebook,
                    success: false,
                    message: "No target platforms selected.",
                    externalPostId: nil
                )
            )
            post.status = .failed
            post.updatedAt = .now
            return
        }

        for platform in targets {
            let connector = ConnectorFactory.connector(for: platform)
            let account = accounts.first { $0.platform == platform && $0.isConnected }
            let result = await connector.publishPost(post: post, account: account)
            allSucceeded = allSucceeded && result.success

            let log = PublishLog(
                postId: post.id,
                platform: platform,
                success: result.success,
                message: result.message,
                externalPostId: result.externalPostId
            )
            context.insert(log)
            post.publishLogs.append(log)
        }

        post.status = allSucceeded ? .published : .failed
        post.updatedAt = .now
    }
}
