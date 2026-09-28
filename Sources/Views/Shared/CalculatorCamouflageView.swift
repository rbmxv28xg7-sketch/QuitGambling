import SwiftUI
import AudioToolbox

/// A hyper-realistic, fully functional iOS Calculator disguise screen.
/// Entering the secret PIN followed by '=' seamlessly unlocks the Quit Gambling app.
struct CalculatorCamouflageView: View {
    var onExit: () -> Void
    var targetPIN: String = "1234"
    var onBiometricRecovery: (() async -> Bool)?

    @State private var displayText: String = "0"
    @State private var previousValue: Double? = nil
    @State private var activeOperator: Operator? = nil
    @State private var isTypingNewNumber: Bool = true
    @State private var hasError: Bool = false

    enum Operator: String {
        case add = "+"
        case subtract = "−"
        case multiply = "×"
        case divide = "÷"
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 12) {
                Spacer(minLength: 20)

                // Calculator Display
                VStack(alignment: .trailing, spacing: 4) {
                    // Discreet recovery trigger on long press
                    Text(displayText)
                        .font(.system(size: displayText.count > 7 ? 60 : 84, weight: .light, design: .default))
                        .foregroundStyle(Color.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.35)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.horizontal, 28)
                        .contentShape(Rectangle())
                        .onLongPressGesture(minimumDuration: 1.5) {
                            attemptBiometricRecovery()
                        }
                }

                // Calculator Keypad
                VStack(spacing: 12) {
                    // Row 1: AC, +/-, %, ÷
                    HStack(spacing: 12) {
                        calcButton(
                            title: displayText == "0" && activeOperator == nil ? "AC" : "C",
                            type: .utility,
                            longPressAction: { attemptBiometricRecovery() }
                        ) {
                            clearCalculator()
                        }

                        calcButton(title: "⁺/₋", type: .utility) {
                            toggleSign()
                        }

                        calcButton(title: "%", type: .utility) {
                            applyPercent()
                        }

                        calcButton(
                            title: "÷",
                            type: .operation(activeOperator == .divide)
                        ) {
                            selectOperator(.divide)
                        }
                    }

                    // Row 2: 7, 8, 9, ×
                    HStack(spacing: 12) {
                        calcButton(title: "7", type: .digit) { appendDigit("7") }
                        calcButton(title: "8", type: .digit) { appendDigit("8") }
                        calcButton(title: "9", type: .digit) { appendDigit("9") }
                        calcButton(
                            title: "×",
                            type: .operation(activeOperator == .multiply)
                        ) {
                            selectOperator(.multiply)
                        }
                    }

                    // Row 3: 4, 5, 6, −
                    HStack(spacing: 12) {
                        calcButton(title: "4", type: .digit) { appendDigit("4") }
                        calcButton(title: "5", type: .digit) { appendDigit("5") }
                        calcButton(title: "6", type: .digit) { appendDigit("6") }
                        calcButton(
                            title: "−",
                            type: .operation(activeOperator == .subtract)
                        ) {
                            selectOperator(.subtract)
                        }
                    }

                    // Row 4: 1, 2, 3, +
                    HStack(spacing: 12) {
                        calcButton(title: "1", type: .digit) { appendDigit("1") }
                        calcButton(title: "2", type: .digit) { appendDigit("2") }
                        calcButton(title: "3", type: .digit) { appendDigit("3") }
                        calcButton(
                            title: "+",
                            type: .operation(activeOperator == .add)
                        ) {
                            selectOperator(.add)
                        }
                    }

                    // Row 5: 0 (wide), ., =
                    HStack(spacing: 12) {
                        // 0 Button spans two slots
                        Button {
                            playKeyClick()
                            appendDigit("0")
                        } label: {
                            HStack {
                                Text("0")
                                    .font(.system(size: 34, weight: .regular))
                                    .foregroundStyle(Color.white)
                                    .padding(.leading, 32)
                                Spacer()
                            }
                            .frame(height: 76)
                            .background(Color(white: 0.20))
                            .clipShape(Capsule())
                        }
                        .buttonStyle(CalcButtonStyle())

                        calcButton(title: ".", type: .digit) { appendDecimal() }
                        calcButton(title: "=", type: .operation(false), isAccent: true) { evaluateOrUnlock() }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
    }

    // MARK: - Keypad Button Helper

    enum ButtonType {
        case digit
        case utility
        case operation(Bool)
    }

    private func calcButton(
        title: String,
        type: ButtonType,
        isAccent: Bool = false,
        longPressAction: (() -> Void)? = nil,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            playKeyClick()
            action()
        } label: {
            ZStack {
                Circle()
                    .fill(buttonBackgroundColor(for: type, isAccent: isAccent))
                    .frame(height: 76)

                Text(title)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(buttonTextColor(for: type))
            }
        }
        .buttonStyle(CalcButtonStyle())
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 1.5).onEnded { _ in
                longPressAction?()
            }
        )
    }

    private func buttonBackgroundColor(for type: ButtonType, isAccent: Bool) -> Color {
        switch type {
        case .digit:
            return Color(white: 0.20)
        case .utility:
            return Color(white: 0.65)
        case .operation(let isActive):
            if isActive {
                return Color.white
            }
            return Color(red: 1.0, green: 0.58, blue: 0.0) // Apple orange
        }
    }

    private func buttonTextColor(for type: ButtonType) -> Color {
        switch type {
        case .digit:
            return Color.white
        case .utility:
            return Color.black
        case .operation(let isActive):
            return isActive ? Color(red: 1.0, green: 0.58, blue: 0.0) : Color.white
        }
    }

    // MARK: - Math Logic & Secret PIN

    private func appendDigit(_ digit: String) {
        if hasError || isTypingNewNumber || displayText == "0" {
            displayText = digit
            isTypingNewNumber = false
            hasError = false
        } else {
            if displayText.count < 10 {
                displayText += digit
            }
        }
    }

    private func appendDecimal() {
        if hasError || isTypingNewNumber {
            displayText = "0."
            isTypingNewNumber = false
            hasError = false
        } else if !displayText.contains(".") {
            displayText += "."
        }
    }

    private func selectOperator(_ op: Operator) {
        if let prev = previousValue, let activeOp = activeOperator, !isTypingNewNumber {
            let current = Double(displayText) ?? 0
            let res = calculate(prev, op: activeOp, current)
            displayText = formatResult(res)
            previousValue = res
        } else {
            previousValue = Double(displayText)
        }
        activeOperator = op
        isTypingNewNumber = true
    }

    private func evaluateOrUnlock() {
        let currentClean = displayText.trimmingCharacters(in: .whitespacesAndNewlines)

        // Check if entered number matches the secret unlock PIN!
        if currentClean == targetPIN && activeOperator == nil {
            unlockApp()
            return
        }

        guard let op = activeOperator, let prev = previousValue else {
            // Also check if entered number alone matches PIN before calculating
            if currentClean == targetPIN {
                unlockApp()
            }
            return
        }

        let current = Double(currentClean) ?? 0
        let res = calculate(prev, op: op, current)
        displayText = formatResult(res)
        previousValue = nil
        activeOperator = nil
        isTypingNewNumber = true
    }

    private func calculate(_ a: Double, op: Operator, _ b: Double) -> Double {
        switch op {
        case .add: return a + b
        case .subtract: return a - b
        case .multiply: return a * b
        case .divide:
            if b == 0 {
                hasError = true
                return 0
            }
            return a / b
        }
    }

    private func formatResult(_ val: Double) -> String {
        if hasError {
            return "Error"
        }
        if val.truncatingRemainder(dividingBy: 1) == 0 && abs(val) < 1_000_000_000 {
            return "\(Int(val))"
        }
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 6
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: val)) ?? "\(val)"
    }

    private func clearCalculator() {
        displayText = "0"
        previousValue = nil
        activeOperator = nil
        isTypingNewNumber = true
        hasError = false
    }

    private func toggleSign() {
        if displayText != "0" && !hasError {
            if displayText.hasPrefix("-") {
                displayText.removeFirst()
            } else {
                displayText = "-" + displayText
            }
        }
    }

    private func applyPercent() {
        if let val = Double(displayText) {
            let res = val / 100.0
            displayText = formatResult(res)
            isTypingNewNumber = true
        }
    }

    private func playKeyClick() {
        AudioServicesPlaySystemSound(1104) // Standard iOS keyboard tick
    }

    private func unlockApp() {
        SensoryFeedbackService.shared.successFeedback()
        withAnimation(Design.Anim.spring) {
            onExit()
        }
    }

    private func attemptBiometricRecovery() {
        Task {
            if let onBiometricRecovery {
                let success = await onBiometricRecovery()
                if success {
                    unlockApp()
                }
            } else {
                unlockApp()
            }
        }
    }
}

// Custom touch style for calculator buttons
private struct CalcButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    CalculatorCamouflageView(onExit: {})
}
