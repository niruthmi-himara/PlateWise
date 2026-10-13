import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Today", systemImage: "fork.knife") {
                TodayView()
            }
            Tab("History", systemImage: "chart.bar.fill") {
                Text("History screen")
            }
            Tab("Settings", systemImage: "gearshape.fill") {
                Text("Settings screen")
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Meal.self, inMemory: true)
}
