import Foundation

enum DashboardSection: String, CaseIterable, Identifiable, Hashable {
    case drafts
    case scheduled
    case published
    case failed
    case calendar
    case mediaLibrary
    case accounts
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .drafts: "Piszkozatok"
        case .scheduled: "Ütemezve"
        case .published: "Publikálva"
        case .failed: "Sikertelen"
        case .calendar: "Naptár"
        case .mediaLibrary: "Médiatár"
        case .accounts: "Fiókok"
        case .settings: "Beállítások"
        }
    }

    var systemImage: String {
        switch self {
        case .drafts: "doc.text"
        case .scheduled: "clock"
        case .published: "checkmark.seal"
        case .failed: "exclamationmark.triangle"
        case .calendar: "calendar"
        case .mediaLibrary: "photo.on.rectangle"
        case .accounts: "person.crop.circle.badge.checkmark"
        case .settings: "gearshape"
        }
    }

    var postStatus: PostStatus? {
        switch self {
        case .drafts: .draft
        case .scheduled: .scheduled
        case .published: .published
        case .failed: .failed
        case .calendar, .mediaLibrary, .accounts, .settings: nil
        }
    }
}
