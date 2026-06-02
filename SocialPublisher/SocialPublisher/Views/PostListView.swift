import SwiftData
import SwiftUI

struct PostListView: View {
    @Query(sort: \PostItem.scheduledDate, order: .forward) private var posts: [PostItem]
    @State private var searchText = ""
    @State private var selectedPlatform: SocialPlatform?
    @State private var selectedStatus: PostStatus?
    @State private var selectedPost: PostItem?

    private let initialStatus: PostStatus?

    init(initialStatus: PostStatus? = nil) {
        self.initialStatus = initialStatus
        _selectedStatus = State(initialValue: initialStatus)
    }

    var body: some View {
        VStack(spacing: 0) {
            filters
                .padding()

            Divider()

            if filteredPosts.isEmpty {
                ContentUnavailableView("No posts", systemImage: "tray", description: Text("Create a new post or adjust your filters."))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(filteredPosts) { post in
                    Button {
                        selectedPost = post
                    } label: {
                        PostRowView(post: post)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button("Edit") { selectedPost = post }
                    }
                }
                .listStyle(.inset)
            }
        }
        .sheet(item: $selectedPost) { post in
            PostEditorView(post: post)
        }
    }

    private var filters: some View {
        HStack(spacing: 12) {
            TextField("Search posts", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .frame(minWidth: 220)

            Picker("Status", selection: $selectedStatus) {
                Text("All Statuses").tag(PostStatus?.none)
                ForEach(PostStatus.allCases) { status in
                    Text(status.displayName).tag(Optional(status))
                }
            }
            .frame(width: 170)

            Picker("Platform", selection: $selectedPlatform) {
                Text("All Platforms").tag(SocialPlatform?.none)
                ForEach(SocialPlatform.allCases) { platform in
                    Label(platform.displayName, systemImage: platform.systemImage)
                        .tag(Optional(platform))
                }
            }
            .frame(width: 220)

            Spacer()

            Text("\(filteredPosts.count) post\(filteredPosts.count == 1 ? "" : "s")")
                .foregroundStyle(.secondary)
        }
    }

    private var filteredPosts: [PostItem] {
        posts.filter { post in
            let matchesSearch = searchText.isEmpty ||
                post.title.localizedCaseInsensitiveContains(searchText) ||
                post.bodyText.localizedCaseInsensitiveContains(searchText)
            let matchesStatus = selectedStatus.map { post.status == $0 } ?? true
            let matchesPlatform = selectedPlatform.map { post.targetPlatforms.contains($0) } ?? true
            return matchesSearch && matchesStatus && matchesPlatform
        }
    }
}

private struct PostRowView: View {
    let post: PostItem

    var body: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Text(post.title)
                        .font(.headline)
                        .lineLimit(1)
                    StatusBadge(status: post.status)
                }

                Text(post.bodyText.isEmpty ? "No body text" : post.bodyText)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                HStack(spacing: 8) {
                    Label(DateFormatters.dateTime.string(from: post.scheduledDate), systemImage: "calendar")
                    Label("\(post.mediaFiles.count)", systemImage: "photo")
                    ForEach(post.targetPlatforms) { platform in
                        Label(platform.displayName, systemImage: platform.systemImage)
                            .labelStyle(.iconOnly)
                            .help(platform.displayName)
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 8)
    }
}

struct StatusBadge: View {
    let status: PostStatus

    var body: some View {
        Text(status.displayName)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(status.tint.opacity(0.16))
            .foregroundStyle(status.tint)
            .clipShape(Capsule())
    }
}

extension PostStatus {
    var tint: Color {
        switch self {
        case .draft: .secondary
        case .scheduled: .blue
        case .published: .green
        case .failed: .red
        }
    }
}
