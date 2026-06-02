import SwiftData
import SwiftUI

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = AccountsViewModel()

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 52))
                .foregroundStyle(.tint)

            VStack(spacing: 10) {
                Text("SocialPublisher")
                    .font(.largeTitle.bold())
                Text("Helyi posztkezelő és ütemező app előre elkészített képekhez, szövegekhez és kampányposztokhoz.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 680)
            }

            VStack(alignment: .leading, spacing: 14) {
                Label("Piszkozatokat, ütemezett posztokat és médiatárat kezel helyben.", systemImage: "square.and.pencil")
                Label("Az importált képeket az app saját MediaLibrary mappájába másolja.", systemImage: "photo.stack")
                Label("A social platformokhoz később hivatalos API-kliens köthető.", systemImage: "lock.shield")
                Label("Most demó publikálást használ, valódi kiposztolás nélkül.", systemImage: "terminal")
            }
            .font(.body)
            .padding(20)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            Text("Fontos: valódi Facebook, Instagram, TikTok, LinkedIn, X/Twitter vagy YouTube publikálás csak hivatalos API hozzáféréssel működhet. Ez az MVP nem posztol ki valódi platformokra.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 760)

            HStack(spacing: 12) {
                Button {
                    Task {
                        await viewModel.addMissingMockAccounts(context: modelContext)
                    }
                } label: {
                    Label("Demó fiókok hozzáadása", systemImage: "person.crop.circle.badge.plus")
                }

                Button {
                    hasSeenOnboarding = true
                } label: {
                    Label("Dashboard megnyitása", systemImage: "arrow.right")
                }
                .buttonStyle(.borderedProminent)
            }

            if let statusMessage = viewModel.statusMessage {
                Text(statusMessage)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(48)
    }
}
