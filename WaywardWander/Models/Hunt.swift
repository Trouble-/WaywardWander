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
    let skipOption: SkipOption

    var clLocation: CLLocation {
        CLLocation(latitude: location.lat, longitude: location.lng)
    }

    init(id: Int, location: Coordinate, arrivalRadius: Double, initialClue: String, hints: [Hint], reveal: Reveal, unlockNext: UnlockType, passcode: String?, skipOption: SkipOption = .disabled) {
        self.id = id
        self.location = location
        self.arrivalRadius = arrivalRadius
        self.initialClue = initialClue
        self.hints = hints
        self.reveal = reveal
        self.unlockNext = unlockNext
        self.passcode = passcode
        self.skipOption = skipOption
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        location = try container.decode(Coordinate.self, forKey: .location)
        arrivalRadius = try container.decode(Double.self, forKey: .arrivalRadius)
        initialClue = try container.decode(String.self, forKey: .initialClue)
        hints = try container.decode([Hint].self, forKey: .hints)
        reveal = try container.decode(Reveal.self, forKey: .reveal)
        unlockNext = try container.decode(UnlockType.self, forKey: .unlockNext)
        passcode = try container.decodeIfPresent(String.self, forKey: .passcode)
        skipOption = try container.decodeIfPresent(SkipOption.self, forKey: .skipOption) ?? .disabled
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

enum SkipOption: Codable, Equatable {
    case disabled
    case allowed
    case password(String)

    // Custom coding to handle the associated value
    enum CodingKeys: String, CodingKey {
        case type
        case password
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case "disabled":
            self = .disabled
        case "allowed":
            self = .allowed
        case "password":
            let password = try container.decode(String.self, forKey: .password)
            self = .password(password)
        default:
            self = .disabled
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .disabled:
            try container.encode("disabled", forKey: .type)
        case .allowed:
            try container.encode("allowed", forKey: .type)
        case .password(let password):
            try container.encode("password", forKey: .type)
            try container.encode(password, forKey: .password)
        }
    }
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
