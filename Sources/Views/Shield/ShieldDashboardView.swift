import SwiftUI
import FamilyControls

/// Fully functional Shield Dashboard for Screen Time app and targeted website blocking with custom domain management and working deactivation.
struct ShieldDashboardView: View {
    @Environment(ShieldManager.self) private var shieldManager
    @Environment(\.scenePhase) private var scenePhase
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @State private var isPickerPresented = false
    @State private var isShowingDomainList = false
    @State private var isShowingFrictionGate = false
    @State private var isShieldHovering = false
    @State private var newDomainText = ""
    @State private var domainSearchText = ""
    @State private var isShowingDNSSheet = false
    @State private var isShowingPaywall = false
    @State private var dnsService = DNSProtectionService.shared

    var body: some View {
        @Bindable var shield = shieldManager

        ZStack {
            FlutedGlassBackgroundView()

            ScrollView(showsIndicators: false) {
                VStack(spacing: Design.Spacing.lg) {
                    // Hero Shield Card
                    shieldHeroCard(shield)

                    // Mode Selection Card
                    modeSelectionCard(shield)

                    // App Picker Section
                    appPickerCard

                    // Targeted Casino Domains Section (Option 1 - Default Screen Time)
                    casinoDomainBlocklistCard

                    // System-wide DNS Network Protection (Option 2 - 525,000 Domains ohne Erweiterung)
                    dnsProtectionCard

                    // Location Protection Card (Gefahrenzonen-Radar)
                    zoneRadarCard

                    // Privacy Guarantee
                    privacyGuaranteeCard
                }
                .padding(Design.Spacing.md)
                .padding(.bottom, 96)
            }
        }
        .navigationTitle("Shield".loc)
        .familyActivityPicker(
            isPresented: $isPickerPresented,
            selection: $shield.activitySelection
        )
        .sheet(isPresented: $isShowingDomainList) {
            domainListSheet
                .scrollIndicators(.hidden)
        }
        .sheet(isPresented: $isShowingDNSSheet) {
            DNSProtectionSheet()
                .scrollIndicators(.hidden)
        }
        .fullScreenCover(isPresented: $isShowingPaywall) {
            PaywallView()
        }
        .scrollIndicators(.hidden)
        .fullScreenCover(isPresented: $isShowingFrictionGate) {
            MindfulFrictionGateView(
                title: "Deactivate Shield?".loc,
                subtitle: "Take 5 seconds to breathe calmly before turning off protection.".loc,
                duration: 5,
                confirmButtonTitle: "Really Turn Off Shield Now".loc,
                onConfirmOverride: {
                    withAnimation(Design.Anim.spring) {
                        shieldManager.disableShield()
                        Task {
                            await dnsService.disableDNSProtection()
                        }
                    }
                }
            )
        }
        .task {
            await shieldManager.checkAuthorization()
            await dnsService.checkStatus()
            withAnimation(.easeInOut(duration: 2.6).repeatForever(autoreverses: true)) {
                isShieldHovering = true
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                Task {
                    await shieldManager.checkAuthorization()
                    await dnsService.checkStatus()
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            Task {
                await shieldManager.checkAuthorization()
                await dnsService.checkStatus()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name.NEDNSSettingsConfigurationDidChange)) { _ in
            Task {
                await dnsService.checkStatus()
            }
        }
        .dismissKeyboardOnTap()
    }

    // MARK: - Hero Shield Card

    private func shieldHeroCard(_ shield: ShieldManager) -> some View {
        VStack(spacing: Design.Spacing.md) {
            // Case 1: NOT AUTHORIZED & DNS NOT ACTIVE (Needs setup)
            if !shield.isAuthorized && !dnsService.isDNSActive {
                // Shield Badge in Amber/Gold
                ZStack {
                    Circle()
                        .fill(Design.Colors.gold.opacity(0.18))
                        .frame(width: 82, height: 82)
                        .background(.ultraThinMaterial, in: Circle())

                    Circle()
                        .strokeBorder(Design.Colors.gold.opacity(0.6), lineWidth: 2.5)
                        .frame(width: 82, height: 82)

                    Image(systemName: "exclamationmark.shield.fill")
                        .font(.system(size: 38, weight: .medium))
                        .foregroundStyle(Design.Colors.gold)
                }
                .shadow(color: Design.Colors.gold.opacity(0.35), radius: 10, y: 4)
                .frame(height: 96)
                .padding(.top, 4)

                // Warning Pill
                HStack(spacing: 6) {
                    Circle()
                        .fill(Design.Colors.gold)
                        .frame(width: 9, height: 9)

                    Text("PERMISSION REQUIRED".loc)
                        .font(.caption)
                        .fontWeight(.heavy)
                        .foregroundStyle(Design.Colors.gold)
                        .tracking(1.2)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Design.Colors.gold.opacity(0.16))
                .clipShape(Capsule())

                // Status Text
                VStack(spacing: 4) {
                    Text("Screen Time Permission Required".loc)
                        .font(.title3)
                        .bold()
                        .foregroundStyle(Color.white)

                    Text("To reliably block websites and apps on this iPhone, Quit Gambling requires official Apple Screen Time authorization.".loc)
                        .font(.caption)
                        .foregroundStyle(Design.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    if let errorMsg = shield.authorizationErrorMessage {
                        Text(errorMsg)
                            .font(.caption2)
                            .foregroundStyle(Design.Colors.sos)
                            .padding(.top, 2)
                    }
                }

                // Grant Permission Button
                Button {
                    Task {
                        _ = await shieldManager.requestAuthorization()
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "hand.raised.fill")
                            .font(.headline)
                        Text("Grant in iOS & Activate Shield".loc)
                            .font(.headline)
                            .bold()
                    }
                    .foregroundStyle(Design.Colors.textOnPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Design.Colors.primary)
                    .clipShape(.rect(cornerRadius: Design.Radius.md))
                    .shadow(color: Design.Colors.primary.opacity(0.35), radius: 10, y: 4)
                }

            // Case 2: PROTECTED (Screen Time OR DNS active)
            } else if shield.isShieldActive || dnsService.isDNSActive {
                // Hovering Shield Badge (Green)
                ZStack {
                    Ellipse()
                        .fill(Design.Colors.primary.opacity(isShieldHovering ? 0.16 : 0.32))
                        .frame(width: isShieldHovering ? 54 : 70, height: isShieldHovering ? 10 : 15)
                        .blur(radius: isShieldHovering ? 8 : 5)
                        .offset(y: 48)

                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Design.Colors.primary.opacity(isShieldHovering ? 0.30 : 0.18),
                                    Design.Colors.primary.opacity(0.06),
                                    .clear
                                ],
                                center: .center,
                                startRadius: 10,
                                endRadius: 58
                            )
                        )
                        .frame(width: 116, height: 116)
                        .scaleEffect(isShieldHovering ? 1.08 : 0.94)
                        .blur(radius: 6)

                    ZStack {
                        Circle()
                            .fill(Design.Colors.primary.opacity(0.18))
                            .frame(width: 82, height: 82)
                            .background(.ultraThinMaterial, in: Circle())

                        Circle()
                            .strokeBorder(
                                LinearGradient(
                                    colors: [Design.Colors.primary, Design.Colors.primary.opacity(0.65)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2.5
                            )
                            .frame(width: 82, height: 82)

                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 38, weight: .medium))
                            .foregroundStyle(Design.Colors.primary)
                            .scaleEffect(1.04)
                    }
                    .shadow(
                        color: Design.Colors.primary.opacity(isShieldHovering ? 0.40 : 0.60),
                        radius: isShieldHovering ? 16 : 8,
                        x: 0,
                        y: isShieldHovering ? 12 : 6
                    )
                    .offset(y: isShieldHovering ? -8 : 2)
                }
                .frame(height: 96)
                .padding(.top, 4)

                // Status Pill (GREEN)
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 9, height: 9)

                    Text("PROTECTION IS ACTIVE".loc)
                        .font(.caption)
                        .fontWeight(.heavy)
                        .foregroundStyle(Color.green)
                        .tracking(1.2)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Color.green.opacity(0.16))
                .clipShape(Capsule())

                // Status Text
                VStack(spacing: 4) {
                    if shield.isShieldActive && dnsService.isDNSActive {
                        Text("Maximum Dual Protection Active".loc)
                            .font(.title3)
                            .bold()
                            .foregroundStyle(Color.white)

                        Text("Screen Time (Top 25 %@) + DNS (525,000+ domains) secure your iPhone around the clock.".loc(shieldManager.currentCountry.name))
                            .font(.caption)
                            .foregroundStyle(Design.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    } else if dnsService.isDNSActive {
                        Text("DNS Network Protection Active".loc)
                            .font(.title3)
                            .bold()
                            .foregroundStyle(Color.white)

                        Text("Over 525,000 gambling domains are blocked in Safari, Chrome & all apps at network level.".loc)
                            .font(.caption)
                            .foregroundStyle(Design.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    } else {
                        Text("Protection Armed & Active".loc)
                            .font(.title3)
                            .bold()
                            .foregroundStyle(Color.white)

                        Text("%d gambling websites in Safari & apps are blocked.".loc(shield.activeFilterDomains.count))
                            .font(.caption)
                            .foregroundStyle(Design.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }

                // Deactivate Action
                Button {
                    isShowingFrictionGate = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "pause.circle")
                            .font(.headline)
                        Text("Pause / Turn Off Protection...".loc)
                            .font(.subheadline)
                            .bold()
                    }
                    .foregroundStyle(Color.white.opacity(0.85))
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: Design.Radius.md)
                            .stroke(Color.white.opacity(0.20), lineWidth: 1)
                    )
                    .clipShape(.rect(cornerRadius: Design.Radius.md))
                }

            // Case 3: AUTHORIZED & SHIELD INACTIVE (Red, Disabled)
            } else {
                // Shield Badge in Red (Disabled)
                ZStack {
                    Circle()
                        .fill(Color.red.opacity(0.10))
                        .frame(width: 82, height: 82)
                        .background(.ultraThinMaterial, in: Circle())

                    Circle()
                        .strokeBorder(Color.red.opacity(0.4), lineWidth: 2.5)
                        .frame(width: 82, height: 82)

                    Image(systemName: "shield.slash.fill")
                        .font(.system(size: 38, weight: .medium))
                        .foregroundStyle(Design.Colors.sos)
                }
                .shadow(color: Color.black.opacity(0.15), radius: 8, y: 6)
                .frame(height: 96)
                .padding(.top, 4)

                // Status Pill (RED)
                HStack(spacing: 6) {
                    Circle()
                        .fill(Design.Colors.sos)
                        .frame(width: 9, height: 9)

                    Text("PROTECTION IS OFF".loc)
                        .font(.caption)
                        .fontWeight(.heavy)
                        .foregroundStyle(Design.Colors.sos)
                        .tracking(1.2)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Design.Colors.sos.opacity(0.16))
                .clipShape(Capsule())

                // Status Text
                VStack(spacing: 4) {
                    Text("Shield is Inactive".loc)
                        .font(.title3)
                        .bold()
                        .foregroundStyle(Color.white)

                    Text("Websites and apps are freely accessible. Enable the shield for automatic protection.".loc)
                        .font(.caption)
                        .foregroundStyle(Design.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                // Activate Button (GREEN)
                Button {
                    Task {
                        if !shieldManager.isAuthorized {
                            _ = await shieldManager.requestAuthorization()
                        } else {
                            withAnimation(Design.Anim.spring) {
                                shieldManager.isShieldActive = true
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "shield.fill")
                            .font(.headline)
                        Text("TURN SHIELD ON NOW".loc)
                            .font(.headline)
                            .bold()
                    }
                    .foregroundStyle(Design.Colors.textOnPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Design.Colors.primary)
                    .clipShape(.rect(cornerRadius: Design.Radius.md))
                    .shadow(color: Design.Colors.primary.opacity(0.35), radius: 10, y: 4)
                }
            }
        }
        .sereneCardStyle(padding: Design.Spacing.lg)
    }

    // MARK: - Mode Selection Card

    private func modeSelectionCard(_ shield: ShieldManager) -> some View {
        VStack(alignment: .leading, spacing: Design.Spacing.sm) {
            Label("Protection Mode".loc, systemImage: "clock.badge.checkmark")
                .font(.headline)
                .foregroundStyle(Design.Colors.secondary)

            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text("24/7 Continuous Shield".loc)
                            .font(.subheadline)
                            .bold()
                            .foregroundStyle(Design.Colors.secondary)
                        Text("ACTIVE".loc)
                            .font(.system(size: 9, weight: .black))
                            .foregroundStyle(Design.Colors.textOnPrimary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Design.Colors.primary)
                            .clipShape(Capsule())
                    }
                    Text("Always active for maximum protection. Gambling sites and apps remain blocked around the clock.".loc)
                        .font(.caption2)
                        .foregroundStyle(Design.Colors.textSecondary)
                }
                Spacer()
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(Design.Colors.primary)
            }
            .padding(Design.Spacing.sm)
            .background(Design.Colors.primary.opacity(0.12))
            .clipShape(.rect(cornerRadius: Design.Radius.sm))
        }
        .sereneCardStyle(padding: Design.Spacing.md)
    }

    // MARK: - App Picker Card

    private var appPickerCard: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.md) {
            HStack {
                Label("Apps & Websites Shield".loc, systemImage: "shield.checkered")
                    .font(.headline)
                    .foregroundStyle(Design.Colors.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Spacer()
            }

            let appCount = shieldManager.activitySelection.applicationTokens.count
            let catCount = shieldManager.activitySelection.categoryTokens.count
            let webCount = shieldManager.activitySelection.webDomainTokens.count

            if (appCount + catCount + webCount) > 0 {
                Text("%d app(s), %d category(ies) & %d website(s) protected by Quit Gambling shield.".loc(appCount, catCount, webCount))
                    .font(.subheadline)
                    .bold()
                    .foregroundStyle(Design.Colors.primary)
            } else {
                Text("Select apps and websites (e.g. betting apps, casino sites). When opened in Safari or on your Home Screen, the Quit Gambling shield appears immediately.".loc)
                    .font(.subheadline)
                    .foregroundStyle(Design.Colors.textSecondary)
            }

            Button {
                Task {
                    if !shieldManager.isAuthorized {
                        _ = await shieldManager.requestAuthorization()
                    }
                    isPickerPresented = true
                }
            } label: {
                Label("Select Apps & Websites to Block".loc, systemImage: "plus.circle.fill")
                    .font(.subheadline)
                    .bold()
                    .foregroundStyle(Design.Colors.primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Design.Colors.primary.opacity(0.12))
                    .clipShape(.rect(cornerRadius: Design.Radius.md))
            }
        }
        .sereneCardStyle(padding: Design.Spacing.md)
    }

    // MARK: - Casino Domain Card

    private var casinoDomainBlocklistCard: some View {
        @Bindable var shield = shieldManager

        return VStack(alignment: .leading, spacing: Design.Spacing.sm) {
            HStack {
                Label("Blocked Websites".loc, systemImage: "network.badge.shield.half.filled")
                    .font(.headline)
                    .foregroundStyle(Design.Colors.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Spacer()
                Text("%d Websites".loc(shieldManager.allBlockedDomains.count))
                    .font(.caption2)
                    .bold()
                    .foregroundStyle(Design.Colors.gold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Design.Colors.gold.opacity(0.15))
                    .clipShape(.capsule)
            }

            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Design.Colors.primary)
                    .font(.subheadline)
                Text("Top 25 in %@ automatically blocked".loc(shieldManager.currentCountry.name))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Design.Colors.secondary)
                Spacer()
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(Design.Colors.primary.opacity(0.12))
            .clipShape(.rect(cornerRadius: Design.Radius.sm))

            let sampleList = shieldManager.defaultGamblingDomains.prefix(4).joined(separator: ", ")
            Text("Quit Gambling blocks the 25 most critical gambling & betting providers for %@ (e.g. %@).".loc(shieldManager.currentCountry.name, sampleList))
                .font(.caption)
                .foregroundStyle(Design.Colors.textSecondary)
                .lineSpacing(2)

            // Add Custom Domain Field
            HStack {
                TextField("e.g. new-casino.com", text: $newDomainText)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .font(.caption)
                    .padding(8)
                    .background(Design.Colors.surfaceHover)
                    .clipShape(.rect(cornerRadius: Design.Radius.sm))

                Button {
                    guard !newDomainText.isEmpty else { return }
                    shieldManager.addCustomDomain(newDomainText)
                    newDomainText = ""
                } label: {
                    Text("+ Add".loc)
                        .font(.caption)
                        .bold()
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(Design.Colors.primary)
                        .foregroundStyle(Design.Colors.textOnPrimary)
                        .clipShape(.rect(cornerRadius: Design.Radius.sm))
                }
            }
            .padding(.top, 2)

            if !newDomainText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                let clean = newDomainText.trimmingCharacters(in: .whitespacesAndNewlines)
                if shieldManager.isDomainInGlobalDatabase(clean) {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(.green)
                        Text("Already in the global 524k protection database".loc)
                            .font(.caption2)
                            .bold()
                            .foregroundStyle(.green)
                    }
                    .padding(.top, 2)
                }
            }

            Button {
                isShowingDomainList = true
            } label: {
                Text("View & manage all %d standard domains →".loc(shieldManager.allBlockedDomains.count))
                    .font(.caption)
                    .bold()
                    .foregroundStyle(Design.Colors.primary)
            }
            .padding(.top, 2)
        }
        .sereneCardStyle(padding: Design.Spacing.md)
    }

    // MARK: - DNS Network Protection Card (Option 2 - 525,000 Domains without Extension)

    private var dnsProtectionCard: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.sm) {
            HStack {
                HStack(spacing: 6) {
                    Label("Network Shield".loc, systemImage: "shield.checkered")
                        .font(.headline)
                        .foregroundStyle(Design.Colors.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    if !subscriptionManager.isPro {
                        ProBadge(isCompact: true)
                    }
                }
                Spacer()
                if dnsService.isDNSActive {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 7, height: 7)
                        Text("Active".loc)
                            .font(.caption2)
                            .bold()
                            .foregroundStyle(Color.green)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.green.opacity(0.15))
                    .clipShape(.capsule)
                } else if dnsService.isConfigured {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Design.Colors.gold)
                            .frame(width: 7, height: 7)
                        Text("Activate in iOS".loc)
                            .font(.caption2)
                            .bold()
                            .foregroundStyle(Design.Colors.gold)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Design.Colors.gold.opacity(0.15))
                    .clipShape(.capsule)
                } else {
                    Text("525,000 Sites".loc)
                        .font(.caption2)
                        .bold()
                        .foregroundStyle(Design.Colors.gold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Design.Colors.gold.opacity(0.15))
                        .clipShape(.capsule)
                }
            }

            if dnsService.isDNSActive {
                Text("**Network-wide protected:** Over 525,000 gambling websites blocked in Safari, Chrome & all apps — with zero battery or data loss.".loc)
                    .font(.caption)
                    .foregroundStyle(Design.Colors.textSecondary)
                    .lineSpacing(2)
            } else {
                Text("Blocks **over 525,000 gambling domains** worldwide at network level — in Safari, Google Chrome, Firefox, and all apps. **100% without Safari extensions**.".loc)
                    .font(.caption)
                    .foregroundStyle(Design.Colors.textSecondary)
                    .lineSpacing(2)

                // Quick navigation guide for iOS Settings
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                            .font(.caption2)
                            .foregroundStyle(Design.Colors.gold)
                        Text("Path in iOS Settings:".loc)
                            .font(.caption2)
                            .bold()
                            .foregroundStyle(Design.Colors.gold)
                    }
                    Text("Tap **‹ Back** in top left (out of app menu) → **General** → **VPN & Device Management** → **DNS**.".loc)
                        .font(.caption2)
                        .foregroundStyle(Design.Colors.ivory)
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.06))
                .clipShape(.rect(cornerRadius: Design.Radius.sm))
            }

            HStack(spacing: Design.Spacing.sm) {
                Button {
                    isShowingDNSSheet = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: dnsService.isDNSActive ? "shield.fill" : "list.bullet.rectangle")
                        Text(dnsService.isDNSActive ? "DNS Details".loc : "Instructions".loc)
                    }
                    .font(.caption)
                    .bold()
                    .foregroundStyle(Design.Colors.gold)
                    .frame(maxWidth: .infinity)
                    .frame(height: 38)
                    .background(Design.Colors.gold.opacity(0.12))
                    .clipShape(.rect(cornerRadius: Design.Radius.sm))
                }

                if !dnsService.isDNSActive {
                    Button {
                        if !subscriptionManager.isPro {
                            isShowingPaywall = true
                        } else {
                            Task {
                                _ = await dnsService.activateDNS()
                            }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "bolt.fill")
                            Text("Activate Now".loc)
                        }
                        .font(.caption)
                        .bold()
                        .foregroundStyle(Color.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 38)
                        .background(Design.Colors.gold)
                        .clipShape(.rect(cornerRadius: Design.Radius.sm))
                    }
                }
            }
            .padding(.top, 2)
        }
        .sereneCardStyle(padding: Design.Spacing.md)
    }

    // MARK: - Location Zone Radar Card

    private var zoneRadarCard: some View {
        NavigationLink(destination: ZoneRadarView()) {
            HStack(spacing: Design.Spacing.md) {
                ZStack {
                    Circle()
                        .fill(Design.Colors.primary.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: "location.north.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Design.Colors.primary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text("Danger Zone Radar".loc)
                            .font(.subheadline)
                            .bold()
                            .foregroundStyle(Color.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        if !subscriptionManager.isPro {
                            ProBadge(isCompact: true)
                        }
                    }
                    Text("Automatic geofence protection with dwell-time filter".loc)
                        .font(.caption2)
                        .foregroundStyle(Design.Colors.textSecondary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(Design.Colors.textTertiary)
            }
            .sereneCardStyle(padding: Design.Spacing.md)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Privacy Guarantee Card

    private var privacyGuaranteeCard: some View {
        HStack(spacing: Design.Spacing.md) {
            ZStack {
                Circle()
                    .fill(Design.Colors.gold.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: "lock.shield.fill")
                    .font(.title3)
                    .foregroundStyle(Design.Colors.gold)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("100% Secure & Private".loc)
                    .font(.subheadline)
                    .bold()
                    .foregroundStyle(Color.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text("Filtering is performed strictly locally on your iPhone. No personal data is transmitted or stored.".loc)
                    .font(.caption2)
                    .foregroundStyle(Design.Colors.textSecondary)
                    .lineSpacing(2)
            }

            Spacer()
        }
        .sereneCardStyle(padding: Design.Spacing.md)
    }

    // MARK: - Domain List Sheet

    private var filteredDefaultDomains: [String] {
        if domainSearchText.isEmpty {
            return shieldManager.defaultGamblingDomains
        } else {
            return shieldManager.defaultGamblingDomains.filter { $0.localizedCaseInsensitiveContains(domainSearchText) }
        }
    }

    private var filteredCustomDomains: [String] {
        if domainSearchText.isEmpty {
            return shieldManager.customBlockedDomains
        } else {
            return shieldManager.customBlockedDomains.filter { $0.localizedCaseInsensitiveContains(domainSearchText) }
        }
    }

    private var domainListSheet: some View {
        NavigationStack {
            ZStack {
                FlutedGlassBackgroundView()

                List {
                Section {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Region: %@".loc(shieldManager.currentCountry.name))
                                .font(.subheadline)
                                .bold()
                            Text("Top 25 standard blocked websites".loc)
                                .font(.caption2)
                                .foregroundStyle(Design.Colors.textSecondary)
                        }
                        Spacer()
                        Picker("Country".loc, selection: Binding(
                            get: { shieldManager.currentCountryCode },
                            set: { shieldManager.setCountry($0) }
                        )) {
                            ForEach(CountryBlocklistCatalog.prioritizedCountries(for: AppPreferences.shared.languageCode)) { country in
                                Text(country.name.loc).tag(country.code)
                            }
                        }
                        .tint(Design.Colors.primary)
                    }
                    .padding(.vertical, 4)
                }

                Section("Top 25 in %@ (%d)".loc(shieldManager.currentCountry.name, filteredDefaultDomains.count)) {
                    ForEach(filteredDefaultDomains, id: \.self) { domain in
                        HStack {
                            Image(systemName: "safari.fill")
                                .foregroundStyle(Design.Colors.primary)
                            Text(domain)
                                .font(.body)
                            Spacer()
                            Image(systemName: "checkmark.shield.fill")
                                .foregroundStyle(Design.Colors.gold)
                        }
                    }
                }

                if !shieldManager.customBlockedDomains.isEmpty {
                    Section("Custom Domains (%d)".loc(filteredCustomDomains.count)) {
                        ForEach(filteredCustomDomains, id: \.self) { domain in
                            HStack {
                                Image(systemName: "globe")
                                    .foregroundStyle(Design.Colors.primary)
                                Text(domain)
                                    .font(.body)
                                Spacer()
                                Button(role: .destructive) {
                                    shieldManager.removeCustomDomain(domain)
                                } label: {
                                    Image(systemName: "trash")
                                        .foregroundStyle(.red)
                                }
                            }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(.clear)
            .searchable(text: $domainSearchText, prompt: Text("Search domain...".loc))
            .scrollIndicators(.hidden)
        }
        .navigationTitle("Blocked Domains".loc)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done".loc) { isShowingDomainList = false }
                }
            }
        }
        .scrollIndicators(.hidden)
    }

    // MARK: - Actions

    private func handleShieldToggle(_ shield: ShieldManager) {
        if shield.isShieldActive {
            // Open Mindful Friction Gate: User can breathe and then legitimately deactivate
            isShowingFrictionGate = true
        } else {
            Task {
                if !shieldManager.isAuthorized {
                    let granted = await shieldManager.requestAuthorization()
                    if granted {
                        shieldManager.isShieldActive = true
                    }
                } else {
                    shieldManager.isShieldActive = true
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ShieldDashboardView()
    }
    .environment(ShieldManager())
}
