import SwiftUI
import UserNotifications

/// Service managing scheduled local push notifications for morning pledges and evening reflections.
@Observable
@MainActor
final class NotificationManager {
    var isPermissionGranted: Bool = false
    var morningReminderEnabled: Bool {
        didSet {
            UserDefaults.standard.set(morningReminderEnabled, forKey: "morningReminderEnabled")
            updateSchedules()
        }
    }
    var eveningReminderEnabled: Bool {
        didSet {
            UserDefaults.standard.set(eveningReminderEnabled, forKey: "eveningReminderEnabled")
            updateSchedules()
        }
    }
    var morningTime: Date {
        didSet {
            UserDefaults.standard.set(morningTime.timeIntervalSince1970, forKey: "morningReminderTime")
            updateSchedules()
        }
    }
    var eveningTime: Date {
        didSet {
            UserDefaults.standard.set(eveningTime.timeIntervalSince1970, forKey: "eveningReminderTime")
            updateSchedules()
        }
    }

    init() {
        self.morningReminderEnabled = UserDefaults.standard.object(forKey: "morningReminderEnabled") as? Bool ?? false
        self.eveningReminderEnabled = UserDefaults.standard.object(forKey: "eveningReminderEnabled") as? Bool ?? false

        let savedMorning = UserDefaults.standard.double(forKey: "morningReminderTime")
        if savedMorning > 0 {
            self.morningTime = Date(timeIntervalSince1970: savedMorning)
        } else {
            // Default 08:30
            var comps = Calendar.current.dateComponents([.year, .month, .day], from: .now)
            comps.hour = 8
            comps.minute = 30
            self.morningTime = Calendar.current.date(from: comps) ?? .now
        }

        let savedEvening = UserDefaults.standard.double(forKey: "eveningReminderTime")
        if savedEvening > 0 {
            self.eveningTime = Date(timeIntervalSince1970: savedEvening)
        } else {
            // Default 20:30
            var comps = Calendar.current.dateComponents([.year, .month, .day], from: .now)
            comps.hour = 20
            comps.minute = 30
            self.eveningTime = Calendar.current.date(from: comps) ?? .now
        }
    }

    func checkPermission() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        isPermissionGranted = (settings.authorizationStatus == .authorized)
    }

    func requestPermission() async -> Bool {
        do {
            // Request silent visual alerts only (Silent Sanctuary principle: no loud chime triggers)
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge])
            isPermissionGranted = granted
            if granted {
                updateSchedules()
            }
            return granted
        } catch {
            isPermissionGranted = false
            return false
        }
    }

    func updateSchedules() {
        guard isPermissionGranted else { return }

        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["morning_pledge", "evening_journal"])

        if morningReminderEnabled {
            let content = UNMutableNotificationContent()
            content.title = "Daily Pledge"
            content.body = "A new day begins. Renew your commitment: Today I stay free from gambling."
            content.sound = nil // Silent Sanctuary: 100% silent, no stress chime

            let comps = Calendar.current.dateComponents([.hour, .minute], from: morningTime)
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
            let request = UNNotificationRequest(identifier: "morning_pledge", content: content, trigger: trigger)
            center.add(request)
        }

        if eveningReminderEnabled {
            let content = UNMutableNotificationContent()
            content.title = "Evening Reflection"
            content.body = "How was your day? Take a quiet moment to record your thoughts and progress in your journal."
            content.sound = nil // Silent Sanctuary: 100% silent, no stress chime

            let comps = Calendar.current.dateComponents([.hour, .minute], from: eveningTime)
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
            let request = UNNotificationRequest(identifier: "evening_journal", content: content, trigger: trigger)
            center.add(request)
        }
    }
}
