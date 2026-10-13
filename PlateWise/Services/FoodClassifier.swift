import Foundation
import Vision
import CoreML

/// One suggested food with how confident the AI is.
struct FoodSuggestion: Identifiable {
    let id = UUID()
    let food: FoodItem
    let confidence: Double
}

/// Result of analysing a photo.
struct ClassificationResult {
    let suggestions: [FoodSuggestion]   // Matched foods with calories
    let topLabels: [String]             // What the AI saw (for transparency)
}

/// A simple label from the AI, safe to pass between threads.
struct DetectedLabel: Sendable {
    let identifier: String
    let confidence: Double
}

enum ClassifierError: Error {
    case modelNotFound
}

/// Recognises food using a Core ML model (MobileNetV2) run through the Vision framework.
/// Runs fully on-device: no internet needed and photos stay private.
struct FoodClassifier {
    func classify(_ imageData: Data) async throws -> ClassificationResult {
        // Run the ML model in the background so the UI stays smooth
        let labels = try await Task.detached(priority: .userInitiated) {
            try Self.runModel(on: imageData)
        }.value

        var suggestions: [FoodSuggestion] = []
        var seen = Set<String>()

        // Check the most likely labels and match them to our food list
        for label in labels.prefix(30) where label.confidence > 0.03 {
            for food in FoodDatabase.matches(for: label.identifier)
            where !seen.contains(food.name) {
                seen.insert(food.name)
                suggestions.append(FoodSuggestion(food: food, confidence: label.confidence))
            }
        }

        let topLabels = labels.prefix(5).map {
            "\(Self.cleanName($0.identifier)) \(Int($0.confidence * 100))%"
        }
        return ClassificationResult(suggestions: Array(suggestions.prefix(5)),
                                    topLabels: topLabels)
    }

    /// The model is loaded once and reused (faster and uses less memory).
    nonisolated(unsafe) private static var cachedModel: VNCoreMLModel?

    nonisolated private static func loadModel() throws -> VNCoreMLModel {
        if let cachedModel { return cachedModel }
        guard let url = Bundle.main.url(forResource: "MobileNetV2", withExtension: "mlmodelc") else {
            throw ClassifierError.modelNotFound
        }
        let config = MLModelConfiguration()
        #if targetEnvironment(simulator)
        config.computeUnits = .cpuOnly      // Simulator has no Neural Engine
        #endif
        let model = try VNCoreMLModel(for: MLModel(contentsOf: url, configuration: config))
        cachedModel = model
        return model
    }

    /// Runs the Core ML model on the photo and returns labels sorted by confidence.
    nonisolated private static func runModel(on imageData: Data) throws -> [DetectedLabel] {
        let model = try loadModel()
        let request = VNCoreMLRequest(model: model)
        request.imageCropAndScaleOption = .centerCrop
        let handler = VNImageRequestHandler(data: imageData)
        try handler.perform([request])

        let results = request.results as? [VNClassificationObservation] ?? []
        return results
            .map { DetectedLabel(identifier: $0.identifier, confidence: Double($0.confidence)) }
            .sorted { $0.confidence > $1.confidence }
    }

    /// Turns "pizza, pizza pie" into "pizza".
    nonisolated static func cleanName(_ identifier: String) -> String {
        let first = identifier.components(separatedBy: ",").first ?? identifier
        return first.replacingOccurrences(of: "_", with: " ")
    }
}
