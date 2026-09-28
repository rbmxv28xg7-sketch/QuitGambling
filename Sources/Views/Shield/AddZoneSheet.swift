import SwiftUI
import SwiftData
import MapKit

/// Sheet to configure and save a new geofenced trigger zone with custom location search and map picker.
struct AddZoneSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var initialCoordinate: CLLocationCoordinate2D? = nil
    private var locationShieldManager = LocationShieldManager()

    @State private var name: String = ""
    @State private var radiusMeters: Double = 150.0 // approx 500 ft
    @State private var dwellTimeMinutes: Int = 3
    @State private var isSilentShieldOnly: Bool = true
    @State private var selectedCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
    @State private var mapPosition: MapCameraPosition = .camera(MapCamera(centerCoordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), distance: 2500))

    // Location search
    @State private var searchQuery: String = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var isSearching: Bool = false

    private var radiusFeet: Int {
        Int(radiusMeters * 3.28084)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                FlutedGlassBackgroundView()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: Design.Spacing.lg) {
                        Text("Create New Zone")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(Color.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, Design.Spacing.xs)

                        // 1. Search Location & Address
                        zoneSection("Select Place or Address") {
                            VStack(spacing: Design.Spacing.sm) {
                                HStack(spacing: 8) {
                                    Image(systemName: "magnifyingglass")
                                        .font(.subheadline)
                                        .foregroundStyle(Design.Colors.textSecondary)

                                    TextField("Search address, arcade, casino...", text: $searchQuery)
                                        .foregroundStyle(Design.Colors.textPrimary)
                                        .autocorrectionDisabled()
                                        .onSubmit {
                                            performSearch()
                                        }

                                    if !searchQuery.isEmpty {
                                        Button {
                                            searchQuery = ""
                                            searchResults = []
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundStyle(Design.Colors.textTertiary)
                                        }
                                        .buttonStyle(.plain)
                                    }

                                    Button {
                                        performSearch()
                                    } label: {
                                        Text("Search")
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(Color.black)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .background(Design.Colors.gold)
                                            .clipShape(Capsule())
                                    }
                                    .buttonStyle(.plain)
                                }

                                if isSearching {
                                    ProgressView()
                                        .tint(Design.Colors.gold)
                                        .padding(.vertical, 4)
                                }

                                // Search Results Dropdown
                                if !searchResults.isEmpty {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Divider().background(Color.white.opacity(0.12))

                                        ForEach(searchResults.prefix(4), id: \.self) { item in
                                            Button {
                                                selectMapItem(item)
                                            } label: {
                                                HStack(spacing: 10) {
                                                    Image(systemName: "mappin.circle.fill")
                                                        .foregroundStyle(Design.Colors.primary)
                                                        .font(.headline)

                                                    VStack(alignment: .leading, spacing: 2) {
                                                        Text(item.name ?? "Place")
                                                            .font(.subheadline.weight(.medium))
                                                            .foregroundStyle(Color.white)
                                                            .lineLimit(1)
                                                        Text(item.placemark.title ?? "")
                                                            .font(.caption2)
                                                            .foregroundStyle(Design.Colors.textSecondary)
                                                            .lineLimit(1)
                                                    }
                                                    Spacer()
                                                }
                                                .padding(.vertical, 6)
                                            }
                                            .buttonStyle(.plain)

                                            if item != searchResults.prefix(4).last {
                                                Divider().background(Color.white.opacity(0.08))
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // 2. Interactive Map Picker
                        zoneSection("Place on Map") {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Tap map to align the zone.")
                                        .font(.caption2)
                                        .foregroundStyle(Design.Colors.textSecondary)
                                        .lineLimit(1)

                                    Spacer()

                                    Button {
                                        centerOnCurrentLocation()
                                    } label: {
                                        HStack(spacing: 4) {
                                            Image(systemName: "location.fill")
                                            Text("My Location")
                                        }
                                        .font(.caption2.weight(.semibold))
                                        .foregroundStyle(Design.Colors.primary)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Design.Colors.primary.opacity(0.12))
                                        .clipShape(Capsule())
                                    }
                                    .buttonStyle(.plain)
                                }

                                MapReader { proxy in
                                    Map(position: $mapPosition) {
                                        Annotation(name.isEmpty ? "Danger Zone" : name, coordinate: selectedCoordinate) {
                                            ZStack {
                                                Circle()
                                                    .fill(Design.Colors.sos)
                                                    .frame(width: 32, height: 32)
                                                    .shadow(color: Design.Colors.sos.opacity(0.6), radius: 6)
                                                Image(systemName: "shield.slash.fill")
                                                    .font(.caption)
                                                    .foregroundStyle(Color.white)
                                            }
                                        }

                                        MapCircle(center: selectedCoordinate, radius: radiusMeters)
                                            .foregroundStyle(Design.Colors.primary.opacity(0.22))
                                            .stroke(Design.Colors.primary, lineWidth: 2)
                                    }
                                    .frame(height: 200)
                                    .clipShape(RoundedRectangle(cornerRadius: Design.Radius.md))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: Design.Radius.md)
                                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                    )
                                    .onTapGesture { screenPoint in
                                        if let coord = proxy.convert(screenPoint, from: .local) {
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                selectedCoordinate = coord
                                            }
                                            reverseGeocode(coord)
                                        }
                                    }
                                }
                            }
                        }

                        // 3. Name & Description
                        zoneSection("Zone Name") {
                            TextField("e.g. Downtown Casino, Arcade", text: $name)
                                .foregroundStyle(Design.Colors.textPrimary)
                        }

                        // 4. Radius (Feet & Meters for USA standards)
                        zoneSection("Shield Radius") {
                            VStack(alignment: .leading, spacing: Design.Spacing.xs) {
                                HStack {
                                    Text("Radius:")
                                        .font(.subheadline)
                                        .foregroundStyle(Design.Colors.textSecondary)
                                    Spacer()
                                    Text("\(radiusFeet) ft (\(Int(radiusMeters)) m)")
                                        .font(.subheadline)
                                        .bold()
                                        .foregroundStyle(Design.Colors.gold)
                                        .lineLimit(1)
                                }
                                Slider(value: $radiusMeters, in: 45...450, step: 15)
                                    .tint(Design.Colors.primary)
                            }
                        }

                        // 5. Dwell Time
                        zoneSection("Dwell-Time Filter") {
                            VStack(alignment: .leading, spacing: Design.Spacing.xs) {
                                HStack {
                                    Text("Activation after:")
                                        .font(.subheadline)
                                        .foregroundStyle(Design.Colors.textSecondary)
                                    Spacer()
                                    Text("\(dwellTimeMinutes) Minutes")
                                        .font(.subheadline)
                                        .bold()
                                        .foregroundStyle(Design.Colors.gold)
                                        .lineLimit(1)
                                }
                                Slider(value: Binding(
                                    get: { Double(dwellTimeMinutes) },
                                    set: { dwellTimeMinutes = Int($0) }
                                ), in: 1...5, step: 1)
                                    .tint(Design.Colors.primary)

                                Text("No alarm when passing by by car or transit.")
                                    .font(.caption2)
                                    .foregroundStyle(Design.Colors.textSecondary)
                                    .lineLimit(1)
                            }
                        }

                        // 6. Action Type
                        zoneSection("Response Type") {
                            Toggle("Silent Shield (Recommended)", isOn: $isSilentShieldOnly)
                                .tint(Design.Colors.toggleTint)
                                .foregroundStyle(Design.Colors.textPrimary)

                            Text(isSilentShieldOnly
                                 ? "Silent background activation of the app and web shield."
                                 : "Discreet mindful impulse to take a breath.")
                                .font(.caption2)
                                .foregroundStyle(Design.Colors.textSecondary)
                                .lineLimit(1)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, Design.Spacing.md)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Design.Colors.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveZone()
                    }
                    .bold()
                    .foregroundStyle(Design.Colors.gold)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                if let coord = initialCoordinate {
                    selectedCoordinate = coord
                    mapPosition = .camera(MapCamera(centerCoordinate: coord, distance: 2500))
                } else {
                    centerOnCurrentLocation()
                }
            }
        }
        .dismissKeyboardOnTap()
    }

    private func centerOnCurrentLocation() {
        SensoryFeedbackService.shared.selectionClick()
        Task {
            if let loc = await locationShieldManager.requestAndFetchLocation() {
                withAnimation(.easeInOut(duration: 0.6)) {
                    selectedCoordinate = loc.coordinate
                    mapPosition = .camera(MapCamera(centerCoordinate: loc.coordinate, distance: 2000))
                }
                reverseGeocode(loc.coordinate)
            }
        }
    }

    private func performSearch() {
        let trimmed = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        isSearching = true
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = trimmed
        request.region = MKCoordinateRegion(
            center: selectedCoordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        )

        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            isSearching = false
            searchResults = response?.mapItems ?? []
            if let first = searchResults.first {
                selectMapItem(first)
            }
        }
    }

    private func selectMapItem(_ item: MKMapItem) {
        let coord = item.placemark.coordinate
        selectedCoordinate = coord
        mapPosition = .camera(MapCamera(centerCoordinate: coord, distance: 2000))
        if name.isEmpty || name == "Danger Zone" {
            name = item.name ?? "Danger Zone"
        }
        searchResults = []
    }

    private func reverseGeocode(_ coord: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, _ in
            if let placemark = placemarks?.first, name.isEmpty {
                name = placemark.name ?? placemark.thoroughfare ?? "Danger Zone"
            }
        }
    }

    private func saveZone() {
        let zone = TriggerZone(
            name: name.trimmingCharacters(in: .whitespaces),
            latitude: selectedCoordinate.latitude,
            longitude: selectedCoordinate.longitude,
            radiusMeters: radiusMeters,
            dwellTimeMinutes: dwellTimeMinutes,
            isSilentShieldOnly: isSilentShieldOnly,
            isActive: true
        )
        modelContext.insert(zone)
        try? modelContext.save()
        dismiss()
    }

    private func zoneSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: Design.Spacing.xs) {
            Text(title.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundStyle(Design.Colors.gold)
                .padding(.leading, 8)
                .lineLimit(1)

            VStack(spacing: Design.Spacing.md) {
                content()
            }
            .liquidGlass(cornerRadius: Design.Radius.card, padding: Design.Spacing.md)
        }
    }
}
