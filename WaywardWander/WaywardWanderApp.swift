import SwiftUI

@main
struct WaywardWanderApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

enum GameState: String {
    case intro
    case playing
    case reveal
    case passcode
    case victory
}

struct EditorItem: Identifiable {
    let id = UUID()
    let hunt: EditableHunt
    let isNew: Bool
}

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var huntStore = HuntStore()

    @State private var selectedHunt: Hunt?
    @State private var gameState: GameState = .intro
    @State private var currentClueIndex: Int = 0
    @State private var hintsRevealed: Int = 0
    @State private var arrivedClues: Set<Int> = []
    @State private var unlockedClues: Set<Int> = []

    // Editor state
    @State private var editorItem: EditorItem?

    var currentClue: Clue? {
        guard let hunt = selectedHunt, currentClueIndex < hunt.clues.count else { return nil }
        return hunt.clues[currentClueIndex]
    }

    var isLastClue: Bool {
        guard let hunt = selectedHunt else { return false }
        return currentClueIndex >= hunt.clues.count - 1
    }

    var body: some View {
        Group {
            if let hunt = selectedHunt {
                huntView(hunt: hunt)
            } else {
                HomeView(
                    huntStore: huntStore,
                    onSelectHunt: { hunt in
                        selectHunt(hunt)
                    },
                    onCreateQuest: {
                        editorItem = EditorItem(hunt: EditableHunt.createNew(), isNew: true)
                    },
                    onEditQuest: { hunt in
                        editorItem = EditorItem(hunt: EditableHunt.from(hunt), isNew: false)
                    }
                )
            }
        }
        .sheet(item: $editorItem) { item in
            QuestEditorView(
                hunt: item.hunt,
                isNewQuest: item.isNew,
                huntStore: huntStore,
                onSave: {
                    editorItem = nil
                },
                onCancel: {
                    editorItem = nil
                }
            )
        }
        .onChange(of: currentClueIndex) { _, _ in
            saveProgress()
        }
        .onChange(of: gameState) { _, _ in
            saveProgress()
        }
        .onChange(of: hintsRevealed) { _, _ in
            saveProgress()
        }
        .onChange(of: arrivedClues) { _, _ in
            saveProgress()
        }
        .onChange(of: unlockedClues) { _, _ in
            saveProgress()
        }
    }

    @ViewBuilder
    private func huntView(hunt: Hunt) -> some View {
        switch gameState {
        case .intro:
            HuntIntroView(hunt: hunt, onStart: {
                locationManager.requestAuthorization()
                gameState = .playing
            }, onBackToHome: {
                selectedHunt = nil
            })

        case .playing:
            if let clue = currentClue {
                ClueView(
                    clue: clue,
                    clueNumber: currentClueIndex + 1,
                    totalClues: hunt.clues.count,
                    locationManager: locationManager,
                    hintsRevealed: $hintsRevealed,
                    hasArrivedAtClue: arrivedClues.contains(currentClueIndex),
                    onArrival: {
                        gameState = .reveal
                    },
                    onMarkArrived: {
                        arrivedClues.insert(currentClueIndex)
                    },
                    onBackToIntro: {
                        goToHome()
                    },
                    onPreviousClue: {
                        if currentClueIndex > 0 {
                            goToPreviousClue()
                        } else {
                            gameState = .intro
                        }
                    }
                )
            }

        case .reveal:
            if let clue = currentClue {
                RevealView(
                    reveal: clue.reveal,
                    clueNumber: currentClueIndex + 1,
                    isLastClue: isLastClue,
                    unlockType: clue.unlockNext,
                    huntId: hunt.id,
                    onContinue: {
                        handleContinue()
                    },
                    onBackToIntro: {
                        goToHome()
                    },
                    onBackToClue: {
                        gameState = .playing
                    }
                )
            }

        case .passcode:
            if let clue = currentClue, let passcode = clue.passcode {
                PasscodeView(
                    expectedPasscode: passcode,
                    onSuccess: {
                        unlockedClues.insert(currentClueIndex)
                        advanceToNextClue()
                    },
                    onBackToIntro: {
                        goToHome()
                    },
                    onBackToReveal: {
                        gameState = .reveal
                    }
                )
            }

        case .victory:
            VictoryView(
                hunt: hunt,
                onRestart: {
                    restartHunt()
                },
                onBackToHome: {
                    goToHome()
                },
                onBackToLastClue: {
                    goToLastClue()
                }
            )
        }
    }

    private func selectHunt(_ hunt: Hunt) {
        selectedHunt = hunt

        // Check for saved progress on this hunt
        if let progress = HuntProgressManager.shared.loadProgress() {
            if progress.huntId == hunt.id {
                currentClueIndex = progress.currentClueIndex
                hintsRevealed = progress.hintsRevealed
                arrivedClues = Set(progress.arrivedClues)
                unlockedClues = Set(progress.unlockedClues)
                if let state = GameState(rawValue: progress.gameState) {
                    gameState = state
                }
                return
            }
        }

        // Fresh start
        currentClueIndex = 0
        hintsRevealed = 0
        arrivedClues = []
        unlockedClues = []
        gameState = .intro
    }

    private func saveProgress() {
        guard let hunt = selectedHunt else { return }
        HuntProgressManager.shared.saveProgress(
            huntId: hunt.id,
            clueIndex: currentClueIndex,
            gameState: gameState,
            hintsRevealed: hintsRevealed,
            arrivedClues: arrivedClues,
            unlockedClues: unlockedClues
        )
    }

    private func handleContinue() {
        guard let clue = currentClue else { return }

        if isLastClue {
            gameState = .victory
            // Mark hunt as editable after completion
            if let hunt = selectedHunt {
                huntStore.markHuntEditable(hunt.id)
            }
        } else if clue.unlockNext == .passcode && clue.passcode != nil && !unlockedClues.contains(currentClueIndex) {
            gameState = .passcode
        } else {
            advanceToNextClue()
        }
    }

    private func advanceToNextClue() {
        currentClueIndex += 1
        hintsRevealed = 0
        gameState = .playing
    }

    private func restartHunt() {
        currentClueIndex = 0
        hintsRevealed = 0
        arrivedClues = []
        unlockedClues = []
        gameState = .intro
        HuntProgressManager.shared.clearProgress()
    }

    private func goToHome() {
        selectedHunt = nil
        currentClueIndex = 0
        hintsRevealed = 0
        gameState = .intro
    }

    private func goToPreviousClue() {
        guard currentClueIndex > 0 else { return }
        currentClueIndex -= 1
        if let hunt = selectedHunt {
            hintsRevealed = hunt.clues[currentClueIndex].hints.count
        }
        // Go to the reveal page of the previous clue
        gameState = .reveal
    }

    private func goToLastClue() {
        if let hunt = selectedHunt {
            hintsRevealed = hunt.clues[currentClueIndex].hints.count
        }
        // Go to the reveal page of the last clue
        gameState = .reveal
    }
}

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)

            Text("Loading...")
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    ContentView()
}
