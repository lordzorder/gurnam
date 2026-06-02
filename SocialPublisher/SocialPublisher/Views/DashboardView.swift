import SwiftUI

struct DashboardView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @EnvironmentObject private var scheduler: SchedulerService
    @State private var selection: DashboardSection? = .scheduled
    @State private var showingNewPost = false

    var body: some View {
        if hasSeenOnboarding {
            NavigationSplitView {
                sidebar
            } detail: {
                detailView
            }
            .toolbar {
                ToolbarItemGroup {
                    schedulerIndicator
                    Button {
                        showingNewPost = true
                    } label: {
                        Label("Új poszt", systemImage: "plus")
                    }
                    .keyboardShortcut("n", modifiers: [.command])
                }
            }
            .sheet(isPresented: $showingNewPost) {
                PostEditorView()
            }
        } else {
            OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
        }
    }

    private var sidebar: some View {
        List(selection: $selection) {
            Section("Posztok") {
                ForEach([DashboardSection.drafts, .scheduled, .published, .failed, .calendar]) { section in
                    sidebarRow(section)
                }
            }

            Section("Tárhely") {
                sidebarRow(.mediaLibrary)
                sidebarRow(.accounts)
            }

            Section("Rendszer") {
                sidebarRow(.settings)
            }
        }
        .navigationTitle("SocialPublisher")
    }

    private func sidebarRow(_ section: DashboardSection) -> some View {
        NavigationLink(value: section) {
            Label(section.title, systemImage: section.systemImage)
        }
    }

    @ViewBuilder
    private var detailView: some View {
        switch selection ?? .scheduled {
        case .drafts:
            PostListView(initialStatus: .draft)
                .navigationTitle("Piszkozatok")
        case .scheduled:
            PostListView(initialStatus: .scheduled)
                .navigationTitle("Ütemezve")
        case .published:
            PostListView(initialStatus: .published)
                .navigationTitle("Publikálva")
        case .failed:
            PostListView(initialStatus: .failed)
                .navigationTitle("Sikertelen")
        case .calendar:
            CalendarView()
                .navigationTitle("Naptár")
        case .mediaLibrary:
            MediaLibraryView()
                .navigationTitle("Médiatár")
        case .accounts:
            AccountsView()
                .navigationTitle("Fiókok")
        case .settings:
            SettingsView()
                .navigationTitle("Beállítások")
        }
    }

    private var schedulerIndicator: some View {
        Label(
            scheduler.isRunning ? "Ütemező aktív" : "Ütemező kikapcsolva",
            systemImage: scheduler.isRunning ? "bolt.badge.checkmark" : "bolt.slash"
        )
        .foregroundStyle(scheduler.isRunning ? .green : .secondary)
        .labelStyle(.titleAndIcon)
    }
}
