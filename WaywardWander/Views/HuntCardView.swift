import SwiftUI

struct HuntCardView: View {
    let hunt: Hunt
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(hunt.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)

                        HStack(spacing: 12) {
                            Label("\(hunt.clues.count)", systemImage: "mappin.circle.fill")
                                .font(.subheadline)
                                .foregroundColor(AppTheme.accent)

                            Label(huntDifficulty, systemImage: "figure.walk")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
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
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(AppTheme.accent.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var huntDifficulty: String {
        switch hunt.clues.count {
        case 1...3: return "Short"
        case 4...6: return "Medium"
        default: return "Long"
        }
    }
}
