import SwiftUI

/// Step-by-step mockup guide for activating the Safari Web Extension,
/// styled with QuitGambling's serene Obsidian-Glass design.
struct SafariExtensionTutorialView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                FlutedGlassBackgroundView()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: Design.Spacing.lg) {
                        // Header
                        VStack(alignment: .leading, spacing: 4) {
                            Text("STEP-BY-STEP GUIDE")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .tracking(1.2)
                                .foregroundStyle(Design.Colors.gold)

                            Text("Enable Safari Extension")
                                .font(.title2)
                                .bold()
                                .foregroundStyle(Design.Colors.ivory)

                            Text("The extension protects you from 524,000+ gambling & betting sites worldwide and immediately shows the mindful 5-second pause in Safari.")
                                .font(.caption)
                                .foregroundStyle(Design.Colors.textSecondary)
                                .lineSpacing(2)
                        }
                        .padding(.horizontal)
                        .padding(.top, Design.Spacing.sm)

                        // Step 1
                        StepCard(
                            stepNumber: 1,
                            title: "Open iOS Settings, scroll down and select “Apps” or “Safari”."
                        ) {
                            VStack(spacing: Design.Spacing.sm) {
                                Button {
                                    if let url = URL(string: UIApplication.openSettingsURLString) {
                                        UIApplication.shared.open(url)
                                    }
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: "gear")
                                        Text("Open iOS Settings")
                                    }
                                    .font(.subheadline)
                                    .bold()
                                    .foregroundStyle(Design.Colors.textOnPrimary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Design.Colors.primary)
                                    .clipShape(.capsule)
                                }
                                .padding(.top, 4)

                                // Mockup: iOS Settings List
                                MockupContainer {
                                    VStack(spacing: 0) {
                                        MockupHeader(title: "Settings")
                                        MockupRow(icon: "message.fill", iconBg: .green, title: "Messages")
                                        MockupRow(icon: "video.fill", iconBg: .green, title: "FaceTime")
                                        MockupRow(icon: "safari.fill", iconBg: .blue, title: "Safari", isHighlighted: true)
                                        MockupRow(icon: "chart.line.uptrend.xyaxis", iconBg: .black, title: "Stocks")
                                        MockupRow(icon: "cloud.sun.fill", iconBg: .blue, title: "Weather", isLast: true)
                                    }
                                }
                            }
                        }

                        // Step 2
                        StepCard(
                            stepNumber: 2,
                            title: "Scroll down in Safari settings and tap “Extensions”."
                        ) {
                            MockupContainer {
                                VStack(spacing: 0) {
                                    MockupHeader(title: "Safari")
                                    MockupSectionHeader(title: "GENERAL")
                                    MockupRow(title: "AutoFill")
                                    MockupRow(title: "Favorites")
                                    MockupRow(title: "Block Pop-ups", hasToggle: true)
                                    MockupRow(title: "Extensions", isHighlighted: true)
                                    MockupRow(title: "Downloads", isLast: true)
                                }
                            }
                        }

                        // Step 3
                        StepCard(
                            stepNumber: 3,
                            title: "Tap “QuitGambling Impulse Brake” in the extensions list."
                        ) {
                            MockupContainer {
                                VStack(spacing: 0) {
                                    MockupHeader(title: "Extensions", backText: "Safari")
                                    MockupRow(
                                        icon: "shield.checkered",
                                        iconBg: Design.Colors.gold,
                                        title: "QuitGambling Impulse Brake",
                                        trailingText: "Off",
                                        isHighlighted: true,
                                        isLast: true
                                    )
                                }
                            }
                        }

                        // Step 4
                        StepCard(
                            stepNumber: 4,
                            title: "Turn on the “Allow Extension” switch."
                        ) {
                            MockupContainer {
                                VStack(spacing: 12) {
                                    HStack(spacing: 12) {
                                        ZStack {
                                            Circle()
                                                .fill(Design.Colors.gold.opacity(0.2))
                                                .frame(width: 44, height: 44)
                                            Image(systemName: "shield.checkered")
                                                .font(.title3)
                                                .foregroundStyle(Design.Colors.gold)
                                        }

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("QuitGambling Impulse Brake")
                                                .font(.subheadline)
                                                .bold()
                                                .foregroundStyle(Design.Colors.ivory)
                                            Text("App: QuitGambling")
                                                .font(.caption2)
                                                .foregroundStyle(Design.Colors.textSecondary)
                                            Text("Mindful 5-second pause on casino websites.")
                                                .font(.caption2)
                                                .foregroundStyle(Design.Colors.textSecondary)
                                        }
                                        Spacer()
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.top, 10)

                                    // Highlighted Toggle
                                    HStack {
                                        Text("Allow Extension")
                                            .font(.caption)
                                            .bold()
                                            .foregroundStyle(Design.Colors.ivory)
                                        Spacer()
                                        Toggle("", isOn: .constant(true))
                                            .labelsHidden()
                                            .tint(.green)
                                    }
                                    .padding(10)
                                    .background(Color.white.opacity(0.04))
                                    .clipShape(.rect(cornerRadius: Design.Radius.sm))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: Design.Radius.sm)
                                            .stroke(Design.Colors.gold, lineWidth: 2)
                                    )
                                    .padding(.horizontal, 10)
                                    .padding(.bottom, 10)
                                }
                            }
                        }

                        // Step 5
                        StepCard(
                            stepNumber: 5,
                            title: "Scroll down to “Permissions” and set “All Websites” to “Allow”."
                        ) {
                            VStack(alignment: .leading, spacing: Design.Spacing.xs) {
                                MockupContainer {
                                    VStack(spacing: 0) {
                                        MockupHeader(title: "All Websites", backText: "QuitGambling")
                                        MockupSelectRow(title: "Ask")
                                        MockupSelectRow(title: "Deny")
                                        MockupSelectRow(title: "Allow", isSelected: true, isHighlighted: true, isLast: true)
                                    }
                                }

                                Text("Note: This enables QuitGambling to show the 5-second pause immediately without triggering a Safari confirmation prompt each time.")
                                    .font(.caption2)
                                    .foregroundStyle(Design.Colors.textSecondary)
                                    .lineSpacing(2)
                                    .padding(.horizontal, 4)
                            }
                        }

                        // Step 6
                        StepCard(
                            stepNumber: 6,
                            title: "All set! Visit a casino site in Safari (e.g. bwin.com, draftkings.com)."
                        ) {
                            VStack(alignment: .leading, spacing: Design.Spacing.xs) {
                                // Safari Address Bar Mockup
                                MockupContainer {
                                    VStack(spacing: 12) {
                                        // Address bar
                                        HStack(spacing: 8) {
                                            Image(systemName: "puzzlepiece.extension.fill")
                                                .font(.caption)
                                                .foregroundStyle(Design.Colors.gold)
                                            Spacer()
                                            HStack(spacing: 4) {
                                                Image(systemName: "lock.fill")
                                                    .font(.caption2)
                                                Text("bwin.com")
                                                    .font(.caption)
                                                    .bold()
                                            }
                                            .foregroundStyle(Design.Colors.ivory)
                                            Spacer()
                                            Image(systemName: "arrow.clockwise")
                                                .font(.caption)
                                                .foregroundStyle(Design.Colors.textSecondary)
                                        }
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(Color.white.opacity(0.08))
                                        .clipShape(.capsule)
                                        .padding(.horizontal, 12)
                                        .padding(.top, 10)

                                        // Mini Gate Preview
                                        VStack(spacing: 6) {
                                            ZStack {
                                                Circle()
                                                    .fill(Design.Colors.primary.opacity(0.15))
                                                    .frame(width: 38, height: 38)
                                                Image(systemName: "shield.checkered")
                                                    .font(.subheadline)
                                                    .foregroundStyle(Design.Colors.primary)
                                            }

                                            Text("Take a deep breath.")
                                                .font(.subheadline)
                                                .bold()
                                                .foregroundStyle(Design.Colors.ivory)

                                            Text("5-Second Mindful Pause")
                                                .font(.caption2)
                                                .foregroundStyle(Design.Colors.gold)

                                            Label("Return to Safety", systemImage: "shield.fill")
                                                .font(.caption2)
                                                .bold()
                                                .foregroundStyle(Design.Colors.textOnPrimary)
                                                .padding(.horizontal, 14)
                                                .padding(.vertical, 6)
                                                .background(Design.Colors.primary)
                                                .clipShape(.capsule)
                                                .padding(.top, 2)
                                        }
                                        .padding(.bottom, 12)
                                    }
                                }

                                Text("524,000+ gambling & betting websites are pre-configured. Protection activates automatically!")
                                    .font(.caption2)
                                    .foregroundStyle(Design.Colors.primary)
                                    .padding(.horizontal, 4)
                            }
                        }

                        // Bottom Finish Button
                        Button {
                            dismiss()
                        } label: {
                            Text("Done & Understood")
                                .font(.subheadline)
                                .bold()
                                .foregroundStyle(Design.Colors.textOnPrimary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Design.Colors.primary)
                                .clipShape(.rect(cornerRadius: Design.Radius.md))
                        }
                        .padding(.horizontal)
                        .padding(.top, Design.Spacing.md)
                        .padding(.bottom, Design.Spacing.xl)
                    }
                }
            }
            .navigationTitle("Safari Extension")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(Design.Colors.textSecondary)
                }
            }
        }
    }
}

// MARK: - Subcomponents

private struct StepCard<Content: View>: View {
    let stepNumber: Int
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.sm) {
            HStack(alignment: .top, spacing: Design.Spacing.sm) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.12))
                        .frame(width: 28, height: 28)
                    Text("\(stepNumber)")
                        .font(.caption)
                        .bold()
                        .foregroundStyle(Design.Colors.ivory)
                }

                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(Design.Colors.ivory)
                    .lineSpacing(2)
            }

            content()
        }
        .sereneCardStyle(padding: Design.Spacing.md)
        .padding(.horizontal)
    }
}

private struct MockupContainer<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            content()
        }
        .frame(maxWidth: .infinity)
        .background(Color.black.opacity(0.45))
        .clipShape(.rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }
}

private struct MockupHeader: View {
    let title: String
    var backText: String? = nil

    var body: some View {
        HStack {
            if let back = backText {
                HStack(spacing: 2) {
                    Image(systemName: "chevron.left")
                        .font(.caption2)
                    Text(back)
                        .font(.caption2)
                }
                .foregroundStyle(.blue)
            }
            Spacer()
            Text(title)
                .font(.caption)
                .bold()
                .foregroundStyle(Design.Colors.ivory)
            Spacer()
            if backText != nil {
                // Spacer balance
                Text("       ").font(.caption2)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.04))
    }
}

private struct MockupSectionHeader: View {
    let title: String

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(Design.Colors.textSecondary)
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(Color.clear)
    }
}

private struct MockupRow: View {
    var icon: String? = nil
    var iconBg: Color = .blue
    let title: String
    var trailingText: String? = nil
    var hasToggle: Bool = false
    var isHighlighted: Bool = false
    var isLast: Bool = false

    var body: some View {
        HStack(spacing: 10) {
            if let icon = icon {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(iconBg)
                        .frame(width: 22, height: 22)
                    Image(systemName: icon)
                        .font(.system(size: 11))
                        .foregroundStyle(.white)
                }
            }

            Text(title)
                .font(.caption)
                .foregroundStyle(Design.Colors.ivory)

            Spacer()

            if let trailing = trailingText {
                Text(trailing)
                    .font(.caption2)
                    .foregroundStyle(Design.Colors.textSecondary)
            }

            if hasToggle {
                Toggle("", isOn: .constant(true))
                    .labelsHidden()
                    .scaleEffect(0.65)
            } else {
                Image(systemName: "chevron.right")
                    .font(.system(size: 9))
                    .foregroundStyle(Design.Colors.textTertiary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(isHighlighted ? Design.Colors.gold.opacity(0.12) : Color.clear)
        .overlay(
            Group {
                if isHighlighted {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Design.Colors.gold, lineWidth: 2)
                        .padding(.horizontal, 4)
                }
            }
        )
        .overlay(alignment: .bottom) {
            if !isLast && !isHighlighted {
                Divider()
                    .background(Color.white.opacity(0.06))
                    .padding(.leading, icon != nil ? 44 : 12)
            }
        }
    }
}

private struct MockupSelectRow: View {
    let title: String
    var isSelected: Bool = false
    var isHighlighted: Bool = false
    var isLast: Bool = false

    var body: some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundStyle(Design.Colors.ivory)

            Spacer()

            if isSelected {
                Image(systemName: "checkmark")
                    .font(.caption2)
                    .bold()
                    .foregroundStyle(.blue)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isHighlighted ? Design.Colors.gold.opacity(0.12) : Color.clear)
        .overlay(
            Group {
                if isHighlighted {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Design.Colors.gold, lineWidth: 2)
                        .padding(.horizontal, 4)
                }
            }
        )
        .overlay(alignment: .bottom) {
            if !isLast && !isHighlighted {
                Divider()
                    .background(Color.white.opacity(0.06))
                    .padding(.leading, 12)
            }
        }
    }
}

#Preview {
    SafariExtensionTutorialView()
}
