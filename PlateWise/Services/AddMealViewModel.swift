import SwiftUI
import SwiftData
import PhotosUI

/// ViewModel for the Add Meal screen: loads the photo, runs AI, and saves the meal.
@Observable
@MainActor
final class AddMealViewModel {
    // Photo
    var pickerItem: PhotosPickerItem?
    var image: UIImage?
    private var imageData: Data?

    // AI state
    var isAnalysing = false
    var suggestions: [FoodSuggestion] = []
    var detectedLabels: [String] = []
    var errorMessage: String?
    private(set) var hasAnalysed = false

    /// True when the AI's best guess is weak, e.g. Sri Lankan dishes the model wasn't trained on.
    var isUnsure: Bool {
        guard hasAnalysed else { return false }
        return (suggestions.first?.confidence ?? 0) < 0.3
    }

    // Form fields
    var name = ""
    var calories = 0
    var type: MealType = .forCurrentTime
    private var aiConfidence: Double?

    private let classifier = FoodClassifier()

    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && calories > 0
    }

    /// Loads the chosen photo, shrinks it to save memory, then runs the AI.
    func loadPhoto() async {
        guard let pickerItem else { return }
        errorMessage = nil
        hasAnalysed = false
        do {
            guard let data = try await pickerItem.loadTransferable(type: Data.self),
                  let original = UIImage(data: data) else { return }
            let resized = original.resized(maxDimension: 1024)   // Performance: smaller image
            withAnimation(.spring) { image = resized }
            imageData = resized.jpegData(compressionQuality: 0.7)
            await analyse()
        } catch {
            errorMessage = "Couldn't load that photo."
        }
    }

    private func analyse() async {
        guard let imageData else { return }
        isAnalysing = true
        defer { isAnalysing = false }
        do {
            let result = try await classifier.classify(imageData)
            withAnimation(.spring) {
                suggestions = result.suggestions
                detectedLabels = result.topLabels
                hasAnalysed = true
            }
            if let best = suggestions.first, best.confidence >= 0.3 {
                select(best.food, confidence: best.confidence)   // Only auto-fill confident guesses
            }
        } catch {
            errorMessage = "The AI couldn't analyse this photo. You can still enter the meal manually."
        }
    }

    func select(_ food: FoodItem, confidence: Double? = nil) {
        name = food.name
        calories = food.calories
        aiConfidence = confidence
    }

    func save(in context: ModelContext) {
        let meal = Meal(name: name.trimmingCharacters(in: .whitespaces),
                        calories: calories,
                        type: type,
                        photoData: imageData,
                        aiConfidence: aiConfidence)
        context.insert(meal)
    }
}
