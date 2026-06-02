import Foundation
import SwiftData

@MainActor
final class PostEditorViewModel: ObservableObject {
    @Published var errorMessage: String?
    @Published var isImportingMedia = false

    func importMedia(urls: [URL], context: ModelContext) async -> [MediaAsset] {
        isImportingMedia = true
        defer { isImportingMedia = false }

        do {
            let assets = try await MediaStorageService.importMedia(from: urls)
            assets.forEach(context.insert)
            try context.save()
            return assets
        } catch {
            errorMessage = error.localizedDescription
            return []
        }
    }

    func save(
        post: PostItem?,
        context: ModelContext,
        title: String,
        bodyText: String,
        scheduledDate: Date,
        selectedMedia: [MediaAsset],
        selectedPlatforms: Set<SocialPlatform>,
        status: PostStatus
    ) -> Bool {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedTitle.isEmpty == false else {
            errorMessage = "Title is required."
            return false
        }

        let sortedPlatforms = selectedPlatforms.sorted { $0.displayName < $1.displayName }

        if let post {
            post.title = trimmedTitle
            post.bodyText = bodyText
            post.scheduledDate = scheduledDate
            post.mediaFiles = selectedMedia
            post.targetPlatforms = sortedPlatforms
            post.status = status
            post.updatedAt = .now
        } else {
            let newPost = PostItem(
                title: trimmedTitle,
                bodyText: bodyText,
                scheduledDate: scheduledDate,
                status: status,
                mediaFiles: selectedMedia,
                targetPlatforms: sortedPlatforms
            )
            context.insert(newPost)
        }

        do {
            try context.save()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
