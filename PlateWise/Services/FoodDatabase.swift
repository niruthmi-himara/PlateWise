import Foundation

/// A known food with typical calories per serving.
struct FoodItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let calories: Int
    let keywords: [String]          // Words the AI model might return for this food
    var isSriLankan = false
}

/// Local food list used to turn AI labels into meals with calories.
enum FoodDatabase {
    static let items: [FoodItem] = [
        // Sri Lankan dishes (chosen from the menu; the model doesn't know these by name)
        FoodItem(name: "Rice and curry", calories: 650, keywords: ["curry"], isSriLankan: true),
        FoodItem(name: "Kottu roti", calories: 750, keywords: ["kottu"], isSriLankan: true),
        FoodItem(name: "Egg hopper", calories: 190, keywords: ["hopper"], isSriLankan: true),
        FoodItem(name: "String hoppers (10)", calories: 350, keywords: ["string hopper"], isSriLankan: true),
        FoodItem(name: "Pol roti", calories: 220, keywords: ["roti"], isSriLankan: true),
        FoodItem(name: "Kiribath (milk rice)", calories: 300, keywords: ["kiribath"], isSriLankan: true),
        FoodItem(name: "Dhal curry", calories: 180, keywords: ["dhal"], isSriLankan: true),
        FoodItem(name: "Fish bun", calories: 280, keywords: ["fish bun"], isSriLankan: true),
        // Foods the model can recognise
        FoodItem(name: "Burger", calories: 550, keywords: ["cheeseburger", "burger"]),
        FoodItem(name: "Pizza slice", calories: 285, keywords: ["pizza"]),
        FoodItem(name: "Hot dog", calories: 290, keywords: ["hotdog", "hot dog"]),
        FoodItem(name: "Burrito", calories: 450, keywords: ["burrito"]),
        FoodItem(name: "Pasta carbonara", calories: 600, keywords: ["carbonara", "spaghetti"]),
        FoodItem(name: "Salad", calories: 150, keywords: ["salad", "cabbage", "broccoli",
                                                        "cucumber", "bell pepper", "guacamole"]),
        FoodItem(name: "Soup", calories: 150, keywords: ["consomme", "hot pot", "soup"]),
        FoodItem(name: "Mashed potato", calories: 210, keywords: ["mashed potato"]),
        FoodItem(name: "Bread", calories: 160, keywords: ["loaf", "bagel", "pretzel"]),
        FoodItem(name: "Banana", calories: 105, keywords: ["banana"]),
        FoodItem(name: "Fruit bowl", calories: 120, keywords: ["orange", "lemon", "pineapple", "strawberry",
                                                            "pomegranate", "fig", "granny smith", "jackfruit"]),
        FoodItem(name: "Ice cream", calories: 210, keywords: ["ice cream", "icecream"]),
        FoodItem(name: "Dessert", calories: 350, keywords: ["trifle", "chocolate sauce"]),
        FoodItem(name: "Coffee", calories: 60, keywords: ["espresso"]),
        FoodItem(name: "Tea with milk", calories: 90, keywords: ["cup", "teapot"]),
    ]

    static var sriLankan: [FoodItem] { items.filter(\.isSriLankan) }

    /// Finds foods whose keywords appear in an AI label, e.g. "cheeseburger" → Burger
    static func matches(for label: String) -> [FoodItem] {
        let label = label.lowercased()
        return items.filter { item in item.keywords.contains { label.contains($0) } }
    }
}
