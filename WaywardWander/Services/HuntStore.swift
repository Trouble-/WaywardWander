import Foundation
import Combine
import ZIPFoundation

class HuntStore: ObservableObject {
    @Published var hunts: [Hunt] = []
    @Published var isLoading: Bool = true

    private let fileManager = FileManager.default

    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private var huntsDirectory: URL {
        documentsDirectory.appendingPathComponent("Hunts", isDirectory: true)
    }

    init() {
        ensureHuntsDirectoryExists()
        loadAllHunts()
    }

    private func ensureHuntsDirectoryExists() {
        if !fileManager.fileExists(atPath: huntsDirectory.path) {
            try? fileManager.createDirectory(at: huntsDirectory, withIntermediateDirectories: true)
        }
    }

    func loadAllHunts() {
        isLoading = true
        var allHunts: [Hunt] = []

        // Load bundled hunts
        if let bundledHunts = loadBundledHunts() {
            allHunts.append(contentsOf: bundledHunts)
        }

        // Load imported hunts from documents
        let importedHunts = loadImportedHunts()
        allHunts.append(contentsOf: importedHunts)

        // Remove duplicates by ID
        var seen = Set<String>()
        hunts = allHunts.filter { hunt in
            if seen.contains(hunt.id) {
                return false
            }
            seen.insert(hunt.id)
            return true
        }

        isLoading = false
    }

    private func loadBundledHunts() -> [Hunt]? {
        guard let resourcePath = Bundle.main.resourcePath else { return nil }

        var hunts: [Hunt] = []
        let resourceURL = URL(fileURLWithPath: resourcePath)

        if let contents = try? fileManager.contentsOfDirectory(at: resourceURL, includingPropertiesForKeys: nil) {
            for url in contents where url.pathExtension == "json" {
                if let hunt = loadHunt(from: url) {
                    hunts.append(hunt)
                }
            }
        }

        return hunts.isEmpty ? nil : hunts
    }

    private func loadImportedHunts() -> [Hunt] {
        var hunts: [Hunt] = []

        guard let contents = try? fileManager.contentsOfDirectory(at: huntsDirectory, includingPropertiesForKeys: nil) else {
            return hunts
        }

        for url in contents {
            // Check for hunt directories (from .wwh imports)
            if url.hasDirectoryPath {
                let huntJsonURL = url.appendingPathComponent("hunt.json")
                if let hunt = loadHunt(from: huntJsonURL) {
                    hunts.append(hunt)
                }
            }
            // Check for standalone .json files (legacy imports)
            else if url.pathExtension == "json" {
                if let hunt = loadHunt(from: url) {
                    hunts.append(hunt)
                }
            }
        }

        return hunts
    }

    private func loadHunt(from url: URL) -> Hunt? {
        do {
            let data = try Data(contentsOf: url)
            let hunt = try JSONDecoder().decode(Hunt.self, from: data)
            return hunt
        } catch {
            print("Error loading hunt from \(url): \(error)")
            return nil
        }
    }

    func importHunt(from url: URL) -> Bool {
        guard url.startAccessingSecurityScopedResource() else {
            return importHuntDirect(from: url)
        }

        defer { url.stopAccessingSecurityScopedResource() }
        return importHuntDirect(from: url)
    }

    private func importHuntDirect(from url: URL) -> Bool {
        let fileExtension = url.pathExtension.lowercased()

        if fileExtension == "wwh" || fileExtension == "zip" {
            return importBundle(from: url)
        } else if fileExtension == "json" {
            return importJSON(from: url)
        }

        return false
    }

    private func importJSON(from url: URL) -> Bool {
        do {
            let data = try Data(contentsOf: url)
            let hunt = try JSONDecoder().decode(Hunt.self, from: data)

            // Create hunt directory
            let huntDir = huntsDirectory.appendingPathComponent(hunt.id, isDirectory: true)
            try fileManager.createDirectory(at: huntDir, withIntermediateDirectories: true)

            // Save hunt.json
            let destinationURL = huntDir.appendingPathComponent("hunt.json")
            try data.write(to: destinationURL)

            loadAllHunts()
            return true
        } catch {
            print("Error importing JSON hunt: \(error)")
            return false
        }
    }

    private func importBundle(from url: URL) -> Bool {
        do {
            // Create temp directory for extraction
            let tempDir = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
            try fileManager.createDirectory(at: tempDir, withIntermediateDirectories: true)

            defer {
                try? fileManager.removeItem(at: tempDir)
            }

            // Unzip the bundle using ZIPFoundation
            try fileManager.unzipItem(at: url, to: tempDir)

            // Find and read hunt.json
            let huntJsonURL = tempDir.appendingPathComponent("hunt.json")
            guard fileManager.fileExists(atPath: huntJsonURL.path) else {
                print("No hunt.json found in bundle")
                return false
            }

            let data = try Data(contentsOf: huntJsonURL)
            let hunt = try JSONDecoder().decode(Hunt.self, from: data)

            // Create hunt directory in Documents
            let huntDir = huntsDirectory.appendingPathComponent(hunt.id, isDirectory: true)
            if fileManager.fileExists(atPath: huntDir.path) {
                try fileManager.removeItem(at: huntDir)
            }
            try fileManager.createDirectory(at: huntDir, withIntermediateDirectories: true)

            // Copy hunt.json
            let destHuntJson = huntDir.appendingPathComponent("hunt.json")
            try data.write(to: destHuntJson)

            // Copy images folder if it exists
            let sourceImagesDir = tempDir.appendingPathComponent("images")
            let destImagesDir = huntDir.appendingPathComponent("images")

            if fileManager.fileExists(atPath: sourceImagesDir.path) {
                try fileManager.copyItem(at: sourceImagesDir, to: destImagesDir)
            }

            loadAllHunts()
            return true
        } catch {
            print("Error importing bundle: \(error)")
            return false
        }
    }

    func deleteHunt(_ hunt: Hunt) {
        // Try to delete hunt directory first
        let huntDir = huntsDirectory.appendingPathComponent(hunt.id, isDirectory: true)
        if fileManager.fileExists(atPath: huntDir.path) {
            try? fileManager.removeItem(at: huntDir)
        }

        // Also try legacy .json file
        let huntJSON = huntsDirectory.appendingPathComponent("\(hunt.id).json")
        if fileManager.fileExists(atPath: huntJSON.path) {
            try? fileManager.removeItem(at: huntJSON)
        }

        loadAllHunts()
    }

    // MARK: - Image Loading

    func imageURL(for imageName: String, huntId: String) -> URL? {
        // Check imported hunt's images folder
        let huntImagesDir = huntsDirectory
            .appendingPathComponent(huntId)
            .appendingPathComponent("images")

        // Try common image extensions
        for ext in ["jpg", "jpeg", "png", "heic"] {
            let imageURL = huntImagesDir.appendingPathComponent("\(imageName).\(ext)")
            if fileManager.fileExists(atPath: imageURL.path) {
                return imageURL
            }
        }

        // Also check without extension (in case filename includes it)
        let directURL = huntImagesDir.appendingPathComponent(imageName)
        if fileManager.fileExists(atPath: directURL.path) {
            return directURL
        }

        return nil
    }
}
