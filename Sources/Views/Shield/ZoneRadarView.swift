import SwiftUI
import SwiftData
import MapKit

/// Serene MapKit-based view managing physical trigger zones with subtle radius overlays.
struct ZoneRadarView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @State private var locationShieldManager = LocationShieldManager()
    @State private var isShowingAddSheet = false
    @State private var showingPaywall = false

    @Query(sort: \TriggerZone.createdAt, order: .reverse) private var zones: [TriggerZone]

    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var isLocating: Bool = false
    @State private var showLocationDeniedAlert: Bool = false
    @State private var hasInitiallyCentered: Bool = false

    var body: some View {
        ZStack {
            FlutedGlassBackgroundView()

            ScrollView(showsIndicators: false) {
                VStack(spacing: Design.Spacing.lg) {
                    // Info Banner
                    psychologyBanner

                    // Interactive Map Preview
                    mapContainer
                        .frame(height: 280)
                        .clipShape(.rect(cornerRadius: Design.Radius.card))
                        .overlay(
                            RoundedRectangle(cornerRadius: Design.Radius.card)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                        .padding(.horizontal, Design.Spacing.md)

                    // Add Zone Action Button
                    VStack(spacing: 6) {
                        Button {
                            if !subscriptionManager.isPro && zones.count >= 1 {
                                showingPaywall = true
                            } else {
                                isShowingAddSheet = true
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Label("Add Danger Zone", systemImage: "plus.circle.fill")
                                if !subscriptionManager.isPro && zones.count >= 1 {
                                    ProBadge(isCompact: true)
                                }
                            }
                            .font(.subheadline)
                            .bold()
                            .foregroundStyle(Design.Colors.textOnPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Design.Colors.primary)
                            .clipShape(.rect(cornerRadius: Design.Radius.md))
                        }

                        if !subscriptionManager.isPro {
                            Text("\(zones.count) of 1 free danger zone used • Pro enables unlimited zones")
                                .font(.caption2)
                                .foregroundStyle(Design.Colors.textTertiary)
                        }
                    }
                    .padding(.horizontal, Design.Spacing.md)

                    // List of Configured Zones
                    zonesSection
                }
                .padding(.vertical, Design.Spacing.md)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Zone Radar")
        .sheet(isPresented: $isShowingAddSheet) {
            AddZoneSheet(initialCoordinate: locationShieldManager.currentLocation?.coordinate)
                .scrollIndicators(.hidden)
        }
        .fullScreenCover(isPresented: $showingPaywall) {
            PaywallView()
        }
        .scrollIndicators(.hidden)
        .alert("Location Access Required", isPresented: $showLocationDeniedAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please allow Quit Gambling access to your location in iOS Settings to display danger zones on the radar and center your current location.")
        }
        .onAppear {
            locationShieldManager.requestPermissions()
            locationShieldManager.syncZones(zones)
            if !hasInitiallyCentered {
                Task {
                    if let loc = await locationShieldManager.requestAndFetchLocation() {
                        hasInitiallyCentered = true
                        withAnimation(.easeInOut(duration: 0.8)) {
                            position = .camera(MapCamera(centerCoordinate: loc.coordinate, distance: 2000))
                        }
                    }
                }
            }
        }
        .onChange(of: locationShieldManager.currentLocation) { _, newLoc in
            if let newLoc, !hasInitiallyCentered {
                hasInitiallyCentered = true
                withAnimation(.easeInOut(duration: 0.8)) {
                    position = .camera(MapCamera(centerCoordinate: newLoc.coordinate, distance: 2000))
                }
            }
        }
        .onChange(of: zones) { _, newZones in
            locationShieldManager.syncZones(newZones)
        }
    }

    // MARK: - Psychology Banner

    private var psychologyBanner: some View {
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
                Text("Subtle Location Shield")
                    .font(.subheadline)
                    .bold()
                    .foregroundStyle(Color.white)
                Text("Dwell-time filter prevents false alarms when passing by.")
                    .font(.caption2)
                    .foregroundStyle(Design.Colors.textSecondary)
                    .lineLimit(2)
            }

            Spacer()
        }
        .sereneCardStyle(padding: Design.Spacing.md)
        .padding(.horizontal, Design.Spacing.md)
    }

    // MARK: - Map

    private var mapContainer: some View {
        ZStack(alignment: .topTrailing) {
            Map(position: $position) {
                UserAnnotation()

                ForEach(zones) { zone in
                    let coord = CLLocationCoordinate2D(latitude: zone.latitude, longitude: zone.longitude)

                    Annotation(zone.name, coordinate: coord) {
                        ZStack {
                            Circle()
                                .fill(zone.isActive ? Design.Colors.primary : Color.gray)
                                .frame(width: 28, height: 28)
                            Image(systemName: "shield.fill")
                                .font(.caption2)
                                .foregroundStyle(zone.isActive ? Design.Colors.textOnPrimary : Color.white)
                        }
                    }

                    MapCircle(center: coord, radius: zone.radiusMeters)
                        .foregroundStyle(zone.isActive ? Design.Colors.primary.opacity(0.2) : Color.gray.opacity(0.15))
                        .stroke(zone.isActive ? Design.Colors.primary : Color.gray, lineWidth: 1.5)
                }
            }
            .mapControls {
                MapCompass()
                MapScaleView()
            }

            // Dedicated, rock-solid location centering button in the top-right
            Button {
                centerOnUserLocation()
            } label: {
                ZStack {
                    Circle()
                        .fill(Color(white: 0.12).opacity(0.85))
                        .background(.ultraThinMaterial, in: Circle())
                        .frame(width: 44, height: 44)

                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        .frame(width: 44, height: 44)

                    if isLocating {
                        ProgressView()
                            .tint(Design.Colors.primary)
                    } else {
                        Image(systemName: "location.fill")
                            .font(.system(size: 19, weight: .semibold))
                            .foregroundStyle(Design.Colors.primary)
                    }
                }
                .shadow(color: Color.black.opacity(0.4), radius: 6, y: 2)
            }
            .buttonStyle(.plain)
            .padding(10)
        }
    }

    private func centerOnUserLocation() {
        SensoryFeedbackService.shared.selectionClick()

        if locationShieldManager.authorizationStatus == .denied || locationShieldManager.authorizationStatus == .restricted {
            showLocationDeniedAlert = true
            return
        }

        isLocating = true
        Task {
            if let loc = await locationShieldManager.requestAndFetchLocation() {
                withAnimation(.easeInOut(duration: 0.8)) {
                    position = .camera(MapCamera(centerCoordinate: loc.coordinate, distance: 1500))
                }
            } else if let loc = locationShieldManager.currentLocation {
                withAnimation(.easeInOut(duration: 0.8)) {
                    position = .camera(MapCamera(centerCoordinate: loc.coordinate, distance: 1500))
                }
            } else {
                withAnimation(.easeInOut(duration: 0.8)) {
                    position = .userLocation(fallback: .automatic)
                }
            }
            isLocating = false
        }
    }

    // MARK: - Zones List

    private var zonesSection: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.sm) {
            Text("Protected Zones (\(zones.count))")
                .font(.headline)
                .foregroundStyle(Color.white)
                .padding(.horizontal, Design.Spacing.md)

            if zones.isEmpty {
                VStack(spacing: Design.Spacing.sm) {
                    Image(systemName: "mappin.slash.circle")
                        .font(.system(size: 40))
                        .foregroundStyle(Design.Colors.primary.opacity(0.6))
                    Text("No Zones Configured Yet")
                        .font(.subheadline)
                        .bold()
                        .foregroundStyle(Color.white)
                    Text("Pin places (e.g. casinos on your commute) to activate automatic geofenced protection.")
                        .font(.caption2)
                        .foregroundStyle(Design.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .sereneCardStyle(padding: Design.Spacing.lg)
                .padding(.horizontal, Design.Spacing.md)
            } else {
                ForEach(zones) { zone in
                    zoneRow(zone)
                }
                .padding(.horizontal, Design.Spacing.md)
            }
        }
    }

    private func zoneRow(_ zone: TriggerZone) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(zone.isActive ? Design.Colors.primary.opacity(0.16) : Color.gray.opacity(0.12))
                        .frame(width: 36, height: 36)
                    Image(systemName: zone.isActive ? "shield.fill" : "shield.slash")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(zone.isActive ? Design.Colors.primary : Design.Colors.textTertiary)
                }

                Text(zone.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.white)
                    .lineLimit(1)

                Spacer(minLength: 8)

                Toggle("", isOn: Binding(
                    get: { zone.isActive },
                    set: { newValue in
                        zone.isActive = newValue
                        try? modelContext.save()
                        locationShieldManager.syncZones(zones)
                    }
                ))
                .labelsHidden()
                .tint(Design.Colors.toggleTint)

                Button(role: .destructive) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        modelContext.delete(zone)
                        try? modelContext.save()
                        locationShieldManager.syncZones(zones)
                    }
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 13))
                        .foregroundStyle(Design.Colors.textTertiary.opacity(0.8))
                        .padding(.vertical, 6)
                        .padding(.horizontal, 4)
                }
                .buttonStyle(.plain)
            }

            // Dedicated, full-width subtitle row that never wraps or hyphenates
            HStack(spacing: 8) {
                HStack(spacing: 3) {
                    Image(systemName: "location.circle")
                        .font(.system(size: 10))
                    Text("\(Int(zone.radiusMeters * 3.28084)) ft (\(Int(zone.radiusMeters))m)")
                }

                Text("•")
                    .foregroundStyle(Color.white.opacity(0.2))

                HStack(spacing: 3) {
                    Image(systemName: "clock")
                        .font(.system(size: 10))
                    Text("\(zone.dwellTimeMinutes) min dwell")
                }

                Text("•")
                    .foregroundStyle(Color.white.opacity(0.2))

                HStack(spacing: 3) {
                    Image(systemName: zone.isSilentShieldOnly ? "speaker.slash" : "bell")
                        .font(.system(size: 10))
                    Text(zone.isSilentShieldOnly ? "Silent" : "Prompt")
                }
            }
            .font(.caption2)
            .foregroundStyle(Design.Colors.textSecondary)
            .lineLimit(1)
            .minimumScaleFactor(0.85)
            .padding(.leading, 48)
        }
        .sereneCardStyle(padding: Design.Spacing.md)
    }
}

#Preview {
    NavigationStack {
        ZoneRadarView()
    }
    .modelContainer(for: TriggerZone.self, inMemory: true)
}
