import SwiftUI

struct HuntImageLoader {
    static func loadImage(named imageName: String, forHuntId huntId: String) -> UIImage? {
        // First, check Documents directory for imported hunt images
        if let documentsImage = loadFromDocuments(imageName: imageName, huntId: huntId) {
            return documentsImage
        }

        // Fall back to bundled assets
        if let bundledImage = UIImage(named: imageName) {
            return bundledImage
        }

        return nil
    }

    private static func loadFromDocuments(imageName: String, huntId: String) -> UIImage? {
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }

        let huntImagesDir = documentsURL
            .appendingPathComponent("Hunts")
            .appendingPathComponent(huntId)
            .appendingPathComponent("images")

        // Try common image extensions
        for ext in ["jpg", "jpeg", "png", "heic", "JPG", "JPEG", "PNG", "HEIC"] {
            let imageURL = huntImagesDir.appendingPathComponent("\(imageName).\(ext)")
            if let image = UIImage(contentsOfFile: imageURL.path) {
                return image
            }
        }

        // Try without extension (filename might include it)
        let directURL = huntImagesDir.appendingPathComponent(imageName)
        if let image = UIImage(contentsOfFile: directURL.path) {
            return image
        }

        return nil
    }
}

// SwiftUI View for loading hunt images with placeholder
struct HuntImage: View {
    let imageName: String
    let huntId: String
    let index: Int
    let totalCount: Int

    var body: some View {
        if let uiImage = HuntImageLoader.loadImage(named: imageName, forHuntId: huntId) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(12)
                .padding(.horizontal)
        } else {
            // Placeholder for missing images
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.orange.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.orange.opacity(0.3), lineWidth: 2)
                    )
                VStack(spacing: 8) {
                    Image(systemName: "photo.on.rectangle")
                        .font(.system(size: 40))
                        .foregroundColor(.orange)
                    Text("Photo \(index + 1) of \(totalCount)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.orange)
                    Text(imageName)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .aspectRatio(4/3, contentMode: .fit)
            .padding(.horizontal)
        }
    }
}
