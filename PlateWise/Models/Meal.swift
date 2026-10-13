import Foundation
import SwiftData

/// The type of meal, used for grouping and icons.
enum MealType: String, Codable, CaseIterable, Identifiable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snack = "Snack"

    var id: String { rawValue }

    /// SF Symbol icon for each meal type
    var icon: String {
        switch self {
        case .breakfast: return "sun.horizon.fill"
        case .lunch: return "sun.max.fill"
        case .dinner: return "moon.stars.fill"
        case .snack: return "carrot.fill"
        }
    }
}

/// A single logged meal, saved permanently with SwiftData.
@Model
final class Meal {
    var name: String
    var calories: Int
    var typeRaw: String                 // MealType stored as text
    var date: Date
    @Attribute(.externalStorage)        // Big photos saved outside the database for performance
    var photoData: Data?
    var aiConfidence: Double?           // How sure the AI was (0–1), nil if entered manually

    var type: MealType {
        get { MealType(rawValue: typeRaw) ?? .snack }
        set { typeRaw = newValue.rawValue }
    }

    init(name: String, calories: Int, type: MealType,
         date: Date = .now, photoData: Data? = nil, aiConfidence: Double? = nil) {
        self.name = name
        self.calories = calories
        self.typeRaw = type.rawValue
        self.date = date
        self.photoData = photoData
        self.aiConfidence = aiConfidence
    }
}
