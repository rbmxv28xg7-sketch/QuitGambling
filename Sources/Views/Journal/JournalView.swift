import SwiftUI
import SwiftData

struct JournalView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \JournalEntry.date, order: .reverse) private var entries: [JournalEntry]
    
    @State private var viewModel = JournalViewModel()
    @State private var showingNewEntry = false
    
    var body: some View {
        NavigationStack {
            List {
                let filtered = viewModel.filteredEntries(entries)
                
                if filtered.isEmpty {
                    ContentUnavailableView(
                        "Keine Einträge",
                        systemImage: "book.pages",
                        description: Text("Beginne dein Tagebuch, indem du deine Gedanken festhältst.")
                    )
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(filtered) { entry in
                        NavigationLink(destination: JournalEntryView(entry: entry)) {
                            VStack(alignment: .leading, spacing: Design.Spacing.sm) {
                                HStack {
                                    Text(entry.date, format: .dateTime.day().month().year())
                                        .font(.subheadline)
                                        .foregroundStyle(Design.Colors.secondary)
                                    Spacer()
                                    if let mood = Design.Mood(rawValue: entry.mood) {
                                        Text(mood.emoji)
                                    }
                                }
                                
                                Text(entry.text)
                                    .lineLimit(2)
                                    .font(.body)
                                    .foregroundStyle(Design.Colors.primary)
                            }
                            .padding(.vertical, Design.Spacing.xs)
                        }
                    }
                    .onDelete(perform: deleteEntries)
                }
            }
            .navigationTitle("Tagebuch")
            .searchable(text: $viewModel.searchText, prompt: "Suchen...")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingNewEntry = true }) {
                        Image(systemName: "square.and.pencil")
                            .foregroundStyle(Design.Colors.accent)
                    }
                    .frame(minWidth: 44, minHeight: 44)
                }
            }
            .sheet(isPresented: $showingNewEntry) {
                NewEntryView(viewModel: viewModel)
            }
        }
    }
    
    private func deleteEntries(offsets: IndexSet) {
        let filtered = viewModel.filteredEntries(entries)
        for index in offsets {
            viewModel.deleteEntry(context: modelContext, entry: filtered[index])
        }
    }
}

#Preview {
    JournalView()
        .modelContainer(for: JournalEntry.self, inMemory: true)
}
