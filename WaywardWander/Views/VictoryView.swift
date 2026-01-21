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

            ScrollView {
                VStack(spacing: 32) {
                    VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.gold.opacity(0.2))
                            .frame(width: 150, height: 150)

                        Circle()
                            .stroke(AppTheme.gold.opacity(0.6), lineWidth: 3)
                            .frame(width: 150, height: 150)

                        Image(systemName: "trophy.fill")
                            .font(.system(size: 70))
                            .foregroundColor(AppTheme.gold)
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

                VStack(spacing: 12) {
                    Button(action: onBackToHome) {
                        HStack {
                            Image(systemName: "house.fill")
                            Text("Home")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.clear)
                        .foregroundColor(AppTheme.accent)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppTheme.accent, lineWidth: 2)
                        )
                    }

                    Button(action: onRestart) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Start Over")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.clear)
                        .foregroundColor(AppTheme.accent)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppTheme.accent, lineWidth: 2)
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
                }
                .padding()
            }
            .onAppear {
                showConfetti = true
            }
        }
        .withAppBackground()
    }
}
