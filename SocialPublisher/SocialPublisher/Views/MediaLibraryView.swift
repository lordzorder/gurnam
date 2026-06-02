import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct MediaLibraryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MediaAsset.createdAt, order: .reverse) private var assets: [MediaAsset]
    @StateObject private var viewModel = MediaLibraryViewModel()
    @State private var showingFileImporter = false
    @State private var searchText = ""

    private let columns = [GridItem(.adaptive(minimum: 180, maximum: 240), spacing: 12)]

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                TextField("Search media", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .frame(minWidth: 240)

                Spacer()

                if viewModel.isImporting {
                    ProgressView()
                        .controlSize(.small)
                }

                Button {
                    showingFileImporter = true
                } label: {
                    Label("Import Images", systemImage: "square.and.arrow.down")
                }
            }
            .padding()

            Divider()

            if filteredAssets.isEmpty {
                ContentUnavailableView("No media", systemImage: "photo.on.rectangle", description: Text("Import images with the picker or drag files into this view."))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .dropDestination(for: URL.self) { urls, _ in
                        Task { await viewModel.importFiles(urls: urls, context: modelContext) }
                        return true
                    }
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(filteredAssets) { asset in
                            MediaAssetCard(asset: asset) {
                                viewModel.reveal(asset: asset)
                            }
                        }
                    }
                    .padding()
                }
                .dropDestination(for: URL.self) { urls, _ in
                    Task { await viewModel.importFiles(urls: urls, context: modelContext) }
                    return true
                }
            }
        }
        .fileImporter(isPresented: $showingFileImporter, allowedContentTypes: [.image], allowsMultipleSelection: true) { result in
            switch result {
            case .success(let urls):
                Task { await viewModel.importFiles(urls: urls, context: modelContext) }
            case .failure(let error):
                viewModel.errorMessage = error.localizedDescription
            }
        }
        .alert("Import failed", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if $0 == false { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var filteredAssets: [MediaAsset] {
        guard searchText.isEmpty == false else { return assets }
        return assets.filter {
            $0.originalFileName.localizedCaseInsensitiveContains(searchText) ||
            $0.fileName.localizedCaseInsensitiveContains(searchText)
        }
    }
}

private struct MediaAssetCard: View {
    let asset: MediaAsset
    let reveal: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            MediaThumbnailView(asset: asset)
                .frame(height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(asset.originalFileName)
                    .font(.callout.weight(.semibold))
                    .lineLimit(1)
                Text(ByteCountFormatter.string(fromByteCount: asset.fileSize, countStyle: .file))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(DateFormatters.day.string(from: asset.createdAt))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Button {
                reveal()
            } label: {
                Label("Reveal", systemImage: "folder")
            }
            .controlSize(.small)
        }
        .padding(10)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
