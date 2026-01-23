import Foundation
import CoreLocation

struct Hunt: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let clues: [Clue]
    var isEditable: Bool

    init(id: String, title: String, description: String, clues: [Clue], isEditable: Bool = true) {
        self.id = id
        self.title = title
        self.description = description
        self.clues = clues
        self.isEditable = isEditable
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        clues = try container.decode([Clue].self, forKey: .clues)
        isEditable = try container.decodeIfPresent(Bool.self, forKey: .isEditable) ?? true
    }
}

struct Clue: Codable, Identifiable {
    let id: Int
    let location: Coordinate
    let arrivalRadius: Double
    let initialClue: String
    let hints: [Hint]
    let reveal: Reveal
    let unlockNext: UnlockType
    let passcode: String?

    var clLocation: CLLocation {
        CLLocation(latitude: location.lat, longitude: location.lng)
    }
}

struct Coordinate: Codable {
    let lat: Double
    let lng: Double
}

struct Hint: Codable {
    let type: HintType
    let content: String?
}

struct Reveal: Codable {
    let photos: [String]
    let text: String
}

enum UnlockType: String, Codable {
    case automatic
    case passcode
}

enum HintType: String, Codable {
    case text
    case compass
    case distance
}

extension Hunt {
    static func load(from filename: String) -> Hunt? {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            print("Could not find \(filename).json in bundle")
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode(Hunt.self, from: data)
        } catch {
            print("Error loading hunt: \(error)")
            return nil
        }
    }
}
