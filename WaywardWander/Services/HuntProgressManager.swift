import Foundation

struct HuntProgress: Codable {
    var huntId: String
    var currentClueIndex: Int
    var gameState: String
    var hintsRevealed: Int
}

class HuntProgressManager {
    static let shared = HuntProgressManager()

    private let progressKey = "huntProgress"

    private init() {}

    func saveProgress(huntId: String, clueIndex: Int, gameState: GameState, hintsRevealed: Int) {
        let progress = HuntProgress(
            huntId: huntId,
            currentClueIndex: clueIndex,
            gameState: gameState.rawValue,
            hintsRevealed: hintsRevealed
        )

        if let encoded = try? JSONEncoder().encode(progress) {
            UserDefaults.standard.set(encoded, forKey: progressKey)
        }
    }

    func loadProgress() -> HuntProgress? {
        guard let data = UserDefaults.standard.data(forKey: progressKey),
              let progress = try? JSONDecoder().decode(HuntProgress.self, from: data) else {
            return nil
        }
        return progress
    }

    func clearProgress() {
        UserDefaults.standard.removeObject(forKey: progressKey)
    }
}
