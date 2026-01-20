import SwiftUI

struct VictoryView: View {
    let hunt: Hunt
    let onRestart: () -> Void
    let onBackToHome: () -> Void
    let onBackToLastClue: () -> Void

    @State private var showConfetti: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onBackToHome) {
                    HStack(spacing: 4) {
                        Image(systemName: "house")
                        Text("Home")
                    }
                    .font(.subheadline)
                    .foregroundColor(AppTheme.accent)
                }

                Spacer()

                Button(action: onBackToLastClue) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Previous")
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(.systemBackground))

            VStack(spacing: 32) {
                Spacer()

                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(Color.yellow.opacity(0.2))
                            .frame(width: 150, height: 150)

                        Circle()
                            .stroke(Color.yellow.opacity(0.6), lineWidth: 3)
                            .frame(width: 150, height: 150)

                        Image(systemName: "trophy.fill")
                            .font(.system(size: 70))
                            .foregroundColor(.yellow)
                    }

                Text("Congratulations!")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("You completed")
                    .font(.title3)
                    .foregroundColor(.secondary)

                Text(hunt.title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.accent)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppTheme.success)
                    Text("\(hunt.clues.count) locations discovered")
                }

                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(AppTheme.accent)
                    Text("Journey complete!")
                }
            }
            .font(.subheadline)
            .padding()
            .background(AppTheme.successLight)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppTheme.successBorder, lineWidth: 2)
            )

            Spacer()

                Button(action: onRestart) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Start Over")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.accent)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
            .padding()
            .onAppear {
                showConfetti = true
            }
        }
        .withAppBackground()
    }
}
