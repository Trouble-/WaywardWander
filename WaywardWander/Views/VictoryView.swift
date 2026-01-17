import SwiftUI

struct VictoryView: View {
    let hunt: Hunt
    let onRestart: () -> Void

    @State private var showConfetti: Bool = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color.yellow.opacity(0.2))
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
                    .foregroundColor(.orange)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("\(hunt.clues.count) locations discovered")
                }

                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("Hunt complete!")
                }
            }
            .font(.subheadline)
            .padding()
            .background(Color.green.opacity(0.1))
            .cornerRadius(12)

            Spacer()

            Button(action: onRestart) {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Start Over")
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
        .onAppear {
            showConfetti = true
        }
    }
}
