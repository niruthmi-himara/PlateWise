import SwiftUI
import SwiftData

/// Root view: the three main tabs, with the app's brand colour and chosen theme.
/// Shows the onboarding walkthrough the first time the app is opened.
struct ContentView: View {
    @AppStorage("appearance") private var appearance: AppearanceMode = .system
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some View {
        TabView {
            Tab("Today", systemImage: "fork.knife") {
                TodayView()
            }
            Tab("History", systemImage: "chart.bar.fill") {
                HistoryView()
            }
            Tab("Settings", systemImage: "gearshape.fill") {
                SettingsView()
            }
        }
        .tint(.green)                                    // Brand colour for buttons and tabs
        .preferredColorScheme(appearance.colorScheme)    // Light / Dark / System
        .fullScreenCover(isPresented: Binding(
            get: { !hasSeenOnboarding },
            set: { hasSeenOnboarding = !$0 }
        )) {
            OnboardingView()
                .preferredColorScheme(appearance.colorScheme)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Meal.self, inMemory: true)
}
