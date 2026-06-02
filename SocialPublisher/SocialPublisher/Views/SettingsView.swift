import AppKit
import SwiftUI

struct SettingsView: View {
    @AppStorage("automaticCheckingEnabled") private var automaticCheckingEnabled = true
    @AppStorage("mockModeEnabled") private var mockModeEnabled = true
    @AppStorage("defaultPlatformRawValues") private var defaultPlatformRawValues = "facebook,instagram"
    @State private var defaultPlatforms: Set<SocialPlatform> = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                settingsSection("Scheduler") {
                    Toggle("Automatic minute-by-minute due-post checks", isOn: $automaticCheckingEnabled)
                    Toggle("Mock mode", isOn: $mockModeEnabled)
                    Text("Mock mode keeps publishing local. Real platform publishing requires official APIs and OAuth credentials.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }

                settingsSection("Media Library") {
                    Text(mediaLibraryPath)
                        .font(.system(.body, design: .monospaced))
                        .textSelection(.enabled)

                    Button {
                        openMediaLibrary()
                    } label: {
                        Label("Open in Finder", systemImage: "folder")
                    }
                }

                settingsSection("Default Platforms") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 220), spacing: 10)], alignment: .leading, spacing: 10) {
                        ForEach(SocialPlatform.allCases) { platform in
                            Toggle(isOn: defaultPlatformBinding(platform)) {
                                Label(platform.displayName, systemImage: platform.systemImage)
                            }
                        }
                    }
                }

                settingsSection("API Integration Notes") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Connectors live in the Connectors folder and currently return mock results.")
                        Text("Replace each placeholder connector with official SDK or URLSession API clients after OAuth setup.")
                        Text("Do not add scraping, browser automation, or unofficial posting flows.")
                    }
                    .foregroundStyle(.secondary)
                }
            }
            .padding(24)
        }
        .onAppear(perform: loadDefaults)
    }

    private var mediaLibraryPath: String {
        (try? MediaStorageService.mediaLibraryDirectory.path) ?? "Application Support path unavailable"
    }

    private func settingsSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func loadDefaults() {
        defaultPlatforms = Set(defaultPlatformRawValues.split(separator: ",").compactMap { SocialPlatform(rawValue: String($0)) })
    }

    private func defaultPlatformBinding(_ platform: SocialPlatform) -> Binding<Bool> {
        Binding {
            defaultPlatforms.contains(platform)
        } set: { isSelected in
            if isSelected {
                defaultPlatforms.insert(platform)
            } else {
                defaultPlatforms.remove(platform)
            }
            defaultPlatformRawValues = defaultPlatforms.map(\.rawValue).sorted().joined(separator: ",")
        }
    }

    private func openMediaLibrary() {
        guard let directory = try? MediaStorageService.ensureMediaLibraryExists() else { return }
        NSWorkspace.shared.activateFileViewerSelecting([directory])
    }
}
