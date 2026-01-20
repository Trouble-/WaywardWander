import SwiftUI

struct HuntCardView: View {
    let hunt: Hunt
    let isUserCreated: Bool
    let onSelect: () -> Void
    var onEdit: (() -> Void)?
    var onDelete: (() -> Void)?
    var onShare: (() -> Void)?

    init(
        hunt: Hunt,
        isUserCreated: Bool = false,
        onSelect: @escaping () -> Void,
        onEdit: (() -> Void)? = nil,
        onDelete: (() -> Void)? = nil,
        onShare: (() -> Void)? = nil
    ) {
        self.hunt = hunt
        self.isUserCreated = isUserCreated
        self.onSelect = onSelect
        self.onEdit = onEdit
        self.onDelete = onDelete
        self.onShare = onShare
    }

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

                            if isUserCreated {
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
        .contextMenu {
            if isUserCreated {
                if let onEdit = onEdit {
                    Button(action: onEdit) {
                        Label("Edit", systemImage: "pencil")
                    }
                }

                if let onShare = onShare {
                    Button(action: onShare) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                }

                if let onDelete = onDelete {
                    Button(role: .destructive, action: onDelete) {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
    }
}
