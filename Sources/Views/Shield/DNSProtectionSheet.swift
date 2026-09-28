import SwiftUI

/// Elegant in-app sheet for configuring system-wide DNS Gambling Protection without any Safari extensions.
struct DNSProtectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ShieldManager.self) private var shieldManager
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @State private var dnsService = DNSProtectionService.shared
    @State private var isActivating = false
    @State private var showingPaywall = false

    var body: some View {
        NavigationStack {
            ZStack {
                FlutedGlassBackgroundView()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: Design.Spacing.lg) {
                        // Screen-Time Baseline Confirmation Banner
                        if shieldManager.isShieldActive {
                            HStack(spacing: 10) {
                                Image(systemName: "checkmark.shield.fill")
                                    .font(.title3)
                                    .foregroundStyle(.green)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Screen Time Shield is active")
                                        .font(.caption)
                                        .bold()
                                        .foregroundStyle(Color.green)
                                    Text("Top casinos (Stake, Rollbit, Tipico, etc.) are already reliably blocked on this iPhone.")
                                        .font(.caption2)
                                        .foregroundStyle(Design.Colors.textSecondary)
                                }
                            }
                            .padding(Design.Spacing.sm)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.green.opacity(0.12))
                            .clipShape(.rect(cornerRadius: Design.Radius.sm))
                        }

                        // Hero Header
                        heroHeaderCard

                        // In-App Direct Activation (The Only Method)
                        directActivationCard

                        // Benefits
                        dnsBenefitsCard
                    }
                    .padding(Design.Spacing.md)
                    .padding(.bottom, Design.Spacing.xl)
                }
            }
            .navigationTitle("DNS Network Shield")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.subheadline)
                    .bold()
                    .foregroundStyle(Design.Colors.primary)
                }
            }
            .fullScreenCover(isPresented: $showingPaywall) {
                PaywallView()
            }
            .task {
                await dnsService.checkStatus()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                Task {
                    await dnsService.checkStatus()
                }
            }
        }
    }

    // MARK: - Hero Header Card

    private var heroHeaderCard: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.sm) {
            HStack(spacing: Design.Spacing.sm) {
                ZStack {
                    Circle()
                        .fill(Design.Colors.primary.opacity(0.18))
                        .frame(width: 44, height: 44)
                    Image(systemName: "shield.checkered")
                        .font(.title3)
                        .foregroundStyle(Design.Colors.primary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("System-Wide Network Shield")
                        .font(.headline)
                        .bold()
                        .foregroundStyle(Design.Colors.ivory)
                    Text("525,000+ gambling sites blocked")
                        .font(.caption)
                        .foregroundStyle(Design.Colors.gold)
                }

                Spacer()

                if dnsService.isDNSActive {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(.green)
                            .frame(width: 8, height: 8)
                        Text("Active")
                            .font(.caption2)
                            .bold()
                            .foregroundStyle(.green)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.15))
                    .clipShape(.capsule)
                }
            }

            Text("Blocks all known online casinos, sportsbooks, and crypto bookmakers **directly at network level** — across Safari, Google Chrome, all apps and games. Fully **without Safari extensions**.")
                .font(.caption)
                .foregroundStyle(Design.Colors.textSecondary)
                .lineSpacing(2)
        }
        .sereneCardStyle(padding: Design.Spacing.md)
    }

    // MARK: - Direct In-App Activation Card

    private var directActivationCard: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.md) {
            HStack {
                Label("In-App Setup", systemImage: "bolt.fill")
                    .font(.subheadline)
                    .bold()
                    .foregroundStyle(Design.Colors.primary)
                Spacer()
                if dnsService.isDNSActive {
                    Text("Protected")
                        .font(.caption2)
                        .bold()
                        .foregroundStyle(.green)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.15))
                        .clipShape(.capsule)
                }
            }

            Text("QuitGambling configures Apple's official encrypted DNS interface to block over 500,000 gambling domains across your entire device.")
                .font(.caption)
                .foregroundStyle(Design.Colors.textSecondary)
                .lineSpacing(2)

            if let err = dnsService.errorMessage {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption2)
                        .foregroundStyle(Design.Colors.sos)
                    Text(err)
                        .font(.caption2)
                        .bold()
                        .foregroundStyle(Design.Colors.sos)
                }
                .padding(.vertical, 2)
            }

            if dnsService.isDNSActive {
                // ACTIVE STATE
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.shield.fill")
                            .font(.title3)
                            .foregroundStyle(.green)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("System-Wide DNS Shield Active")
                                .font(.subheadline)
                                .bold()
                                .foregroundStyle(.white)
                            Text("525,000+ gambling domains blocked across all apps and browsers.")
                                .font(.caption2)
                                .foregroundStyle(Design.Colors.textSecondary)
                        }
                    }
                    .padding(Design.Spacing.sm)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.green.opacity(0.12))
                    .clipShape(.rect(cornerRadius: Design.Radius.sm))

                    Button {
                        Task {
                            isActivating = true
                            defer { isActivating = false }
                            await dnsService.disableDNSProtection()
                        }
                    } label: {
                        HStack(spacing: 8) {
                            if isActivating {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "xmark.circle")
                            }
                            Text("Disable DNS Shield")
                                .font(.subheadline)
                                .bold()
                        }
                        .foregroundStyle(Design.Colors.sos)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Design.Colors.sos.opacity(0.15))
                        .clipShape(.rect(cornerRadius: Design.Radius.md))
                    }
                    .disabled(isActivating)
                }
            } else if dnsService.isConfigured {
                // PROFILE SAVED, NEEDS 1-TIME ACTIVATION IN SETTINGS
                VStack(alignment: .leading, spacing: Design.Spacing.sm) {
                    // Step 1: Done
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.body)
                            .foregroundStyle(.green)
                        VStack(alignment: .leading, spacing: 1) {
                            Text("1. DNS Profile Saved in iOS")
                                .font(.caption)
                                .bold()
                                .foregroundStyle(.green)
                            Text("QuitGambling gambling shield filter is registered with iOS.")
                                .font(.caption2)
                                .foregroundStyle(Design.Colors.textSecondary)
                        }
                    }
                    .padding(Design.Spacing.sm)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.green.opacity(0.10))
                    .clipShape(.rect(cornerRadius: Design.Radius.sm))

                    // Step 2: User Action / 1-Tap Direct Activation
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 6) {
                            Image(systemName: "bolt.shield.fill")
                                .font(.body)
                                .foregroundStyle(Design.Colors.gold)
                            Text("2. Activate in iOS")
                                .font(.caption)
                                .bold()
                                .foregroundStyle(Design.Colors.gold)
                        }

                        Text("Tap **Activate Now** to confirm the iOS DNS filter profile:")
                            .font(.caption2)
                            .foregroundStyle(Design.Colors.textSecondary)

                        // PRIMARY 1-TAP ACTIVATION BUTTON
                        Button {
                            if !subscriptionManager.isPro {
                                showingPaywall = true
                            } else {
                                Task {
                                    isActivating = true
                                    defer { isActivating = false }
                                    _ = await dnsService.activateDNS()
                                }
                            }
                        } label: {
                            HStack(spacing: 8) {
                                if isActivating {
                                    ProgressView()
                                        .tint(.black)
                                } else {
                                    Image(systemName: "bolt.fill")
                                }
                                Text("Activate Now in iOS")
                                    .font(.subheadline)
                                    .bold()
                            }
                            .foregroundStyle(Design.Colors.textOnPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Design.Colors.gold)
                            .clipShape(.rect(cornerRadius: Design.Radius.md))
                            .shadow(color: Design.Colors.gold.opacity(0.35), radius: 6, y: 2)
                        }
                        .disabled(isActivating)

                        // Secondary: Manual Settings fallback if preferred
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Or manually enable in iOS Settings:")
                                .font(.caption2)
                                .foregroundStyle(Design.Colors.textSecondary)

                            HStack(spacing: 8) {
                                Button {
                                    if !subscriptionManager.isPro {
                                        showingPaywall = true
                                    } else {
                                        dnsService.openDNSSettings()
                                    }
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "gear")
                                        Text("Open Settings →")
                                    }
                                    .font(.caption)
                                    .bold()
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 38)
                                    .background(Color.white.opacity(0.12))
                                    .clipShape(.rect(cornerRadius: Design.Radius.sm))
                                }

                                Button {
                                    Task {
                                        isActivating = true
                                        defer { isActivating = false }
                                        _ = await dnsService.activateDNS()
                                    }
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "arrow.clockwise")
                                        Text("Verify")
                                    }
                                    .font(.caption)
                                    .bold()
                                    .foregroundStyle(.white)
                                    .frame(width: 85)
                                    .frame(height: 38)
                                    .background(Color.white.opacity(0.12))
                                    .clipShape(.rect(cornerRadius: Design.Radius.sm))
                                }
                            }

                            Text("Path: Top left ‹ Back → General → VPN & Device Management → DNS → QuitGambling")
                                .font(.caption2)
                                .foregroundStyle(Design.Colors.ivory.opacity(0.65))
                        }
                        .padding(.top, 4)
                    }
                    .padding(Design.Spacing.sm)
                    .background(Design.Colors.gold.opacity(0.08))
                    .clipShape(.rect(cornerRadius: Design.Radius.sm))
                }
            } else {
                // NOT CONFIGURED YET
                Button {
                    if !subscriptionManager.isPro {
                        showingPaywall = true
                    } else {
                        Task {
                            isActivating = true
                            defer { isActivating = false }
                            _ = await dnsService.enableDNSProtection()
                        }
                    }
                } label: {
                    HStack(spacing: 8) {
                        if isActivating {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "checkmark.shield.fill")
                        }
                        Text("Set Up DNS Shield in iOS")
                            .font(.subheadline)
                            .bold()
                    }
                    .foregroundStyle(Design.Colors.textOnPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Design.Colors.primary)
                    .clipShape(.rect(cornerRadius: Design.Radius.md))
                }
                .disabled(isActivating)
                .padding(.top, 4)
            }
        }
        .sereneCardStyle(padding: Design.Spacing.md)
    }

    // MARK: - DNS Benefits Card

    private var dnsBenefitsCard: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.xs) {
            Label("Network Shield Benefits", systemImage: "sparkles")
                .font(.subheadline)
                .bold()
                .foregroundStyle(Design.Colors.gold)

            VStack(alignment: .leading, spacing: 6) {
                benefitItem(icon: "checkmark.circle.fill", title: "Seamless Background Protection", subtitle: "Blocks 525,000+ gambling domains at system level.")
                benefitItem(icon: "globe", title: "Protects All Browsers & Apps", subtitle: "Filters Safari, Chrome, Firefox, and in-app web views.")
                benefitItem(icon: "bolt.batteryblock.fill", title: "Battery & Data Friendly", subtitle: "Zero added battery consumption or data overhead.")
            }
            .padding(.top, 4)
        }
        .sereneCardStyle(padding: Design.Spacing.md)
    }

    private func benefitItem(icon: String, title: String, subtitle: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(Design.Colors.primary)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.caption)
                    .bold()
                    .foregroundStyle(Design.Colors.ivory)
                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(Design.Colors.textSecondary)
            }
        }
    }
}

#Preview {
    DNSProtectionSheet()
}
