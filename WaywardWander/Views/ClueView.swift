import SwiftUI

struct ClueView: View {
    let clue: Clue
    let clueNumber: Int
    let totalClues: Int
    @ObservedObject var locationManager: LocationManager
    @Binding var hintsRevealed: Int
    let onArrival: () -> Void
    let onBackToIntro: () -> Void
    let onPreviousClue: (() -> Void)?

    @State private var hasArrived: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onBackToIntro) {
                    HStack(spacing: 4) {
                        Image(systemName: "house")
                        Text("Start")
                    }
                    .font(.subheadline)
                    .foregroundColor(.orange)
                }

                Spacer()

                if let onPrevious = onPreviousClue {
                    Button(action: onPrevious) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Previous")
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(.systemBackground))

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
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.orange.opacity(0.5), lineWidth: 2)
                )

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
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue.opacity(0.5), lineWidth: 2)
                        )
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
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.green.opacity(0.5), lineWidth: 2)
                    )
                }

                #if DEBUG
                if !hasArrived {
                    Button(action: {
                        withAnimation {
                            hasArrived = true
                        }
                    }) {
                        HStack {
                            Image(systemName: "hammer.fill")
                            Text("Dev: Simulate Arrival")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple.opacity(0.1))
                        .foregroundColor(.purple)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.purple.opacity(0.5), lineWidth: 2)
                        )
                    }
                }
                #endif

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
        .withAppBackground()
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
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.yellow.opacity(0.5), lineWidth: 2)
                )

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
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.orange.opacity(0.5), lineWidth: 2)
                )

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
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue.opacity(0.5), lineWidth: 2)
                )
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
