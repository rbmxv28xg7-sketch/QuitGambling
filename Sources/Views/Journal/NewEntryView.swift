import SwiftUI

struct NewEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var viewModel: JournalViewModel
    
    @State private var text: String = ""
    @State private var selectedMood: Int = 3
    @State private var gratitude: String = ""
    @State private var hadCravings: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Stimmung")) {
                    MoodPickerView(selectedMood: $selectedMood)
                }
                
                Section(header: Text("Tagebuch")) {
                    TextField("Was beschäftigt dich?", text: $text, axis: .vertical)
                        .lineLimit(5...)
                        .frame(minHeight: 44)
                }
                
                Section(header: Text("Dankbarkeit")) {
                    TextField("Wofür bist du heute dankbar?", text: $gratitude, axis: .vertical)
                        .frame(minHeight: 44)
                }
                
                Section {
                    Toggle("Hattest du heute Spieldruck?", isOn: $hadCravings)
                        .frame(minHeight: 44)
                }
            }
            .navigationTitle("Neuer Eintrag")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        viewModel.createEntry(
                            context: modelContext,
                            text: text,
                            mood: selectedMood,
                            gratitude: gratitude,
                            hadCravings: hadCravings
                        )
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NewEntryView(viewModel: JournalViewModel())
}
