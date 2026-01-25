import SwiftUI

struct HuntCardView: View {
    let hunt: Hunt
    let isEditable: Bool
    let onSelect: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onShare: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(hunt.title)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)

                            if isEditable {
                                Image(systemName: "pencil.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.accent)
                            }
                        }

                        Label("\(hunt.clues.count) locations", systemImage: "mappin.circle.fill")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.accent)
                    }

                    Spacer()

                    Image(systemName: "chevron.right.circle.fill")
                        .font(.title2)
                        .foregroundColor(AppTheme.accent)
                }

                Text(hunt.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .padding()
            .background(AppTheme.accentLight)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppTheme.accentBorder, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .modifier(EditableContextMenu(
            isEditable: isEditable,
            onEdit: onEdit,
            onShare: onShare,
            onDelete: onDelete
        ))
    }
}

struct EditableContextMenu: ViewModifier {
    let isEditable: Bool
    let onEdit: () -> Void
    let onShare: () -> Void
    let onDelete: () -> Void

    func body(content: Content) -> some View {
        content.contextMenu {
            Button(action: onEdit) {
                Label("Edit", systemImage: "pencil")
            }
            .disabled(!isEditable)

            Button(action: onShare) {
                Label("Share", systemImage: "square.and.arrow.up")
            }

            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
