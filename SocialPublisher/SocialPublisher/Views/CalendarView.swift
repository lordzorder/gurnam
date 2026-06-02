import SwiftData
import SwiftUI

struct CalendarView: View {
    @Query(sort: \PostItem.scheduledDate, order: .forward) private var posts: [PostItem]
    @State private var visibleMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: .now)) ?? .now

    private let columns = Array(repeating: GridItem(.flexible(minimum: 110), spacing: 8), count: 7)

    var body: some View {
        VStack(spacing: 16) {
            header

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(Calendar.current.shortWeekdaySymbols, id: \.self) { weekday in
                    Text(weekday)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }

                ForEach(calendarCells, id: \.self) { day in
                    if let day {
                        CalendarDayCell(date: day, posts: postsForDay(day))
                    } else {
                        Color.clear
                            .frame(minHeight: 116)
                    }
                }
            }
        }
        .padding()
    }

    private var header: some View {
        HStack {
            Button {
                visibleMonth = Calendar.current.date(byAdding: .month, value: -1, to: visibleMonth) ?? visibleMonth
            } label: {
                Image(systemName: "chevron.left")
            }
            .help("Previous month")

            Text(monthTitle)
                .font(.title2.bold())

            Button {
                visibleMonth = Calendar.current.date(byAdding: .month, value: 1, to: visibleMonth) ?? visibleMonth
            } label: {
                Image(systemName: "chevron.right")
            }
            .help("Next month")

            Spacer()

            Button("Today") {
                visibleMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: .now)) ?? .now
            }
        }
    }

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: visibleMonth)
    }

    private var calendarCells: [Date?] {
        guard
            let monthInterval = Calendar.current.dateInterval(of: .month, for: visibleMonth),
            let dayRange = Calendar.current.range(of: .day, in: .month, for: visibleMonth)
        else { return [] }

        let firstWeekday = Calendar.current.component(.weekday, from: monthInterval.start)
        let leadingEmptyDays = max(0, firstWeekday - Calendar.current.firstWeekday)
        let days = dayRange.compactMap { day -> Date? in
            var components = Calendar.current.dateComponents([.year, .month], from: visibleMonth)
            components.day = day
            return Calendar.current.date(from: components)
        }

        return Array(repeating: nil, count: leadingEmptyDays) + days
    }

    private func postsForDay(_ date: Date) -> [PostItem] {
        posts.filter { Calendar.current.isDate($0.scheduledDate, inSameDayAs: date) }
    }
}

private struct CalendarDayCell: View {
    let date: Date
    let posts: [PostItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.headline)
                Spacer()
                if Calendar.current.isDateInToday(date) {
                    Circle()
                        .fill(.tint)
                        .frame(width: 8, height: 8)
                }
            }

            ForEach(posts.prefix(3)) { post in
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.title)
                        .font(.caption.weight(.semibold))
                        .lineLimit(1)
                    Text(DateFormatters.time.string(from: post.scheduledDate))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding(6)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(post.status.tint.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            }

            if posts.count > 3 {
                Text("+ \(posts.count - 3) more")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
        .padding(10)
        .frame(minHeight: 116, alignment: .topLeading)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
