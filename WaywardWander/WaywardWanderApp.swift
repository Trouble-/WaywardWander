import SwiftUI

@main
struct WaywardWanderApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

enum GameState {
    case intro
    case playing
    case reveal
    case passcode
    case victory
}

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()

    @State private var hunt: Hunt?
    @State private var gameState: GameState = .intro
    @State private var currentClueIndex: Int = 0

    var currentClue: Clue? {
        guard let hunt = hunt, currentClueIndex < hunt.clues.count else { return nil }
        return hunt.clues[currentClueIndex]
    }

    var isLastClue: Bool {
        guard let hunt = hunt else { return false }
        return currentClueIndex >= hunt.clues.count - 1
    }

    var body: some View {
        Group {
            if let hunt = hunt {
                switch gameState {
                case .intro:
                    HuntIntroView(hunt: hunt) {
                        locationManager.requestAuthorization()
                        gameState = .playing
                    }

                case .playing:
                    if let clue = currentClue {
                        ClueView(
                            clue: clue,
                            clueNumber: currentClueIndex + 1,
                            totalClues: hunt.clues.count,
                            locationManager: locationManager
                        ) {
                            gameState = .reveal
                        }
                    }

                case .reveal:
                    if let clue = currentClue {
                        RevealView(
                            reveal: clue.reveal,
                            clueNumber: currentClueIndex + 1,
                            isLastClue: isLastClue,
                            unlockType: clue.unlockNext
                        ) {
                            handleContinue()
                        }
                    }

                case .passcode:
                    if let clue = currentClue, let passcode = clue.passcode {
                        PasscodeView(expectedPasscode: passcode) {
                            advanceToNextClue()
                        }
                    }

                case .victory:
                    VictoryView(hunt: hunt) {
                        restartHunt()
                    }
                }
            } else {
                LoadingView()
            }
        }
        .onAppear {
            loadHunt()
        }
    }

    private func loadHunt() {
        hunt = Hunt.load(from: "sample_hunt")
    }

    private func handleContinue() {
        guard let clue = currentClue else { return }

        if isLastClue {
            gameState = .victory
        } else if clue.unlockNext == .passcode && clue.passcode != nil {
            gameState = .passcode
        } else {
            advanceToNextClue()
        }
    }

    private func advanceToNextClue() {
        currentClueIndex += 1
        gameState = .playing
    }

    private func restartHunt() {
        currentClueIndex = 0
        gameState = .intro
    }
}

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)

            Text("Loading hunt...")
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    ContentView()
}
