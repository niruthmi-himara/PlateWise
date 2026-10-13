import SwiftUI
import SwiftData
import Charts

/// Total calories for one day (used by the chart).
struct DailyTotal: Identifiable {
    let date: Date
    let calories: Int
    var id: Date { date }
}

/// Meals grouped under one day (used by the list).
struct DayGroup: Identifiable {
    let day: Date
    let meals: [Meal]
    var id: Date { day }
}

/// Time range shown in the chart.
enum HistoryRange: String, CaseIterable, Identifiable {
    case week = "7 Days"
    case month = "30 Days"

    var id: String { rawValue }
    var days: Int { self == .week ? 7 : 30 }
}

/// History screen: interactive calorie chart plus all meals grouped by day.
struct HistoryView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Meal.date, order: .reverse) private var meals: [Meal]
    @AppStorage("dailyGoal") private var dailyGoal = 2000
    @State private var range: HistoryRange = .week
    @State private var selectedDate: Date?          // Set when the user taps/drags on the chart

    // MARK: - Data for the chart

    private var dailyTotals: [DailyTotal] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let grouped = Dictionary(grouping: meals) { calendar.startOfDay(for: $0.date) }
        return (0..<range.days).reversed().compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            let total = grouped[day]?.reduce(0) { $0 + $1.calories } ?? 0
            return DailyTotal(date: day, calories: total)
        }
    }

    /// Average over days that have at least one meal logged.
    private var averageCalories: Int {
        let logged = dailyTotals.filter { $0.calories > 0 }
        guard !logged.isEmpty else { return 0 }
        return logged.reduce(0) { $0 + $1.calories } / logged.count
    }

    private var selectedTotal: DailyTotal? {
        guard let selectedDate else { return nil }
        return dailyTotals.first { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
    }

    // MARK: - Data for the list

    private var dayGroups: [DayGroup] {
        let grouped = Dictionary(grouping: meals) { Calendar.current.startOfDay(for: $0.date) }
        return grouped.keys.sorted(by: >).map { DayGroup(day: $0, meals: grouped[$0] ?? []) }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 16) {
                        Picker("Range", selection: $range.animation(.spring)) {
                            ForEach(HistoryRange.allCases) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                        .pickerStyle(.segmented)

                        summaryHeader
                        calorieChart
                    }
                    .padding(.vertical, 8)
                }

                if meals.isEmpty {
                    ContentUnavailableView("No history yet",
                                           systemImage: "chart.bar",
                                           description: Text("Meals you log will appear here."))
                } else {
                    ForEach(dayGroups) { group in
                        Section(group.day.formatted(date: .complete, time: .omitted)) {
                            ForEach(group.meals) { meal in
                                NavigationLink(value: meal) {
                                    MealRow(meal: meal)
                                }
                            }
                            .onDelete { offsets in
                                for index in offsets {
                                    context.delete(group.meals[index])
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("History")
            .navigationDestination(for: Meal.self) { meal in
                MealDetailView(meal: meal)
            }
        }
    }

    // MARK: - Pieces

    /// Shows the daily average, or the tapped day's total.
    private var summaryHeader: some View {
        VStack(alignment: .leading, spacing: 2) {
            if let selectedTotal {
                Text(selectedTotal.date.formatted(.dateTime.weekday(.wide).day().month()))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(selectedTotal.calories) kcal")
                    .font(.title2.bold())
            } else {
                Text("Daily average")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(averageCalories) kcal")
                    .font(.title2.bold())
            }
        }
        .contentTransition(.numericText())
        .animation(.snappy, value: selectedDate)
    }

    /// Bar chart of calories per day with a dashed goal line.
    private var calorieChart: some View {
        Chart {
            ForEach(dailyTotals) { day in
                BarMark(x: .value("Day", day.date, unit: .day),
                        y: .value("Calories", day.calories))
                    .foregroundStyle(day.calories > dailyGoal ? Color.orange.gradient : Color.green.gradient)
                    .cornerRadius(6)
                    .opacity(selectedTotal == nil || selectedTotal?.id == day.id ? 1 : 0.4)
            }
            RuleMark(y: .value("Goal", dailyGoal))
                .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [5]))
                .foregroundStyle(.secondary)
                .annotation(position: .top, alignment: .leading) {
                    Text("Goal \(dailyGoal)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
        }
        .chartXSelection(value: $selectedDate)          // Tap or drag to inspect a day
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: range == .week ? 1 : 5)) { _ in
                AxisValueLabel(format: range == .week
                               ? Date.FormatStyle().weekday(.abbreviated)
                               : Date.FormatStyle().day())
            }
        }
        .frame(height: 220)
        .accessibilityLabel("Calories per day. Daily average \(averageCalories) kcal.")
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: Meal.self, inMemory: true)
}
