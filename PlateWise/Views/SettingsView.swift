import SwiftUI
import SwiftData

/// The app's colour theme choice, saved in @AppStorage.
enum AppearanceMode: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"

    var id: String { rawValue }

    /// nil means "follow the iPhone's setting"
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

/// Settings screen: daily goal, theme, demo data and app info.
struct SettingsView: View {
    @Environment(\.modelContext) private var context
    @AppStorage("dailyGoal") private var dailyGoal = 2000
    @AppStorage("appearance") private var appearance: AppearanceMode = .system
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = true
    @State private var showingDeleteConfirm = false
    @State private var showingDemoAlert = false

    var body: some View {
        NavigationStack {
            Form {
                // Daily goal
                Section {
                    Stepper(value: $dailyGoal, in: 1200...4000, step: 50) {
                        LabeledContent("Daily goal", value: "\(dailyGoal) kcal")
                    }
                } header: {
                    Text("Goal")
                } footer: {
                    Text("Used for the ring on Today and the goal line in History.")
                }

                // Theme (Dark Mode support)
                Section("Appearance") {
                    Picker("Theme", selection: $appearance) {
                        ForEach(AppearanceMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // Data
                Section {
                    Button("Load demo data", systemImage: "wand.and.stars") {
                        DemoData.load(into: context)
                        showingDemoAlert = true
                    }
                    Button("Delete all meals", systemImage: "trash", role: .destructive) {
                        showingDeleteConfirm = true
                    }
                } header: {
                    Text("Data")
                } footer: {
                    Text("Demo data adds sample meals for the past 29 days so the charts can be shown.")
                }

                // About
                Section("About") {
                    LabeledContent("Version",
                                   value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                    LabeledContent("AI model", value: "MobileNetV2 (Core ML)")
                    Button("Show welcome screens again", systemImage: "hand.wave") {
                        hasSeenOnboarding = false
                    }
                    Label("Photos are analysed on your device and never uploaded.",
                          systemImage: "lock.shield")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
            .confirmationDialog("Delete all meals?",
                                isPresented: $showingDeleteConfirm,
                                titleVisibility: .visible) {
                Button("Delete All", role: .destructive) {
                    try? context.delete(model: Meal.self)
                }
            } message: {
                Text("This can't be undone.")
            }
            .alert("Demo data added", isPresented: $showingDemoAlert) {
                Button("OK") { }
            } message: {
                Text("Open the History tab to see the charts.")
            }
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: Meal.self, inMemory: true)
}
