import SwiftUI
import SwiftData

struct SobrietyCalendarView: View {
    @Bindable var viewModel: TrackerViewModel
    var logs: [CravingLog]
    
    @Query private var profiles: [UserProfile]
    @State private var selectedDate: Date?

    private let daysOfWeek = ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"]
    
    var body: some View {
        VStack(spacing: Design.Spacing.md) {
            // Header
            HStack {
                Button(action: { viewModel.previousMonth() }) {
                    Image(systemName: "chevron.left")
                        .frame(minWidth: 44, minHeight: 44)
                }
                Spacer()
                Text(viewModel.selectedMonth, format: .dateTime.month(.wide).year())
                    .font(.headline)
                    .foregroundStyle(Design.Colors.primary)
                Spacer()
                Button(action: { viewModel.nextMonth() }) {
                    Image(systemName: "chevron.right")
                        .frame(minWidth: 44, minHeight: 44)
                }
            }
            .foregroundStyle(Design.Colors.accent)
            .padding(.horizontal)
            
            // Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: Design.Spacing.sm) {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .foregroundStyle(Design.Colors.secondary)
                }
                
                let days = getDaysInMonth()
                ForEach(days, id: \.self) { date in
                    let status = viewModel.dayStatus(
                        for: date,
                        logs: logs,
                        startDate: profiles.first?.sobrietyStartDate ?? .now
                    )
                    
                    Text(date, format: .dateTime.day())
                        .font(.body)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 44)
                        .background(status.color)
                        .cornerRadius(Design.Radius.sm)
                        .onTapGesture {
                            selectedDate = date
                        }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(Design.Colors.surface)
        .cornerRadius(Design.Radius.lg)
        .padding(.horizontal)
        .sheet(item: $selectedDate) { date in
            // Detail sheet could go here
            Text("Detail for \(date.formatted(date: .abbreviated, time: .omitted))")
                .presentationDetents([.medium])
        }
    }
    
    private func getDaysInMonth() -> [Date] {
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: viewModel.selectedMonth),
              let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: viewModel.selectedMonth)) else {
            return []
        }
        
        return range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)
        }
    }
}

extension Date: Identifiable {
    public var id: TimeInterval { self.timeIntervalSince1970 }
}
