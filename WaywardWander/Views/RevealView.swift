import SwiftUI

struct RevealView: View {
    let reveal: Reveal
    let clueNumber: Int
    let isLastClue: Bool
    let unlockType: UnlockType
    let huntId: String
    let onContinue: () -> Void
    let onBackToIntro: () -> Void
    let onBackToClue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onBackToIntro) {
                    HStack(spacing: 4) {
                        Image(systemName: "house")
                        Text("Start")
                    }
                    .font(.subheadline)
                    .foregroundColor(.orange)
                }

                Spacer()

                Button(action: onBackToClue) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back to Clue")
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(.systemBackground))

            ScrollView {
                VStack(spacing: 24) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.yellow)

                Text("Discovery!")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                if !reveal.photos.isEmpty {
                    TabView {
                        ForEach(Array(reveal.photos.enumerated()), id: \.offset) { index, photo in
                            HuntImage(
                                imageName: photo,
                                huntId: huntId,
                                index: index,
                                totalCount: reveal.photos.count
                            )
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))
                    .frame(height: 280)
                }

                Text(reveal.text)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding()
                    .background(Color.yellow.opacity(0.1))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.yellow.opacity(0.5), lineWidth: 2)
                    )

                Button(action: onContinue) {
                    HStack {
                        Text(isLastClue ? "Complete Hunt" : "Next Clue")
                            .fontWeight(.semibold)
                        Image(systemName: isLastClue ? "flag.checkered" : "arrow.right")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.top)

                Spacer(minLength: 50)
            }
                .padding()
            }
        }
        .withAppBackground()
    }
}
