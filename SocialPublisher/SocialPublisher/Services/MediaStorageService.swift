import Foundation
import UniformTypeIdentifiers

enum MediaStorageError: LocalizedError {
    case missingApplicationSupportDirectory
    case unsupportedFileType(URL)

    var errorDescription: String? {
        switch self {
        case .missingApplicationSupportDirectory:
            "Could not locate Application Support."
        case .unsupportedFileType(let url):
            "Unsupported media type: \(url.lastPathComponent)"
        }
    }
}

enum MediaStorageService {
    static let applicationFolderName = "SocialPublisher"
    static let mediaLibraryFolderName = "MediaLibrary"

    static var applicationSupportDirectory: URL {
        get throws {
            guard let baseURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
                throw MediaStorageError.missingApplicationSupportDirectory
            }

            return baseURL.appendingPathComponent(applicationFolderName, isDirectory: true)
        }
    }

    static var mediaLibraryDirectory: URL {
        get throws {
            try applicationSupportDirectory.appendingPathComponent(mediaLibraryFolderName, isDirectory: true)
        }
    }

    @discardableResult
    static func ensureMediaLibraryExists() throws -> URL {
        let directory = try mediaLibraryDirectory
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }

    static func importMedia(from sourceURLs: [URL]) async throws -> [MediaAsset] {
        let destinationFolder = try ensureMediaLibraryExists()
        let fileManager = FileManager.default
        var importedAssets: [MediaAsset] = []

        for sourceURL in sourceURLs {
            let securityScoped = sourceURL.startAccessingSecurityScopedResource()
            defer {
                if securityScoped {
                    sourceURL.stopAccessingSecurityScopedResource()
                }
            }

            let originalName = sourceURL.lastPathComponent
            let fileExtension = sourceURL.pathExtension.lowercased()
            guard let type = UTType(filenameExtension: fileExtension), type.conforms(to: .image) else {
                throw MediaStorageError.unsupportedFileType(sourceURL)
            }

            let storedName = "\(UUID().uuidString).\(fileExtension)"
            let destinationURL = destinationFolder.appendingPathComponent(storedName)

            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }

            try fileManager.copyItem(at: sourceURL, to: destinationURL)
            let attributes = try fileManager.attributesOfItem(atPath: destinationURL.path)
            let fileSize = (attributes[.size] as? NSNumber)?.int64Value ?? 0

            importedAssets.append(
                MediaAsset(
                    fileName: storedName,
                    originalFileName: originalName,
                    localURL: destinationURL,
                    fileType: type.identifier,
                    fileSize: fileSize
                )
            )
        }

        return importedAssets
    }
}
