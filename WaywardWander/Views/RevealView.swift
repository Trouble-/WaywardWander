import SwiftUI

struct RevealView: View {
    let reveal: Reveal
    let clueNumber: Int
    let isLastClue: Bool
    let unlockType: UnlockType
    let onContinue: () -> Void

    var body: some View {
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
                        ForEach(reveal.photos, id: \.self) { photo in
                            if let uiImage = UIImage(named: photo) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .cornerRadius(12)
                                    .padding(.horizontal)
                            } else {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.gray.opacity(0.2))
                                    VStack {
                                        Image(systemName: "photo")
                                            .font(.system(size: 40))
                                            .foregroundColor(.gray)
                                        Text(photo)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .aspectRatio(4/3, contentMode: .fit)
                                .padding(.horizontal)
                            }
                        }
                    }
                    .tabViewStyle(.page)
                    .frame(height: 280)
                }

                Text(reveal.text)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding()
                    .background(Color.yellow.opacity(0.1))
                    .cornerRadius(16)

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
}
