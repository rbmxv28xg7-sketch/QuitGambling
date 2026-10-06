import UIKit
import CoreMotion

/// High-precision, rock-solid shake detection service combining CoreMotion accelerometer tracking
/// with crash-safe UIResponder motion handling.
@MainActor
final class ShakeMotionService {
    static let shared = ShakeMotionService()

    private let motionManager = CMMotionManager()
    private var isMonitoring = false
    private var lastShakeTimestamp: TimeInterval = 0
    private var lastAcceleration: (x: Double, y: Double, z: Double) = (0, 0, 0)
    private var shakeCounter: Int = 0

    private init() {}

    // MARK: - CoreMotion Accelerometer Monitoring

    func startMonitoring() {
        guard !isMonitoring, motionManager.isAccelerometerAvailable else { return }
        isMonitoring = true

        motionManager.accelerometerUpdateInterval = 0.05 // 20 Hz
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, _ in
            guard let self = self, let data = data else { return }
            self.handleAccelerometerData(data.acceleration)
        }
    }

    func stopMonitoring() {
        guard isMonitoring else { return }
        isMonitoring = false
        motionManager.stopAccelerometerUpdates()
        shakeCounter = 0
    }

    private func handleAccelerometerData(_ acc: CMAcceleration) {
        let x = acc.x
        let y = acc.y
        let z = acc.z

        let magnitude = sqrt(x * x + y * y + z * z)
        let deltaX = abs(x - lastAcceleration.x)
        let deltaY = abs(y - lastAcceleration.y)
        let deltaZ = abs(z - lastAcceleration.z)
        let totalDelta = deltaX + deltaY + deltaZ

        lastAcceleration = (x, y, z)

        // Detect high-energy acceleration reversal (intentional shake)
        if magnitude > 2.2 || totalDelta > 2.8 {
            shakeCounter += 1
            if shakeCounter >= 2 {
                triggerShake()
                shakeCounter = 0
            }
        } else {
            // Decay counter if movement is smooth
            if shakeCounter > 0 {
                shakeCounter -= 1
            }
        }
    }

    // MARK: - Shake Trigger (Debounced)

    func triggerShake() {
        let now = ProcessInfo.processInfo.systemUptime
        // 1.2 second debounce to prevent rapid re-triggering while shaking
        guard now - lastShakeTimestamp > 1.2 else { return }
        lastShakeTimestamp = now

        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .deviceDidShakeNotification, object: nil)
        }
    }
}
