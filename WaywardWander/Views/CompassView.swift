import SwiftUI

struct CompassView: View {
    let rotation: Double

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 200, height: 200)

                Circle()
                    .stroke(Color.gray.opacity(0.6), lineWidth: 3)
                    .frame(width: 200, height: 200)

                ForEach(0..<8) { index in
                    Rectangle()
                        .fill(Color.gray.opacity(0.6))
                        .frame(width: 2, height: 12)
                        .offset(y: -90)
                        .rotationEffect(.degrees(Double(index) * 45))
                }

                Text("N")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .offset(y: -110)

                ArrowShape()
                    .fill(Color.orange)
                    .frame(width: 40, height: 120)
                    .rotationEffect(.degrees(rotation))
                    .animation(.easeInOut(duration: 0.3), value: rotation)
            }

            Text("Follow the arrow")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

struct ArrowShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let width = rect.width
        let height = rect.height
        let centerX = rect.midX

        path.move(to: CGPoint(x: centerX, y: 0))
        path.addLine(to: CGPoint(x: centerX + width/2, y: height * 0.4))
        path.addLine(to: CGPoint(x: centerX + width/6, y: height * 0.35))
        path.addLine(to: CGPoint(x: centerX + width/6, y: height))
        path.addLine(to: CGPoint(x: centerX - width/6, y: height))
        path.addLine(to: CGPoint(x: centerX - width/6, y: height * 0.35))
        path.addLine(to: CGPoint(x: centerX - width/2, y: height * 0.4))
        path.closeSubpath()

        return path
    }
}

#Preview {
    CompassView(rotation: 45)
}
