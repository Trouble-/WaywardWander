import Foundation
import SwiftUI
import Combine
import UIKit

// MARK: - Photo Item

struct PhotoItem: Identifiable {
    var id = UUID()
    var image: UIImage
    var filename: String
}

// MARK: - Editable Hint

struct EditableHint: Identifiable {
    var id = UUID()
    var type: HintType
    var content: String

    func toHint() -> Hint {
        Hint(type: type, content: content.isEmpty ? nil : content)
    }

    static func from(_ hint: Hint) -> EditableHint {
        EditableHint(type: hint.type, content: hint.content ?? "")
    }
}

// MARK: - Editable Clue

class EditableClue: ObservableObject, Identifiable {
    let id = UUID()
    @Published var clueId: Int
    @Published var latitude: String
    @Published var longitude: String
    @Published var arrivalRadius: Double
    @Published var initialClue: String
    @Published var hints: [EditableHint]
    @Published var revealText: String
    @Published var revealPhotos: [PhotoItem]
    @Published var existingPhotoNames: [String]  // For photos already saved to disk
    @Published var unlockType: UnlockType
    @Published var passcode: String

    init(
        clueId: Int = 0,
        latitude: String = "",
        longitude: String = "",
        arrivalRadius: Double = 20.0,
        initialClue: String = "",
        hints: [EditableHint] = [],
        revealText: String = "",
        revealPhotos: [PhotoItem] = [],
        existingPhotoNames: [String] = [],
        unlockType: UnlockType = .automatic,
        passcode: String = ""
    ) {
        self.clueId = clueId
        self.latitude = latitude
        self.longitude = longitude
        self.arrivalRadius = arrivalRadius
        self.initialClue = initialClue
        self.hints = hints
        self.revealText = revealText
        self.revealPhotos = revealPhotos
        self.existingPhotoNames = existingPhotoNames
        self.unlockType = unlockType
        self.passcode = passcode
    }

    var isLocationValid: Bool {
        guard let lat = Double(latitude), let lng = Double(longitude) else {
            return false
        }
        return lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180
    }

    var isValid: Bool {
        isLocationValid && !initialClue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func toClue(photoFilenames: [String]) -> Clue {
        let lat = Double(latitude) ?? 0
        let lng = Double(longitude) ?? 0

        // Combine existing photos with new photo filenames
        let allPhotoNames = existingPhotoNames + photoFilenames

        return Clue(
            id: clueId,
            location: Coordinate(lat: lat, lng: lng),
            arrivalRadius: arrivalRadius,
            initialClue: initialClue,
            hints: hints.map { $0.toHint() },
            reveal: Reveal(photos: allPhotoNames, text: revealText),
            unlockNext: unlockType,
            passcode: unlockType == .passcode && !passcode.isEmpty ? passcode : nil
        )
    }

    static func from(_ clue: Clue) -> EditableClue {
        EditableClue(
            clueId: clue.id,
            latitude: String(clue.location.lat),
            longitude: String(clue.location.lng),
            arrivalRadius: clue.arrivalRadius,
            initialClue: clue.initialClue,
            hints: clue.hints.map { EditableHint.from($0) },
            revealText: clue.reveal.text,
            revealPhotos: [],  // Photos will be loaded separately
            existingPhotoNames: clue.reveal.photos,
            unlockType: clue.unlockNext,
            passcode: clue.passcode ?? ""
        )
    }
}

// MARK: - Editable Hunt

class EditableHunt: ObservableObject {
    @Published var id: String
    @Published var title: String
    @Published var description: String
    @Published var clues: [EditableClue]

    init(
        id: String = UUID().uuidString,
        title: String = "",
        description: String = "",
        clues: [EditableClue] = []
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.clues = clues
    }

    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !clues.isEmpty &&
        clues.allSatisfy { $0.isValid }
    }

    var validationErrors: [String] {
        var errors: [String] = []

        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("Quest must have a title")
        }

        if clues.isEmpty {
            errors.append("Quest must have at least one clue")
        }

        for (index, clue) in clues.enumerated() {
            if !clue.isLocationValid {
                errors.append("Clue \(index + 1): Invalid coordinates")
            }
            if clue.initialClue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                errors.append("Clue \(index + 1): Missing initial clue text")
            }
            if clue.unlockType == .passcode && clue.passcode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                errors.append("Clue \(index + 1): Passcode required when unlock type is passcode")
            }
        }

        return errors
    }

    func toHunt(photoFilenamesPerClue: [[String]]) -> Hunt {
        // Assign sequential IDs to clues
        var cluesWithIds: [Clue] = []
        for (index, editableClue) in clues.enumerated() {
            editableClue.clueId = index
            let photoFilenames = index < photoFilenamesPerClue.count ? photoFilenamesPerClue[index] : []
            cluesWithIds.append(editableClue.toClue(photoFilenames: photoFilenames))
        }

        return Hunt(
            id: id,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            clues: cluesWithIds
        )
    }

    static func from(_ hunt: Hunt) -> EditableHunt {
        EditableHunt(
            id: hunt.id,
            title: hunt.title,
            description: hunt.description,
            clues: hunt.clues.map { EditableClue.from($0) }
        )
    }

    static func createNew() -> EditableHunt {
        let hunt = EditableHunt()
        // Start with one empty clue
        hunt.clues.append(EditableClue(clueId: 0))
        return hunt
    }
}
