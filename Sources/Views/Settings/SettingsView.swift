import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(PrivacyManager.self) private var privacyManager
    @Environment(NotificationManager.self) private var notificationManager

    @Query private var profiles: [UserProfile]

    @State private var startDate = Date.now
    @State private var dailySpend: Double = 0
    @State private var showingResetConfirm = false
    @State private var isLoaded = false

    @Bindable private var bindablePrivacy: PrivacyManager
    @Bindable private var bindableNotifications: NotificationManager

    init() {
        // Fallback for previews/initialization
        self._bindablePrivacy = Bindable(wrappedValue: PrivacyManager())
        self._bindableNotifications = Bindable(wrappedValue: NotificationManager())
    }

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        @Bindable var privacy = privacyManager
        @Bindable var notifications = notificationManager

        Form {
            Section("Profil") {
                DatePicker("Spielfrei seit", selection: $startDate, in: ...Date.now, displayedComponents: .date)
                    .tint(Design.Colors.primary)
                    .onChange(of: startDate) { _, newValue in
                        profile?.sobrietyStartDate = newValue
                        try? modelContext.save()
                    }

                LabeledContent("Täglicher Einsatz") {
                    TextField("Betrag", value: $dailySpend, format: .currency(code: "EUR"))
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                        .onChange(of: dailySpend) { _, newValue in
                            profile?.dailyGamblingSpend = newValue
                            try? modelContext.save()
                        }
                }
            }

            Section("Sicherheit & Privatsphäre") {
                Toggle("Mit FaceID / Passcode schützen", isOn: $privacy.isBiometricsEnabled)
                    .tint(Design.Colors.primary)

                Button {
                    privacyManager.toggleCamouflage()
                } label: {
                    Label("Tarn-Modus jetzt testen", systemImage: "eye.slash.fill")
                        .foregroundStyle(Design.Colors.secondary)
                }
            }

            Section("Tägliche Erinnerungen") {
                Toggle("Morgendliches Versprechen", isOn: $notifications.morningReminderEnabled)
                    .tint(Design.Colors.primary)
                    .onChange(of: notifications.morningReminderEnabled) { _, enabled in
                        if enabled {
                            Task {
                                _ = await notificationManager.requestPermission()
                            }
                        }
                    }

                if notifications.morningReminderEnabled {
                    DatePicker("Morgen-Uhrzeit", selection: $notifications.morningTime, displayedComponents: .hourAndMinute)
                        .tint(Design.Colors.primary)
                }

                Toggle("Abendliche Reflexion", isOn: $notifications.eveningReminderEnabled)
                    .tint(Design.Colors.primary)
                    .onChange(of: notifications.eveningReminderEnabled) { _, enabled in
                        if enabled {
                            Task {
                                _ = await notificationManager.requestPermission()
                            }
                        }
                    }

                if notifications.eveningReminderEnabled {
                    DatePicker("Abend-Uhrzeit", selection: $notifications.eveningTime, displayedComponents: .hourAndMinute)
                        .tint(Design.Colors.primary)
                }
            }

            Section("Vertrauensperson") {
                NavigationLink(destination: EmergencyBuddyView()) {
                    Label("Notfall-Buddy verwalten", systemImage: "person.2.fill")
                }
            }

            Section("Daten") {
                Button {
                    // Export logic placeholder
                } label: {
                    Label("Daten exportieren (JSON)", systemImage: "square.and.arrow.up")
                }

                Button(role: .destructive) {
                    showingResetConfirm = true
                } label: {
                    Label("Alle Daten löschen", systemImage: "trash")
                }
            }

            Section("Über") {
                LabeledContent("Version", value: "1.2.0")

                NavigationLink {
                    ScrollView {
                        VStack(alignment: .leading, spacing: Design.Spacing.md) {
                            Text("Datenschutzerklärung")
                                .font(.title2)
                                .bold()
                            Text("FreiSpiel speichert alle Daten (Tagebucheinträge, Verlangensprotokolle, Notfallkontakte, Testergebnisse) ausschließlich verschlüsselt und lokal auf deinem Gerät.\n\nEs werden keine Daten an Server übertragen oder getrackt.")
                                .foregroundStyle(.secondary)
                                .lineSpacing(3)
                        }
                        .padding()
                    }
                    .navigationTitle("Datenschutz")
                } label: {
                    Text("Datenschutz")
                }
            }
        }
        .navigationTitle("Einstellungen")
        .confirmationDialog(
            "Alle Daten löschen?",
            isPresented: $showingResetConfirm,
            titleVisibility: .visible
        ) {
            Button("Löschen", role: .destructive) {
                deleteAllData()
            }
            Button("Abbrechen", role: .cancel) {}
        } message: {
            Text("Dies kann nicht rückgängig gemacht werden. Alle Einträge, Meilensteine, Testergebnisse und Einstellungen werden unwiderruflich gelöscht.")
        }
        .task {
            guard !isLoaded else { return }
            if let p = profile {
                startDate = p.sobrietyStartDate
                dailySpend = p.dailyGamblingSpend
            }
            isLoaded = true
        }
    }

    private func deleteAllData() {
        try? modelContext.delete(model: JournalEntry.self)
        try? modelContext.delete(model: CravingLog.self)
        try? modelContext.delete(model: MilestoneAchievement.self)
        try? modelContext.delete(model: SavingsGoal.self)
        try? modelContext.delete(model: ReasonToQuit.self)
        try? modelContext.delete(model: EmergencyContact.self)
        try? modelContext.delete(model: SelfAssessmentResult.self)
        try? modelContext.delete(model: UserProfile.self)
        try? modelContext.save()
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .environment(PrivacyManager())
    .environment(NotificationManager())
    .modelContainer(for: UserProfile.self, inMemory: true)
}
