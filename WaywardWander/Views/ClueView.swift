import SwiftUI

struct ClueView: View {
    let clue: Clue
    let clueNumber: Int
    let totalClues: Int
    @ObservedObject var locationManager: LocationManager
    let onArrival: () -> Void

    @State private var hintsRevealed: Int = 0
    @State private var hasArrived: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Clue \(clueNumber) of \(totalClues)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                VStack(spacing: 16) {
                    Image(systemName: "scroll")
                        .font(.system(size: 40))
                        .foregroundColor(.orange)

                    Text(clue.initialClue)
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(16)

                ForEach(0..<hintsRevealed, id: \.self) { index in
                    if index < clue.hints.count {
                        hintView(for: clue.hints[index])
                    }
                }

                if hintsRevealed < clue.hints.count {
                    Button(action: revealNextHint) {
                        HStack {
                            Image(systemName: "lightbulb")
                            Text("Get Hint (\(clue.hints.count - hintsRevealed) remaining)")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(12)
                    }
                }

                if hasArrived {
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.green)

                        Text("You've arrived!")
                            .font(.headline)
                            .foregroundColor(.green)

                        Button(action: onArrival) {
                            Text("See what's here")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(16)
                }

                Spacer(minLength: 50)
            }
            .padding()
        }
        .onAppear {
            locationManager.targetLocation = clue.clLocation
        }
        .onChange(of: locationManager.distanceToTarget) { _, distance in
            if let distance = distance, distance <= clue.arrivalRadius {
                withAnimation {
                    hasArrived = true
                }
            }
        }
    }

    @ViewBuilder
    private func hintView(for hint: Hint) -> some View {
        VStack(spacing: 12) {
            switch hint.type {
            case .text:
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.yellow)
                    Text(hint.content ?? "")
                        .font(.body)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.yellow.opacity(0.1))
                .cornerRadius(12)

            case .compass:
                VStack(spacing: 8) {
                    Text("Compass")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    CompassView(rotation: locationManager.arrowRotation())
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(12)

            case .distance:
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(.blue)
                    if let distance = locationManager.distanceToTarget {
                        Text(formatDistance(distance))
                            .font(.title2)
                            .fontWeight(.semibold)
                    } else {
                        Text("Calculating...")
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
            }
        }
    }

    private func revealNextHint() {
        withAnimation {
            hintsRevealed += 1
        }
    }

    private func formatDistance(_ meters: Double) -> String {
        if meters >= 1000 {
            return String(format: "%.1f km away", meters / 1000)
        } else {
            return String(format: "%.0f m away", meters)
        }
    }
}
