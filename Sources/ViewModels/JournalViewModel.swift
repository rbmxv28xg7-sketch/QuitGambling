import Foundation
import SwiftData
import SwiftUI

@Observable
@MainActor
final class JournalViewModel {
    var searchText: String = ""

    func filteredEntries(_ entries: [JournalEntry]) -> [JournalEntry] {
        if searchText.isEmpty {
            return entries
        } else {
            return entries.filter { $0.text.localizedStandardContains(searchText) }
        }
    }

    func createEntry(context: ModelContext, text: String, mood: Int, gratitude: String, hadCravings: Bool) {
        let entry = JournalEntry(
            date: .now,
            text: text,
            mood: mood,
            gratitude: gratitude,
            hadCravings: hadCravings
        )
        context.insert(entry)
        try? context.save()
    }

    func deleteEntry(context: ModelContext, entry: JournalEntry) {
        context.delete(entry)
        try? context.save()
    }
}
