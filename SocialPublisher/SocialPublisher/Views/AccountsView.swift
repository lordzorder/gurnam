import SwiftData
import SwiftUI

struct AccountsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SocialAccount.createdAt, order: .reverse) private var accounts: [SocialAccount]
    @StateObject private var viewModel = AccountsViewModel()
    @State private var selectedPlatform: SocialPlatform = .facebook
    @State private var accountName = ""

    var body: some View {
        VStack(spacing: 0) {
            addAccountPanel
                .padding()

            Divider()

            if accounts.isEmpty {
                ContentUnavailableView("Nincs fiók", systemImage: "person.crop.circle.badge.plus", description: Text("Adj hozzá demó fiókot. A valódi social bejelentkezés későbbi API-integrációval kerülhet be."))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(accounts) { account in
                    AccountRow(account: account, validate: {
                        Task { await viewModel.validate(account: account) }
                    }, save: {
                        try? modelContext.save()
                    })
                }
                .listStyle(.inset)
            }

            if let statusMessage = viewModel.statusMessage {
                Text(statusMessage)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 10)
            }
        }
    }

    private var addAccountPanel: some View {
        HStack(spacing: 12) {
            Picker("Platform", selection: $selectedPlatform) {
                ForEach(SocialPlatform.allCases) { platform in
                    Label(platform.displayName, systemImage: platform.systemImage)
                        .tag(platform)
                }
            }
            .frame(width: 240)

            TextField("Fiók neve", text: $accountName)
                .textFieldStyle(.roundedBorder)
                .frame(width: 260)

            Button {
                Task {
                    await viewModel.addMockAccount(platform: selectedPlatform, accountName: accountName, context: modelContext)
                    accountName = ""
                }
            } label: {
                Label("Demó fiók hozzáadása", systemImage: "plus")
            }

            Button {
                Task {
                    await viewModel.addMissingMockAccounts(context: modelContext)
                }
            } label: {
                Label("Összes demó fiók", systemImage: "wand.and.stars")
            }

            Spacer()
        }
    }
}

private struct AccountRow: View {
    @Bindable var account: SocialAccount
    let validate: () -> Void
    let save: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: account.platform.systemImage)
                .font(.title2)
                .foregroundStyle(.tint)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 5) {
                Text(account.accountName)
                    .font(.headline)
                Text(account.platform.displayName)
                    .foregroundStyle(.secondary)
                Text(account.tokenExpiryDate.map { "Demó token lejárata: \(DateFormatters.day.string(from: $0))" } ?? "Nincs demó token lejárat")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            Toggle("Demó aktív", isOn: $account.isConnected)
                .toggleStyle(.switch)
                .onChange(of: account.isConnected) { _, _ in save() }

            Button {
                validate()
            } label: {
                Label("Ellenőrzés", systemImage: "checkmark.shield")
            }
        }
        .padding(.vertical, 8)
    }
}
