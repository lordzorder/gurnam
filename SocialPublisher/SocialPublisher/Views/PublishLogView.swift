import SwiftUI

struct PublishLogView: View {
    let post: PostItem

    private var logs: [PublishLog] {
        post.publishLogs.sorted { $0.attemptDate > $1.attemptDate }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Publish Log")
                .font(.headline)

            if logs.isEmpty {
                Text("No publish attempts yet.")
                    .foregroundStyle(.secondary)
            } else {
                VStack(spacing: 8) {
                    ForEach(logs) { log in
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: log.success ? "checkmark.circle.fill" : "xmark.octagon.fill")
                                .foregroundStyle(log.success ? .green : .red)
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(log.platform.displayName)
                                        .font(.callout.weight(.semibold))
                                    Spacer()
                                    Text(DateFormatters.dateTime.string(from: log.attemptDate))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Text(log.message)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                if let externalPostId = log.externalPostId {
                                    Text("External ID placeholder: \(externalPostId)")
                                        .font(.caption2)
                                        .foregroundStyle(.tertiary)
                                }
                            }
                        }
                        .padding(10)
                        .background(.quaternary.opacity(0.35))
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                }
            }
        }
    }
}
