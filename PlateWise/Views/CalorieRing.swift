import SwiftUI

/// Custom component: an animated ring showing calories eaten vs the daily goal.
struct CalorieRing: View {
    let consumed: Int
    let goal: Int

    @State private var animatedProgress: Double = 0
    @ScaledMetric private var size: CGFloat = 200     // Grows with Dynamic Type (accessibility)

    private var progress: Double {
        goal > 0 ? Double(consumed) / Double(goal) : 0
    }

    /// Green while under the goal, orange when over
    private var ringColors: [Color] {
        progress > 1 ? [.orange, .red, .orange] : [.green, .mint, .green]
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(.quaternary, lineWidth: 18)         // Grey background track
            Circle()
                .trim(from: 0, to: min(animatedProgress, 1)) // Only draw part of the circle
                .stroke(AngularGradient(colors: ringColors, center: .center),
                        style: StrokeStyle(lineWidth: 18, lineCap: .round))
                .rotationEffect(.degrees(-90))              // Start from the top
            VStack(spacing: 4) {
                Text("\(consumed)")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .contentTransition(.numericText())      // Numbers roll when they change
                Text("of \(goal) kcal")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.spring(duration: 1.2)) { animatedProgress = progress }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.spring) { animatedProgress = newValue }
        }
        .accessibilityElement(children: .ignore)            // VoiceOver reads one clear sentence
        .accessibilityLabel("\(consumed) of \(goal) calories eaten today")
    }
}

#Preview {
    CalorieRing(consumed: 1250, goal: 2000)
}
