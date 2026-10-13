import SwiftUI
import SwiftData
import PhotosUI

/// Add Meal screen: pick a photo, get AI suggestions, adjust, save.
struct AddMealView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = AddMealViewModel()

    var body: some View {
        NavigationStack {
            Form {
                // Photo picker
                Section {
                    PhotosPicker(selection: $viewModel.pickerItem, matching: .images) {
                        photoArea
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Choose a meal photo")
                }
                .listRowInsets(EdgeInsets())

                // AI working indicator
                if viewModel.isAnalysing {
                    Section {
                        Label("Analysing your meal…", systemImage: "sparkles")
                            .symbolEffect(.pulse)
                            .foregroundStyle(.purple)
                    }
                }

                // AI suggestions
                if !viewModel.suggestions.isEmpty {
                    Section("AI suggestions") {
                        ForEach(viewModel.suggestions) { suggestion in
                            Button {
                                viewModel.select(suggestion.food, confidence: suggestion.confidence)
                            } label: {
                                HStack {
                                    Text(suggestion.food.name)
                                    Spacer()
                                    Text("\(Int(suggestion.confidence * 100))%")
                                        .foregroundStyle(.secondary)
                                    if viewModel.name == suggestion.food.name {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(.green)
                                    }
                                }
                            }
                            .tint(.primary)
                        }
                    }
                }

                // When the AI isn't confident, offer local dishes
                if viewModel.isUnsure {
                    Section {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(FoodDatabase.sriLankan) { food in
                                    Button(food.name) { viewModel.select(food) }
                                        .buttonStyle(.bordered)
                                        .tint(viewModel.name == food.name ? .green : .secondary)
                                }
                            }
                        }
                    } header: {
                        Label("Not sure. Is it a Sri Lankan dish?", systemImage: "questionmark.circle")
                    } footer: {
                        Text("The AI model wasn't trained on local dishes. Tap one to fill it in.")
                    }
                }

                // What the AI saw (transparency)
                if !viewModel.detectedLabels.isEmpty {
                    Section("AI saw") {
                        Text(viewModel.detectedLabels.joined(separator: ", "))
                            .foregroundStyle(.secondary)
                    }
                }

                // Manual details
                Section("Meal details") {
                    TextField("Meal name", text: $viewModel.name)
                    Stepper("\(viewModel.calories) kcal",
                            value: $viewModel.calories, in: 0...3000, step: 10)
                    Picker("Meal", selection: $viewModel.type) {
                        ForEach(MealType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    Menu("Choose a Sri Lankan dish", systemImage: "list.bullet") {
                        ForEach(FoodDatabase.sriLankan) { food in
                            Button("\(food.name) · \(food.calories) kcal") {
                                viewModel.select(food)
                            }
                        }
                    }
                }

                if let error = viewModel.errorMessage {
                    Section {
                        Text(error).foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Add Meal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.save(in: context)
                        dismiss()
                    }
                    .disabled(!viewModel.canSave)
                }
            }
            .onChange(of: viewModel.pickerItem) {
                Task { await viewModel.loadPhoto() }
            }
        }
    }

    /// Shows the chosen photo, or a placeholder.
    @ViewBuilder
    private var photoArea: some View {
        if let image = viewModel.image {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(height: 220)
                .clipped()
                .transition(.opacity.combined(with: .scale))
        } else {
            VStack(spacing: 8) {
                Image(systemName: "camera.fill").font(.largeTitle)
                Text("Choose a meal photo").font(.headline)
                Text("AI will identify the food").font(.caption).foregroundStyle(.secondary)
            }
            .foregroundStyle(.green)
            .frame(maxWidth: .infinity)
            .frame(height: 220)
            .background(.green.opacity(0.1))
        }
    }
}
