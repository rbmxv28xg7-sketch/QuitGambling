import Foundation

/// Service tracking app launch/open frequency and triggering the Pro paywall every 10th session for non-paying users.
enum PeriodicPaywallService {
    private static let counterKey = "app_open_count_periodic_paywall"
    private static let lastOpenTimestampKey = "app_last_open_timestamp"

    /// Current recorded number of app opens.
    static var openCount: Int {
        UserDefaults.standard.integer(forKey: counterKey)
    }

    /// Records an app open session.
    /// Returns true if this open represents the 10th, 20th, 30th... launch and Pro is not active.
    static func recordAppOpenAndCheckTrigger(isPro: Bool) -> Bool {
        guard !isPro else { return false }

        let now = Date().timeIntervalSince1970
        let lastOpen = UserDefaults.standard.double(forKey: lastOpenTimestampKey)

        // Ignore rapid reconnections/re-activations within 20 seconds (e.g., FaceID unlock or quick multitasking glance)
        if lastOpen > 0 && (now - lastOpen) < 20 {
            return false
        }

        UserDefaults.standard.set(now, forKey: lastOpenTimestampKey)

        let newCount = UserDefaults.standard.integer(forKey: counterKey) + 1
        UserDefaults.standard.set(newCount, forKey: counterKey)

        #if DEBUG
        print("📊 [PeriodicPaywall] Session #\(newCount) recorded. Target trigger (% 10 == 0): \(newCount % 10 == 0)")
        #endif

        return newCount % 10 == 0
    }

    /// Reset counter (e.g., for testing or complete data resets)
    static func resetCounter() {
        UserDefaults.standard.set(0, forKey: counterKey)
        UserDefaults.standard.removeObject(forKey: lastOpenTimestampKey)
    }

    #if DEBUG
    /// Helper to set count specifically for testing
    static func setDebugCount(_ count: Int) {
        UserDefaults.standard.set(count, forKey: counterKey)
        UserDefaults.standard.removeObject(forKey: lastOpenTimestampKey)
    }
    #endif
}
