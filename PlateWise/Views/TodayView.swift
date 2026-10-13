import SwiftUI
import SwiftData

/// Home screen: brand header, today's calorie ring and meals grouped by type.
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
                    // Heading with today's date
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Today")
                            .font(.largeTitle.bold())
                        Text(Date.now.formatted(.dateTime.weekday(.wide).day().month(.wide)))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    CalorieRing(consumed: totalCalories, goal: dailyGoal)

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
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Meal.self) { meal in
                MealDetailView(meal: meal)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    BrandHeader()                           // Logo + app name in the top bar
                }
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

#Preview {
    TodayView()
        .modelContainer(for: Meal.self, inMemory: true)
}
