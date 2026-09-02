import SwiftUI

struct CravingLoggerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var intensity: Double = 5
    @State private var selectedTrigger: Design.Trigger = .other
    @State private var selectedMood: Int = 3
    @State private var notes: String = ""
    @State private var wasRelapse: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Intensität (1-10)")) {
                    Slider(value: $intensity, in: 1...10, step: 1)
                    Text("Aktuell: \(Int(intensity))")
                        .foregroundStyle(Design.Colors.secondary)
                }
                
                Section(header: Text("Auslöser")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(Design.Trigger.allCases) { trigger in
                                Button(action: { selectedTrigger = trigger }) {
                                    HStack {
                                        Image(systemName: trigger.icon)
                                        Text(trigger.label)
                                    }
                                    .padding(.horizontal, Design.Spacing.md)
                                    .padding(.vertical, Design.Spacing.sm)
                                    .background(selectedTrigger == trigger ? Design.Colors.accent : Design.Colors.surfaceHover)
                                    .foregroundStyle(selectedTrigger == trigger ? .white : Design.Colors.primary)
                                    .cornerRadius(Design.Radius.xl)
                                }
                                .frame(minHeight: 44)
                            }
                        }
                    }
                }
                
                Section(header: Text("Stimmung")) {
                    MoodPickerView(selectedMood: $selectedMood)
                }
                
                Section(header: Text("Notizen")) {
                    TextField("Was ging dir durch den Kopf?", text: $notes, axis: .vertical)
                        .lineLimit(3...)
                        .frame(minHeight: 44)
                }
                
                Section {
                    Toggle(isOn: $wasRelapse) {
                        VStack(alignment: .leading) {
                            Text("Rückfall?")
                                .foregroundStyle(Design.Colors.primary)
                            Text("Es ist okay. Ein Rückschlag löscht deine bisherigen Erfolge nicht aus.")
                                .font(.caption)
                                .foregroundStyle(Design.Colors.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Craving erfassen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        save()
                    }
                }
            }
        }
    }
    
    private func save() {
        let log = CravingLog(
            intensity: Int(intensity),
            trigger: selectedTrigger.rawValue,
            mood: selectedMood,
            notes: notes,
            wasRelapse: wasRelapse
        )
        modelContext.insert(log)
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    CravingLoggerView()
}
