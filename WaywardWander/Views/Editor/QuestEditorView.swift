import SwiftUI

struct QuestEditorView: View {
    @ObservedObject var hunt: EditableHunt
    let isNewQuest: Bool
    let huntStore: HuntStore
    let onSave: () -> Void
    let onCancel: () -> Void

    @State private var showingDiscardAlert = false
    @State private var showingValidationErrors = false
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Quest metadata
                    metadataSection

                    // Clues
                    cluesSection

                    // Add clue button
                    addClueButton
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(isNewQuest ? "Create Quest" : "Edit Quest")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showingDiscardAlert = true
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveQuest()
                    }
                    .disabled(isSaving)
                    .fontWeight(.semibold)
                }
            }
            .alert("Discard Changes?", isPresented: $showingDiscardAlert) {
                Button("Discard", role: .destructive) {
                    onCancel()
                }
                Button("Keep Editing", role: .cancel) { }
            } message: {
                Text("You have unsaved changes. Are you sure you want to discard them?")
            }
            .alert("Validation Errors", isPresented: $showingValidationErrors) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(hunt.validationErrors.joined(separator: "\n"))
            }
        }
    }

    // MARK: - Metadata Section

    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quest Details")
                .font(.title2.weight(.bold))
                .foregroundColor(.primary)

            VStack(alignment: .leading, spacing: 8) {
                Text("Title")
                    .font(.headline)

                TextField("Quest title", text: $hunt.title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                if hunt.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text("Required")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Description")
                    .font(.headline)

                TextEditor(text: $hunt.description)
                    .frame(minHeight: 80)
                    .padding(8)
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AppTheme.secondaryBorder, lineWidth: 1)
                    )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppTheme.accentBorder, lineWidth: 2)
        )
    }

    // MARK: - Clues Section

    @ViewBuilder
    private var cluesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Clues")
                    .font(.title2.weight(.bold))

                Spacer()

                Text("\(hunt.clues.count) clue\(hunt.clues.count == 1 ? "" : "s")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            if hunt.clues.isEmpty {
                emptyCluesState
            } else {
                ForEach(hunt.clues.indices, id: \.self) { index in
                    let clue = hunt.clues[index]
                    ClueEditorView(
                        clue: clue,
                        clueNumber: index + 1,
                        huntId: hunt.id,
                        onDelete: {
                            withAnimation {
                                _ = hunt.clues.remove(at: index)
                            }
                        }
                    )
                }
            }
        }
    }

    private var emptyCluesState: some View {
        VStack(spacing: 12) {
            Image(systemName: "mappin.slash")
                .font(.system(size: 40))
                .foregroundColor(AppTheme.accent.opacity(0.5))

            Text("No clues yet")
                .font(.headline)
                .foregroundColor(.secondary)

            Text("Add at least one clue to create your quest")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(AppTheme.accentLight)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppTheme.accentBorder, lineWidth: 2)
        )
    }

    // MARK: - Add Clue Button

    private var addClueButton: some View {
        Button(action: addClue) {
            HStack {
                Image(systemName: "plus.circle.fill")
                Text("Add Clue")
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(AppTheme.accent)
            .cornerRadius(12)
        }
    }

    // MARK: - Actions

    private func addClue() {
        withAnimation {
            let newClue = EditableClue(clueId: hunt.clues.count)
            hunt.clues.append(newClue)
        }
    }

    private func saveQuest() {
        guard hunt.isValid else {
            showingValidationErrors = true
            return
        }

        isSaving = true

        // Collect all images from clues
        var allImages: [String: UIImage] = [:]
        var photoFilenamesPerClue: [[String]] = []

        for clue in hunt.clues {
            var cluePhotoFilenames: [String] = []
            for photo in clue.revealPhotos {
                allImages[photo.filename] = photo.image
                cluePhotoFilenames.append(photo.filename)
            }
            photoFilenamesPerClue.append(cluePhotoFilenames)
        }

        let huntToSave = hunt.toHunt(photoFilenamesPerClue: photoFilenamesPerClue)

        if huntStore.saveHunt(huntToSave, images: allImages) {
            onSave()
        } else {
            isSaving = false
            // Could show an error alert here
        }
    }
}

#Preview {
    QuestEditorView(
        hunt: EditableHunt.createNew(),
        isNewQuest: true,
        huntStore: HuntStore(),
        onSave: {},
        onCancel: {}
    )
}
