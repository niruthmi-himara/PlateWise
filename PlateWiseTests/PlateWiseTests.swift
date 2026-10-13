import Testing
import Foundation
import SwiftData
import UIKit
@testable import PlateWise

/// Unit tests for PlateWise: model, food matching, image handling, ViewModel, persistence and Core ML.
@MainActor
struct PlateWiseTests {

    // MARK: - Meal model

    @Test func mealStoresTypeAsText() {
        let meal = Meal(name: "Kottu roti", calories: 750, type: .dinner)
        #expect(meal.typeRaw == "Dinner")
        #expect(meal.type == .dinner)
    }

    @Test func changingMealTypeUpdatesStoredText() {
        let meal = Meal(name: "Tea with milk", calories: 90, type: .snack)
        meal.type = .breakfast
        #expect(meal.typeRaw == "Breakfast")
    }

    // MARK: - Food database (turning AI labels into foods)

    @Test func cheeseburgerLabelMatchesBurger() {
        let names = FoodDatabase.matches(for: "cheeseburger").map(\.name)
        #expect(names.contains("Burger"))
    }

    @Test func labelMatchingIgnoresCase() {
        #expect(!FoodDatabase.matches(for: "PIZZA, pizza pie").isEmpty)
    }

    @Test func unknownLabelHasNoMatch() {
        #expect(FoodDatabase.matches(for: "sports car").isEmpty)
    }

    @Test func sriLankanListContainsLocalDishes() {
        let names = FoodDatabase.sriLankan.map(\.name)
        #expect(names.contains("Rice and curry"))
        #expect(names.contains("Kottu roti"))
        let allAreLocal = FoodDatabase.sriLankan.allSatisfy { $0.isSriLankan }
                #expect(allAreLocal)
    }

    // MARK: - Classifier helpers

    @Test(arguments: zip(["pizza, pizza pie", "ice_cream", "banana"],
                         ["pizza", "ice cream", "banana"]))
    func cleanNameShortensLabels(input: String, expected: String) {
        #expect(FoodClassifier.cleanName(input) == expected)
    }

    // MARK: - Image resizing (memory optimisation)

    private func solidImage(width: CGFloat, height: CGFloat) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: format).image { ctx in
            UIColor.red.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: width, height: height))
        }
    }

    @Test func largeImageIsShrunk() {
        let small = solidImage(width: 3000, height: 1500).resized(maxDimension: 1024)
        #expect(max(small.size.width, small.size.height) <= 1024)
    }

    @Test func smallImageIsUnchanged() {
        let image = solidImage(width: 500, height: 500)
        #expect(image.resized(maxDimension: 1024).size == image.size)
    }

    // MARK: - Add Meal ViewModel

    @Test func cannotSaveWithoutNameAndCalories() {
        let viewModel = AddMealViewModel()
        #expect(!viewModel.canSave)
        viewModel.name = "Salad"
        #expect(!viewModel.canSave)
        viewModel.calories = 150
        #expect(viewModel.canSave)
    }

    @Test func selectingFoodFillsTheForm() {
        let viewModel = AddMealViewModel()
        let food = FoodDatabase.sriLankan[0]
        viewModel.select(food)
        #expect(viewModel.name == food.name)
        #expect(viewModel.calories == food.calories)
    }

    @Test func notUnsureBeforeAnyAnalysis() {
        #expect(!AddMealViewModel().isUnsure)
    }

    // MARK: - Persistence (SwiftData)

    private func makeInMemoryContext() throws -> ModelContext {
        let container = try ModelContainer(for: Meal.self,
                                           configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        return ModelContext(container)
    }

    @Test func savedMealCanBeFetched() throws {
        let context = try makeInMemoryContext()
        let viewModel = AddMealViewModel()
        viewModel.name = "Egg hopper"
        viewModel.calories = 190
        viewModel.save(in: context)

        let meals = try context.fetch(FetchDescriptor<Meal>())
        #expect(meals.count == 1)
        #expect(meals.first?.name == "Egg hopper")
    }

    @Test func demoDataFills29PastDays() throws {
        let context = try makeInMemoryContext()
        DemoData.load(into: context)

        let meals = try context.fetch(FetchDescriptor<Meal>())
        let days = Set(meals.map { Calendar.current.startOfDay(for: $0.date) })
        #expect(days.count == 29)
        #expect(!meals.contains { Calendar.current.isDateInToday($0.date) })
    }

    // MARK: - Core ML integration

    @Test func coreMLModelReturnsLabels() async throws {
        let data = try #require(solidImage(width: 300, height: 300).jpegData(compressionQuality: 0.8))
        let result = try await FoodClassifier().classify(data)
        #expect(result.topLabels.count == 5)
    }
}
