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
    }
}
