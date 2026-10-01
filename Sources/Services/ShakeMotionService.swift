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

    private init() {
        // Safe UIResponder swizzle for hardware / simulator motion events
        _ = UIResponder.swizzleMotionEndedOnce
    }

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

// MARK: - Safe UIResponder Swizzling (Zero Unrecognized Selector Exceptions)

extension UIResponder {
    static let swizzleMotionEndedOnce: Void = {
        guard let originalMethod = class_getInstanceMethod(UIResponder.self, #selector(motionEnded(_:with:))),
              let swizzledMethod = class_getInstanceMethod(UIResponder.self, #selector(qg_motionEnded(_:with:))) else { return }
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }()

    @objc func qg_motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        // Forward to original implementation safely on UIResponder
        qg_motionEnded(motion, with: event)

        if motion == .motionShake {
            Task { @MainActor in
                ShakeMotionService.shared.triggerShake()
            }
        }
    }
}
