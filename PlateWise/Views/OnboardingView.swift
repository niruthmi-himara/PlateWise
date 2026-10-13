import SwiftUI

/// One page of the onboarding walkthrough.
struct OnboardingPage {
    let icon: String
    let title: String
    let message: String
    let color: Color
}

/// First-launch walkthrough: explains the app, then lets the user set a daily goal.
struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("dailyGoal") private var dailyGoal = 2000
    @State private var page = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(icon: "fork.knife.circle.fill",
                       title: "Welcome to PlateWise",
                       message: "Track what you eat in seconds. Just snap a photo of your meal.",
                       color: .green),
        OnboardingPage(icon: "sparkles",
                       title: "AI that sees your food",
                       message: "On-device machine learning recognises your meal and fills in the calories. Your photos never leave your phone.",
                       color: .purple),
        OnboardingPage(icon: "leaf.fill",
                       title: "Made for Sri Lanka",
                       message: "Rice and curry, kottu, hoppers: local dishes are always one tap away.",
                       color: .orange)
    ]

    /// The goal page comes after the info pages.
    private var isLastPage: Bool { page == pages.count }

    var body: some View {
        VStack(spacing: 12) {
            TabView(selection: $page) {
                ForEach(pages.indices, id: \.self) { index in
                    infoPage(pages[index])
                        .tag(index)
                }
                goalPage
                    .tag(pages.count)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            Button(action: next) {
                Text(isLastPage ? "Get Started" : "Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 24)

            Button("Skip", action: finish)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .opacity(isLastPage ? 0 : 1)
                .disabled(isLastPage)
                .padding(.bottom, 8)
        }
        .background(
            LinearGradient(colors: [.green.opacity(0.18), .clear],
                           startPoint: .top, endPoint: .center)
                .ignoresSafeArea()
        )
    }

    // MARK: - Pages

    private func infoPage(_ item: OnboardingPage) -> some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: item.icon)
                .font(.system(size: 96))
                .foregroundStyle(item.color.gradient)
                .symbolEffect(.bounce, value: page)        // Icon bounces when the page changes
            Text(item.title)
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
            Text(item.message)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
            Spacer()
        }
        .accessibilityElement(children: .combine)
    }

    private var goalPage: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "target")
                .font(.system(size: 96))
                .foregroundStyle(.green.gradient)
                .symbolEffect(.bounce, value: page)
            Text("Set your daily goal")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
            Text("\(dailyGoal) kcal")
                .font(.system(.title, design: .rounded, weight: .semibold))
                .contentTransition(.numericText())
                .animation(.snappy, value: dailyGoal)
            Stepper("Daily goal", value: $dailyGoal, in: 1200...4000, step: 50)
                .labelsHidden()
            Text("You can change this later in Settings.")
                .font(.footnote)
                .foregroundStyle(.secondary)
            Spacer()
            Spacer()
        }
    }

    // MARK: - Actions

    private func next() {
        if isLastPage {
            finish()
        } else {
            withAnimation(.spring) { page += 1 }
        }
    }

    private func finish() {
        withAnimation { hasSeenOnboarding = true }
    }
}

#Preview {
    OnboardingView()
}
