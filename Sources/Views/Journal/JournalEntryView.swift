import SwiftUI

struct JournalEntryView: View {
    let entry: JournalEntry
    
    var body: some View {
        ZStack {
            FlutedGlassBackgroundView()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: Design.Spacing.lg) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Journal Entry")
                                .font(.caption)
                                .foregroundStyle(Design.Colors.secondary)
                            Text(entry.date, format: .dateTime.day().month(.wide).year())
                                .font(.title2)
                                .bold()
                                .foregroundStyle(Design.Colors.ivory)
                        }
                        Spacer()
                        if let mood = Design.Mood(rawValue: entry.mood) {
                            ZStack {
                                Circle()
                                    .fill(mood.color.opacity(0.18))
                                    .frame(width: 44, height: 44)
                                Image(systemName: mood.iconName)
                                    .font(.title3.weight(.bold))
                                    .foregroundStyle(mood.color)
                            }
                        }
                    }
                    .sereneCardStyle(padding: Design.Spacing.md)
                    
                    // Content
                    if !entry.text.isEmpty {
                        VStack(alignment: .leading, spacing: Design.Spacing.sm) {
                            Label("Thoughts", systemImage: "text.bubble.fill")
                                .font(.headline)
                                .foregroundStyle(Design.Colors.gold)
                            Text(entry.text)
                                .font(.body)
                                .foregroundStyle(Design.Colors.ivory)
                                .lineSpacing(4)
                        }
                        .sereneCardStyle(padding: Design.Spacing.md)
                    }
                    
                    // Gratitude
                    if !entry.gratitude.isEmpty {
                        VStack(alignment: .leading, spacing: Design.Spacing.sm) {
                            Label("Grateful For", systemImage: "heart.fill")
                                .font(.headline)
                                .foregroundStyle(Design.Colors.primary)
                            Text(entry.gratitude)
                                .font(.body)
                                .foregroundStyle(Design.Colors.ivory)
                                .lineSpacing(4)
                        }
                        .sereneCardStyle(padding: Design.Spacing.md)
                    }
                    
                    // Craving Indicator
                    if entry.hadCravings {
                        HStack(spacing: Design.Spacing.sm) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(Design.Colors.gold)
                            Text("Felt gambling urge on this day")
                                .font(.subheadline)
                                .foregroundStyle(Design.Colors.ivory)
                        }
                        .sereneCardStyle(padding: Design.Spacing.md)
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            SensoryFeedbackService.shared.selectionClick()
        }
    }
}

#Preview {
    JournalEntryView(entry: JournalEntry(text: "Today was a positive and calm day.", mood: 4, gratitude: "Great weather, inspiring conversations.", hadCravings: true))
}
