import SwiftUI

struct BackgroundView: View {
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [
                    Color.orange.opacity(0.3),
                    Color.orange.opacity(0.1),
                    Color(.systemBackground)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Optional background image
            if let bgImage = UIImage(named: "home_background") {
                GeometryReader { geo in
                    Image(uiImage: bgImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                }
                .ignoresSafeArea()
                .opacity(0.6)
            }
        }
    }
}

// View modifier for easy application
extension View {
    func withAppBackground() -> some View {
        ZStack {
            BackgroundView()
            self
        }
    }
}
