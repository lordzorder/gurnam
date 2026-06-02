import Foundation
import SwiftData

@MainActor
final class AccountsViewModel: ObservableObject {
    @Published var statusMessage: String?

    func addMockAccount(platform: SocialPlatform, accountName: String, context: ModelContext) async {
        let connector = ConnectorFactory.connector(for: platform)

        do {
            let auth = try await connector.authenticate()
            let account = SocialAccount(
                platform: platform,
                accountName: accountName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "\(platform.displayName) Mock Account" : accountName,
                accessToken: auth.accessToken,
                refreshToken: auth.refreshToken,
                tokenExpiryDate: auth.expiryDate,
                isConnected: true
            )
            context.insert(account)
            try context.save()
            statusMessage = "\(platform.displayName): demó fiók hozzáadva. Valódi bejelentkezés még nincs bekötve."
        } catch {
            statusMessage = error.localizedDescription
        }
    }

    func addMissingMockAccounts(context: ModelContext) async {
        let existing = (try? context.fetch(FetchDescriptor<SocialAccount>())) ?? []

        for platform in SocialPlatform.allCases where existing.contains(where: { $0.platform == platform }) == false {
            await addMockAccount(platform: platform, accountName: "\(platform.displayName) demó fiók", context: context)
        }
    }

    func validate(account: SocialAccount) async {
        let connector = ConnectorFactory.connector(for: account.platform)
        let isValid = await connector.validateConnection(account: account)
        statusMessage = isValid ? "\(account.accountName): demó kapcsolat rendben." : "\(account.accountName): nincs aktív demó kapcsolat."
    }
}
