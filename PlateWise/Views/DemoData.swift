import Foundation
import SwiftData

/// Creates realistic sample meals for the past 29 days (for demos and testing charts).
enum DemoData {
    /// Typical choices for each meal, with the hour it's eaten.
    private static let menu: [(type: MealType, hour: Int, foods: [String])] = [
        (.breakfast, 8, ["Kiribath (milk rice)", "Egg hopper", "String hoppers (10)", "Pol roti", "Bread", "Banana"]),
        (.lunch, 13, ["Rice and curry", "Rice and curry", "Kottu roti", "Burger", "Pasta carbonara", "Salad"]),
        (.snack, 16, ["Fish bun", "Tea with milk", "Fruit bowl", "Ice cream", "Banana"]),
        (.dinner, 20, ["Kottu roti", "String hoppers (10)", "Rice and curry", "Pizza slice", "Soup", "Dhal curry"])
    ]

    @MainActor
    static func load(into context: ModelContext) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)

        for offset in 1...29 {
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }

            for slot in menu {
                // Skip some snacks so days look different
                if slot.type == .snack && Bool.random() { continue }

                guard let name = slot.foods.randomElement(),
                      let food = FoodDatabase.items.first(where: { $0.name == name }),
                      let date = calendar.date(byAdding: .hour, value: slot.hour, to: day) else { continue }

                context.insert(Meal(name: food.name,
                                    calories: food.calories,
                                    type: slot.type,
                                    date: date))
            }
        }
    }
}
