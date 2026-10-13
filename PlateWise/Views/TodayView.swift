import SwiftUI
import SwiftData

/// Home screen: today's calorie ring and meals grouped by type.
struct TodayView: View {
    @Query(sort: \Meal.date, order: .reverse) private var meals: [Meal]  // Auto-updates from SwiftData
    @AppStorage("dailyGoal") private var dailyGoal = 2000                 // Saved setting
    @State private var showingAddMeal = false

    private var todaysMeals: [Meal] {
        meals.filter { Calendar.current.isDateInToday($0.date) }
    }

    private var totalCalories: Int {
        todaysMeals.reduce(0) { $0 + $1.calories }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    CalorieRing(consumed: totalCalories, goal: dailyGoal)
                        .padding(.top)

                    if todaysMeals.isEmpty {
                        ContentUnavailableView("No meals yet",
                                               systemImage: "fork.knife.circle",
                                               description: Text("Tap + to snap your first meal."))
                    } else {
                        ForEach(MealType.allCases) { type in
                            let items = todaysMeals.filter { $0.type == type }
                            if !items.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Label(type.rawValue, systemImage: type.icon)
                                        .font(.headline)
                                    ForEach(items) { meal in
                                        NavigationLink(value: meal) {
                                            MealRow(meal: meal)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .cardStyle()                // Your custom modifier
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Today")
            .navigationDestination(for: Meal.self) { meal in
                MealDetailView(meal: meal)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add Meal", systemImage: "plus") { showingAddMeal = true }
                }
            }
            .sheet(isPresented: $showingAddMeal) {
                AddMealView()
            }
        }
    }
}

/// One row in the meal list.
struct MealRow: View {
    let meal: Meal

    var body: some View {
        HStack(spacing: 12) {
            MealThumbnail(data: meal.photoData)
            VStack(alignment: .leading, spacing: 2) {
                Text(meal.name).font(.body.weight(.semibold))
                Text(meal.date, style: .time)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text("\(meal.calories) kcal")
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(.secondary)
        }
        .contentShape(Rectangle())
    }
}

/// Small square photo, or an icon if there's no photo.
struct MealThumbnail: View {
    let data: Data?

    var body: some View {
        Group {
            if let data, let image = UIImage(data: data) {
                Image(uiImage: image).resizable().scaledToFill()
            } else {
                Image(systemName: "fork.knife")
                    .foregroundStyle(.green)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.green.opacity(0.15))
            }
        }
        .frame(width: 48, height: 48)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .accessibilityHidden(true)
    }
}
