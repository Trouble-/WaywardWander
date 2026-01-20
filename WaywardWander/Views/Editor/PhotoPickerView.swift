import SwiftUI
import PhotosUI

struct PhotoPickerView: View {
    @Binding var photos: [PhotoItem]
    @Binding var existingPhotoNames: [String]
    let huntId: String

    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var showingCamera = false
    @State private var showingSourcePicker = false

    private let columns = [
        GridItem(.adaptive(minimum: 80, maximum: 100), spacing: 8)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Reveal Photos")
                .font(.headline)
                .foregroundColor(.primary)

            // Photo grid
            if !existingPhotoNames.isEmpty || !photos.isEmpty {
                LazyVGrid(columns: columns, spacing: 8) {
                    // Existing photos (already saved)
                    ForEach(existingPhotoNames, id: \.self) { photoName in
                        ExistingPhotoThumbnail(photoName: photoName, huntId: huntId) {
                            existingPhotoNames.removeAll { $0 == photoName }
                        }
                    }

                    // New photos (not yet saved)
                    ForEach(photos) { photo in
                        PhotoThumbnail(photo: photo) {
                            photos.removeAll { $0.id == photo.id }
                        }
                    }

                    // Add button
                    addPhotoButton
                }
            } else {
                // Empty state with add button
                addPhotoButton
            }
        }
        .padding()
        .background(AppTheme.secondaryLight)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.secondaryBorder, lineWidth: 1)
        )
        .confirmationDialog("Add Photo", isPresented: $showingSourcePicker) {
            Button("Photo Library") {
                // PhotosPicker is triggered separately
            }
            Button("Take Photo") {
                showingCamera = true
            }
            Button("Cancel", role: .cancel) { }
        }
        .photosPicker(isPresented: .constant(false), selection: $selectedItems, matching: .images)
        .onChange(of: selectedItems) { _, newItems in
            loadSelectedPhotos(newItems)
        }
        .fullScreenCover(isPresented: $showingCamera) {
            CameraView { image in
                let filename = "photo_\(UUID().uuidString.prefix(8)).jpg"
                photos.append(PhotoItem(image: image, filename: filename))
            }
        }
    }

    private var addPhotoButton: some View {
        PhotosPicker(selection: $selectedItems, matching: .images) {
            VStack(spacing: 4) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                Text("Add")
                    .font(.caption)
            }
            .foregroundColor(AppTheme.accent)
            .frame(width: 80, height: 80)
            .background(AppTheme.accentLight)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppTheme.accentBorder, lineWidth: 1)
            )
        }
    }

    private func loadSelectedPhotos(_ items: [PhotosPickerItem]) {
        for item in items {
            item.loadTransferable(type: Data.self) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data):
                        if let data = data, let image = UIImage(data: data) {
                            let filename = "photo_\(UUID().uuidString.prefix(8)).jpg"
                            photos.append(PhotoItem(image: image, filename: filename))
                        }
                    case .failure(let error):
                        print("Failed to load photo: \(error)")
                    }
                }
            }
        }
        selectedItems = []
    }
}

// MARK: - Photo Thumbnail

struct PhotoThumbnail: View {
    let photo: PhotoItem
    let onDelete: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: photo.image)
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .background(Circle().fill(Color.black.opacity(0.5)))
            }
            .offset(x: 4, y: -4)
        }
    }
}

// MARK: - Existing Photo Thumbnail

struct ExistingPhotoThumbnail: View {
    let photoName: String
    let huntId: String
    let onDelete: () -> Void

    @State private var loadedImage: UIImage?

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Group {
                if let image = loadedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Rectangle()
                        .fill(AppTheme.secondaryLight)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.secondary)
                        )
                }
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .background(Circle().fill(Color.black.opacity(0.5)))
            }
            .offset(x: 4, y: -4)
        }
        .onAppear {
            loadExistingImage()
        }
    }

    private func loadExistingImage() {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let imagesDirectory = documentsDirectory
            .appendingPathComponent("Hunts")
            .appendingPathComponent(huntId)
            .appendingPathComponent("images")

        // Try with different extensions
        for ext in ["", ".jpg", ".jpeg", ".png", ".heic"] {
            let imagePath = imagesDirectory.appendingPathComponent(photoName + ext)
            if let data = try? Data(contentsOf: imagePath),
               let image = UIImage(data: data) {
                loadedImage = image
                return
            }
        }

        // Also try the name as-is if it has an extension
        let directPath = imagesDirectory.appendingPathComponent(photoName)
        if let data = try? Data(contentsOf: directPath),
           let image = UIImage(data: data) {
            loadedImage = image
        }
    }
}

// MARK: - Camera View

struct CameraView: UIViewControllerRepresentable {
    let onCapture: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onCapture: onCapture, dismiss: dismiss)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onCapture: (UIImage) -> Void
        let dismiss: DismissAction

        init(onCapture: @escaping (UIImage) -> Void, dismiss: DismissAction) {
            self.onCapture = onCapture
            self.dismiss = dismiss
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                onCapture(image)
            }
            dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss()
        }
    }
}

#Preview {
    PhotoPickerView(
        photos: .constant([]),
        existingPhotoNames: .constant(["test_photo"]),
        huntId: "test-hunt"
    )
    .padding()
}
