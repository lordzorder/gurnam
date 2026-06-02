import AppKit
import Foundation
import SwiftData

@MainActor
final class MediaLibraryViewModel: ObservableObject {
    @Published var isImporting = false
    @Published var errorMessage: String?

    func importFiles(urls: [URL], context: ModelContext) async {
        isImporting = true
        defer { isImporting = false }

        do {
            let assets = try await MediaStorageService.importMedia(from: urls)
            assets.forEach(context.insert)
            try context.save()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func reveal(asset: MediaAsset) {
        NSWorkspace.shared.activateFileViewerSelecting([asset.localURL])
    }
}
