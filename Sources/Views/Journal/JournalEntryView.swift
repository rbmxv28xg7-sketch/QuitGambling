import SwiftUI

struct JournalEntryView: View {
    let entry: JournalEntry
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Design.Spacing.lg) {
                // Header
                HStack {
                    Text(entry.date, format: .dateTime.day().month(.wide).year())
                        .font(.title2)
                        .bold()
                        .foregroundStyle(Design.Colors.primary)
                    Spacer()
                    if let mood = Design.Mood(rawValue: entry.mood) {
                        Text(mood.emoji)
                            .font(.system(size: 48))
                    }
                }
                
                // Content
                if !entry.text.isEmpty {
                    VStack(alignment: .leading, spacing: Design.Spacing.sm) {
                        Text("Gedanken")
                            .font(.headline)
                            .foregroundStyle(Design.Colors.secondary)
                        Text(entry.text)
                            .font(.body)
                    }
                }
                
                // Gratitude
                if !entry.gratitude.isEmpty {
                    VStack(alignment: .leading, spacing: Design.Spacing.sm) {
                        Text("Dankbar für")
                            .font(.headline)
                            .foregroundStyle(Design.Colors.secondary)
                        Text(entry.gratitude)
                            .font(.body)
                    }
                    .padding()
                    .background(Design.Colors.surfaceHover)
                    .cornerRadius(Design.Radius.md)
                }
                
                // Craving Indicator
                if entry.hadCravings {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(Design.Colors.sos)
                        Text("Spieldruck an diesem Tag")
                            .foregroundStyle(Design.Colors.primary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Design.Colors.calendarCraving.opacity(0.2))
                    .cornerRadius(Design.Radius.md)
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    JournalEntryView(entry: JournalEntry(text: "Heute war ein guter Tag.", mood: 4, gratitude: "Gutes Wetter, nette Gespräche.", hadCravings: true))
}
