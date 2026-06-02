import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct PostEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @AppStorage("defaultPlatformRawValues") private var defaultPlatformRawValues = "facebook,instagram"
    @StateObject private var viewModel = PostEditorViewModel()

    private let post: PostItem?

    @State private var title: String
    @State private var bodyText: String
    @State private var scheduledDate: Date
    @State private var selectedPlatforms: Set<SocialPlatform>
    @State private var selectedMedia: [MediaAsset]
    @State private var showingFileImporter = false

    init(post: PostItem? = nil) {
        self.post = post
        _title = State(initialValue: post?.title ?? "")
        _bodyText = State(initialValue: post?.bodyText ?? "")
        _scheduledDate = State(initialValue: post?.scheduledDate ?? Calendar.current.date(byAdding: .hour, value: 1, to: .now) ?? .now)
        _selectedPlatforms = State(initialValue: Set(post?.targetPlatforms ?? []))
        _selectedMedia = State(initialValue: post?.mediaFiles ?? [])
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            Divider()

            ScrollView {
                HStack(alignment: .top, spacing: 24) {
                    mainForm
                    mediaPanel
                }
                .padding(24)
            }

            Divider()

            footer
        }
        .frame(minWidth: 820, minHeight: 660)
        .fileImporter(isPresented: $showingFileImporter, allowedContentTypes: [.image], allowsMultipleSelection: true) { result in
            switch result {
            case .success(let urls):
                importMedia(urls)
            case .failure(let error):
                viewModel.errorMessage = error.localizedDescription
            }
        }
        .alert("Post could not be saved", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if $0 == false { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .onAppear {
            if post == nil && selectedPlatforms.isEmpty {
                selectedPlatforms = Set(defaultPlatformRawValues.split(separator: ",").compactMap { SocialPlatform(rawValue: String($0)) })
            }
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(post == nil ? "New Post" : "Edit Post")
                    .font(.title2.bold())
                Text("Mock publishing only until official platform API credentials are connected.")
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(24)
    }

    private var mainForm: some View {
        VStack(alignment: .leading, spacing: 18) {
            TextField("Title", text: $title)
                .font(.title3)
                .textFieldStyle(.roundedBorder)

            VStack(alignment: .leading, spacing: 8) {
                Text("Body Text")
                    .font(.headline)
                TextEditor(text: $bodyText)
                    .font(.body)
                    .frame(minHeight: 180)
                    .scrollContentBackground(.hidden)
                    .background(.quaternary.opacity(0.35))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }

            DatePicker("Scheduled Date", selection: $scheduledDate, displayedComponents: [.date, .hourAndMinute])

            VStack(alignment: .leading, spacing: 10) {
                Text("Target Platforms")
                    .font(.headline)

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 180), spacing: 10)], alignment: .leading, spacing: 10) {
                    ForEach(SocialPlatform.allCases) { platform in
                        Toggle(isOn: platformBinding(platform)) {
                            Label(platform.displayName, systemImage: platform.systemImage)
                        }
                    }
                }
            }

            if let post {
                PublishLogView(post: post)
            }
        }
        .frame(minWidth: 460, maxWidth: .infinity, alignment: .leading)
    }

    private var mediaPanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Media")
                    .font(.headline)
                Spacer()
                Button {
                    showingFileImporter = true
                } label: {
                    Label("Add Images", systemImage: "plus")
                }
            }

            VStack(spacing: 12) {
                if selectedMedia.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "photo.badge.plus")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                        Text("Drop images here or use Add Images.")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, minHeight: 180)
                } else {
                    ForEach(selectedMedia) { asset in
                        HStack(spacing: 10) {
                            MediaThumbnailView(asset: asset)
                                .frame(width: 72, height: 54)
                                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))

                            VStack(alignment: .leading, spacing: 3) {
                                Text(asset.originalFileName)
                                    .font(.callout)
                                    .lineLimit(1)
                                Text(ByteCountFormatter.string(fromByteCount: asset.fileSize, countStyle: .file))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Button {
                                selectedMedia.removeAll { $0.id == asset.id }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(.secondary)
                            .help("Remove from this post")
                        }
                    }
                }
            }
            .padding(16)
            .frame(width: 280)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .dropDestination(for: URL.self) { urls, _ in
                importMedia(urls)
                return true
            }
        }
    }

    private var footer: some View {
        HStack {
            if viewModel.isImportingMedia {
                ProgressView()
                    .controlSize(.small)
                Text("Importing media...")
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button("Cancel") {
                dismiss()
            }

            Button {
                save(status: .draft)
            } label: {
                Label("Save Draft", systemImage: "tray.and.arrow.down")
            }

            Button {
                save(status: .scheduled)
            } label: {
                Label("Schedule", systemImage: "calendar.badge.plus")
            }
            .buttonStyle(.borderedProminent)
            .disabled(selectedPlatforms.isEmpty)
        }
        .padding(18)
    }

    private func platformBinding(_ platform: SocialPlatform) -> Binding<Bool> {
        Binding {
            selectedPlatforms.contains(platform)
        } set: { isSelected in
            if isSelected {
                selectedPlatforms.insert(platform)
            } else {
                selectedPlatforms.remove(platform)
            }
        }
    }

    private func importMedia(_ urls: [URL]) {
        Task {
            let assets = await viewModel.importMedia(urls: urls, context: modelContext)
            selectedMedia.append(contentsOf: assets)
        }
    }

    private func save(status: PostStatus) {
        let saved = viewModel.save(
            post: post,
            context: modelContext,
            title: title,
            bodyText: bodyText,
            scheduledDate: scheduledDate,
            selectedMedia: selectedMedia,
            selectedPlatforms: selectedPlatforms,
            status: status
        )

        if saved {
            dismiss()
        }
    }
}
