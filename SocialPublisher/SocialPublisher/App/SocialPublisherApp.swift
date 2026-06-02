import SwiftData
import SwiftUI

@main
struct SocialPublisherApp: App {
    let modelContainer: ModelContainer = {
        let schema = Schema([
            SocialAccount.self,
            PostItem.self,
            MediaAsset.self,
            PublishLog.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create SwiftData ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .frame(minWidth: 1080, minHeight: 700)
        }
        .modelContainer(modelContainer)
    }
}

private struct AppRootView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("automaticCheckingEnabled") private var automaticCheckingEnabled = true
    @StateObject private var scheduler = SchedulerService()
    @State private var didBootstrap = false

    var body: some View {
        DashboardView()
            .environmentObject(scheduler)
            .task {
                bootstrapIfNeeded()
            }
            .onChange(of: automaticCheckingEnabled) { _, newValue in
                scheduler.start(context: modelContext, automaticCheckingEnabled: newValue)
            }
    }

    private func bootstrapIfNeeded() {
        guard didBootstrap == false else { return }
        didBootstrap = true

        _ = try? MediaStorageService.ensureMediaLibraryExists()
        SampleDataSeeder.seedIfNeeded(context: modelContext)
        scheduler.start(context: modelContext, automaticCheckingEnabled: automaticCheckingEnabled)
    }
}
