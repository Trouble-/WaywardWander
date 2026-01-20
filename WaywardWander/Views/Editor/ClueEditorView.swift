import SwiftUI

struct ClueEditorView: View {
    @ObservedObject var clue: EditableClue
    let clueNumber: Int
    let huntId: String
    let onDelete: () -> Void

    @State private var showingDeleteConfirmation = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with clue number and delete button
            HStack {
                Label("Clue \(clueNumber)", systemImage: "mappin.circle.fill")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(AppTheme.accent)

                Spacer()

                if !clue.isValid {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                }

                Button(action: { showingDeleteConfirmation = true }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }

            Divider()

            // Location picker
            LocationPickerView(
                latitude: $clue.latitude,
                longitude: $clue.longitude
            )

            // Arrival radius
            arrivalRadiusSection

            // Initial clue text
            initialClueSection

            // Hints
            hintsSection

            // Reveal section
            revealSection

            // Unlock type
            unlockTypeSection
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppTheme.accentBorder, lineWidth: 2)
        )
        .confirmationDialog(
            "Delete Clue",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive, action: onDelete)
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this clue? This cannot be undone.")
        }
    }

    // MARK: - Arrival Radius Section

    private var arrivalRadiusSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Arrival Radius")
                    .font(.headline)
                Spacer()
                Text("\(Int(clue.arrivalRadius))m")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Slider(value: $clue.arrivalRadius, in: 5...100, step: 5)
                .tint(AppTheme.accent)

            Text("How close the user must be to trigger arrival")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(AppTheme.secondaryLight)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.secondaryBorder, lineWidth: 1)
        )
    }

    // MARK: - Initial Clue Section

    private var initialClueSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Initial Clue")
                .font(.headline)

            TextEditor(text: $clue.initialClue)
                .frame(minHeight: 80)
                .padding(8)
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(clue.initialClue.isEmpty ? Color.red.opacity(0.5) : AppTheme.secondaryBorder, lineWidth: 1)
                )

            if clue.initialClue.isEmpty {
                Text("Required: The riddle or clue shown to the user")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(AppTheme.secondaryLight)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.secondaryBorder, lineWidth: 1)
        )
    }

    // MARK: - Hints Section

    private var hintsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Hints")
                    .font(.headline)

                Spacer()

                Menu {
                    Button(action: { addHint(.text) }) {
                        Label("Text Hint", systemImage: "text.bubble")
                    }
                    Button(action: { addHint(.compass) }) {
                        Label("Compass Hint", systemImage: "location.north.circle")
                    }
                    Button(action: { addHint(.distance) }) {
                        Label("Distance Hint", systemImage: "ruler")
                    }
                } label: {
                    Label("Add Hint", systemImage: "plus.circle.fill")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(AppTheme.accent)
                }
            }

            if clue.hints.isEmpty {
                Text("No hints added. Hints are revealed progressively as the user needs help.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            } else {
                ForEach(Array(clue.hints.enumerated()), id: \.element.id) { index, hint in
                    HintEditorRow(
                        hint: Binding(
                            get: { clue.hints[index] },
                            set: { clue.hints[index] = $0 }
                        ),
                        index: index,
                        onDelete: { clue.hints.remove(at: index) }
                    )
                }
            }
        }
        .padding()
        .background(AppTheme.infoLight)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.infoBorder, lineWidth: 1)
        )
    }

    private func addHint(_ type: HintType) {
        let content = type == .text ? "" : nil
        clue.hints.append(EditableHint(type: type, content: content ?? ""))
    }

    // MARK: - Reveal Section

    private var revealSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Reveal Content")
                .font(.headline)

            Text("Shown when the user arrives at the location")
                .font(.caption)
                .foregroundColor(.secondary)

            // Reveal text
            VStack(alignment: .leading, spacing: 4) {
                Text("Reveal Text")
                    .font(.subheadline.weight(.medium))

                TextEditor(text: $clue.revealText)
                    .frame(minHeight: 60)
                    .padding(8)
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AppTheme.secondaryBorder, lineWidth: 1)
                    )
            }

            // Photos
            PhotoPickerView(
                photos: $clue.revealPhotos,
                existingPhotoNames: $clue.existingPhotoNames,
                huntId: huntId
            )
        }
        .padding()
        .background(AppTheme.successLight)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.successBorder, lineWidth: 1)
        )
    }

    // MARK: - Unlock Type Section

    private var unlockTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Unlock Next Clue")
                .font(.headline)

            Picker("Unlock Type", selection: $clue.unlockType) {
                Text("Automatic").tag(UnlockType.automatic)
                Text("Passcode").tag(UnlockType.passcode)
            }
            .pickerStyle(.segmented)

            if clue.unlockType == .passcode {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Passcode")
                        .font(.subheadline.weight(.medium))

                    TextField("Enter passcode", text: $clue.passcode)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    if clue.passcode.isEmpty {
                        Text("Required when unlock type is passcode")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .padding()
        .background(AppTheme.secondaryLight)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.secondaryBorder, lineWidth: 1)
        )
    }
}

// MARK: - Hint Editor Row

struct HintEditorRow: View {
    @Binding var hint: EditableHint
    let index: Int
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            // Hint type icon
            Image(systemName: iconForHintType(hint.type))
                .foregroundColor(AppTheme.info)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text("Hint \(index + 1): \(labelForHintType(hint.type))")
                    .font(.caption.weight(.medium))
                    .foregroundColor(.secondary)

                if hint.type == .text {
                    TextField("Hint text", text: $hint.content)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                } else {
                    Text(descriptionForHintType(hint.type))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                }
            }

            Spacer()

            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
            }
        }
        .padding(8)
        .background(Color(.systemBackground).opacity(0.5))
        .cornerRadius(8)
    }

    private func iconForHintType(_ type: HintType) -> String {
        switch type {
        case .text: return "text.bubble"
        case .compass: return "location.north.circle"
        case .distance: return "ruler"
        }
    }

    private func labelForHintType(_ type: HintType) -> String {
        switch type {
        case .text: return "Text"
        case .compass: return "Compass"
        case .distance: return "Distance"
        }
    }

    private func descriptionForHintType(_ type: HintType) -> String {
        switch type {
        case .text: return ""
        case .compass: return "Shows compass pointing to location"
        case .distance: return "Shows distance to location"
        }
    }
}

#Preview {
    ScrollView {
        ClueEditorView(
            clue: EditableClue(
                clueId: 0,
                latitude: "37.7749",
                longitude: "-122.4194",
                initialClue: "Find the famous landmark...",
                hints: [
                    EditableHint(type: .text, content: "Look for the pyramid shape"),
                    EditableHint(type: .compass, content: "")
                ]
            ),
            clueNumber: 1,
            huntId: "test-hunt",
            onDelete: {}
        )
        .padding()
    }
}
