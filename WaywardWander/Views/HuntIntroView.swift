import SwiftUI

struct HuntIntroView: View {
    let hunt: Hunt
    let onStart: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 20) {
                Image(systemName: "map.fill")
                    .font(.system(size: 70))
                    .foregroundColor(.orange)

                Text(hunt.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text(hunt.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(.blue)
                    Text("\(hunt.clues.count) locations to discover")
                }
                .font(.subheadline)

                HStack {
                    Image(systemName: "figure.walk")
                        .foregroundColor(.green)
                    Text("Get ready to explore!")
                }
                .font(.subheadline)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)

            Spacer()

            Button(action: onStart) {
                HStack {
                    Text("Begin Hunt")
                        .fontWeight(.semibold)
                    Image(systemName: "arrow.right")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
        .padding()
    }
}
