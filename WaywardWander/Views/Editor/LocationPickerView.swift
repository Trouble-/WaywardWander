import SwiftUI
import CoreLocation

struct LocationPickerView: View {
    @Binding var latitude: String
    @Binding var longitude: String
    @StateObject private var locationManager = LocationManager()
    @State private var isFetchingLocation = false

    var isValid: Bool {
        guard let lat = Double(latitude), let lng = Double(longitude) else {
            return false
        }
        return lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Location")
                .font(.headline)
                .foregroundColor(.primary)

            // Current location button
            Button(action: useCurrentLocation) {
                HStack {
                    if isFetchingLocation {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "location.fill")
                    }
                    Text(isFetchingLocation ? "Getting Location..." : "Use Current Location")
                }
                .font(.subheadline.weight(.medium))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(AppTheme.accent)
                .cornerRadius(8)
            }
            .disabled(isFetchingLocation)

            // Manual entry fields
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Latitude")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("-90 to 90", text: $latitude)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numbersAndPunctuation)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Longitude")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("-180 to 180", text: $longitude)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numbersAndPunctuation)
                }
            }

            // Validation indicator
            if !latitude.isEmpty || !longitude.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: isValid ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                        .foregroundColor(isValid ? AppTheme.success : .red)
                    Text(isValid ? "Valid coordinates" : "Invalid coordinates")
                        .font(.caption)
                        .foregroundColor(isValid ? AppTheme.success : .red)
                }
            }
        }
        .padding()
        .background(AppTheme.secondaryLight)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.secondaryBorder, lineWidth: 1)
        )
        .onAppear {
            locationManager.requestAuthorization()
        }
    }

    private func useCurrentLocation() {
        isFetchingLocation = true
        locationManager.startUpdating()

        // Give it a moment to get a location
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if let location = locationManager.currentLocation {
                latitude = String(format: "%.6f", location.coordinate.latitude)
                longitude = String(format: "%.6f", location.coordinate.longitude)
            }
            isFetchingLocation = false
            locationManager.stopUpdating()
        }
    }
}

#Preview {
    LocationPickerView(
        latitude: .constant("37.7749"),
        longitude: .constant("-122.4194")
    )
    .padding()
}
