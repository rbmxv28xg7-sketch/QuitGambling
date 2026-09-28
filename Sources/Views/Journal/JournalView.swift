import SwiftUI
import SwiftData

struct JournalView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \JournalEntry.date, order: .reverse) private var entries: [JournalEntry]
    
    @State private var viewModel = JournalViewModel()
    @State private var showingNewEntry = false
    
    var body: some View {
        ZStack {
            FlutedGlassBackgroundView()

            ScrollView(showsIndicators: false) {
                let filtered = viewModel.filteredEntries(entries)

                VStack(spacing: Design.Spacing.md) {
                    if filtered.isEmpty {
                        EmptyStateView(
                            icon: "book.pages",
                            title: "No Entries",
                            subtitle: "Start your journal by recording your daily thoughts."
                        )
                        .padding(.top, 40)
                    } else {
                        ForEach(filtered) { entry in
                            NavigationLink(destination: JournalEntryView(entry: entry)) {
                                VStack(alignment: .leading, spacing: Design.Spacing.sm) {
                                    HStack {
                                        Text(entry.date, format: .dateTime.day().month().year())
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(Design.Colors.textSecondary)
                                        Spacer()
                                        if let mood = Design.Mood(rawValue: entry.mood) {
                                            ZStack {
                                                Circle()
                                                    .fill(mood.color.opacity(0.18))
                                                    .frame(width: 28, height: 28)
                                                Image(systemName: mood.iconName)
                                                    .font(.system(size: 13, weight: .bold))
                                                    .foregroundStyle(mood.color)
                                            }
                                        }
                                    }
                                    
                                    Text(entry.text)
                                        .lineLimit(2)
                                        .font(.body)
                                        .foregroundStyle(Design.Colors.textPrimary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .liquidGlass(cornerRadius: Design.Radius.card, padding: Design.Spacing.md)
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button(role: .destructive) {
                                    SensoryFeedbackService.shared.selectionClick()
                                    modelContext.delete(entry)
                                    try? modelContext.save()
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, Design.Spacing.md)
                .padding(.bottom, 96)
            }
            .navigationTitle("Journal")
            .searchable(text: $viewModel.searchText, prompt: "Search...")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        SensoryFeedbackService.shared.buttonTap()
                        showingNewEntry = true
                    }) {
                        Image(systemName: "square.and.pencil")
                            .foregroundStyle(Design.Colors.gold)
                    }
                    .frame(minWidth: 44, minHeight: 44)
                }
            }
            .sheet(isPresented: $showingNewEntry) {
                NewEntryView(viewModel: viewModel)
                    .scrollIndicators(.hidden)
            }
            .scrollIndicators(.hidden)
        }
        .scrollIndicators(.hidden)
    }
}

#Preview {
    JournalView()
        .modelContainer(for: JournalEntry.self, inMemory: true)
}
