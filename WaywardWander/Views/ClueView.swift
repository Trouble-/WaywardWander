import SwiftUI

struct ClueView: View {
    let clue: Clue
    let clueNumber: Int
    let totalClues: Int
    @ObservedObject var locationManager: LocationManager
    @Binding var hintsRevealed: Int
    let hasArrivedAtClue: Bool
    let onArrival: () -> Void
    let onMarkArrived: () -> Void
    let onBackToIntro: () -> Void
    let onPreviousClue: (() -> Void)?

    @State private var hasArrived: Bool = false
    @State private var showingSkipConfirmation: Bool = false
    @State private var showingSkipPassword: Bool = false
    @State private var skipPasswordEntry: String = ""
    @State private var showingWrongPassword: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onBackToIntro) {
                    HStack(spacing: 4) {
                        Image(systemName: "house")
                        Text("Home")
                    }
                    .font(.subheadline)
                    .foregroundColor(AppTheme.accent)
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
                        .foregroundColor(AppTheme.accent)

                    Text(clue.initialClue)
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
                .background(AppTheme.accentLight)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppTheme.accentBorder, lineWidth: 2)
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
                        .background(AppTheme.infoLight)
                        .foregroundColor(AppTheme.info)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppTheme.infoBorder, lineWidth: 2)
                        )
                    }
                }

                if hasArrived {
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(AppTheme.success)

                        Text("You've arrived!")
                            .font(.headline)
                            .foregroundColor(AppTheme.success)

                        Button(action: onArrival) {
                            Text("See what's here")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppTheme.success)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                    .padding()
                    .background(AppTheme.successLight)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppTheme.successBorder, lineWidth: 2)
                    )
                }

                #if DEBUG
                if !hasArrived {
                    Button(action: {
                        withAnimation {
                            hasArrived = true
                        }
                        onMarkArrived()
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

                // Stuck? help button (only if enabled and not yet arrived)
                if !hasArrived && clue.skipOption != .disabled {
                    Button(action: handleStuckButton) {
                        Text("Stuck?")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                }

                Spacer(minLength: 50)
            }
                .padding()
            }
            .onAppear {
                locationManager.targetLocation = clue.clLocation
                if hasArrivedAtClue {
                    hasArrived = true
                } else {
                    // Check if already within arrival radius when view appears
                    checkArrival()
                }
            }
            .onChange(of: locationManager.distanceToTarget) { _, _ in
                checkArrival()
            }
            .alert("Skip this clue?", isPresented: $showingSkipConfirmation) {
                Button("Skip", role: .destructive) {
                    performSkip()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to skip ahead? This will mark this clue as complete.")
            }
            .alert("Enter Password", isPresented: $showingSkipPassword) {
                SecureField("Password", text: $skipPasswordEntry)
                Button("Submit") {
                    checkSkipPassword()
                }
                Button("Cancel", role: .cancel) {
                    skipPasswordEntry = ""
                }
            } message: {
                Text("Enter the password to skip this clue.")
            }
            .alert("Wrong Password", isPresented: $showingWrongPassword) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("The password you entered is incorrect.")
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
                        .foregroundColor(AppTheme.accent)
                    Text(hint.content ?? "")
                        .font(.body)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.accentLight)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppTheme.accentBorder, lineWidth: 2)
                )

            case .compass:
                VStack(spacing: 8) {
                    Text("Follow the arrow")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    CompassView(rotation: locationManager.arrowRotation())
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(AppTheme.accentLight)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppTheme.accentBorder, lineWidth: 2)
                )

            case .distance:
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(AppTheme.info)
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
                .background(AppTheme.infoLight)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppTheme.infoBorder, lineWidth: 2)
                )
            }
        }
    }

    private func checkArrival() {
        guard !hasArrived else { return }
        if let distance = locationManager.distanceToTarget, distance <= clue.arrivalRadius {
            withAnimation {
                hasArrived = true
            }
            onMarkArrived()
        }
    }

    private func handleStuckButton() {
        switch clue.skipOption {
        case .disabled:
            break // Should not happen since button is hidden
        case .allowed:
            showingSkipConfirmation = true
        case .password:
            showingSkipPassword = true
        }
    }

    private func performSkip() {
        withAnimation {
            hasArrived = true
        }
        onMarkArrived()
    }

    private func checkSkipPassword() {
        if case .password(let correctPassword) = clue.skipOption {
            if skipPasswordEntry.lowercased() == correctPassword.lowercased() {
                skipPasswordEntry = ""
                performSkip()
            } else {
                skipPasswordEntry = ""
                showingWrongPassword = true
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
