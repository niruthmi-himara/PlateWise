import SwiftUI
import SwiftData

/// Shows one meal's full details, with a delete option.
struct MealDetailView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    let meal: Meal

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let data = meal.photoData, let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text(meal.name).font(.title.bold())
                    Label(meal.type.rawValue, systemImage: meal.type.icon)
                    Label("\(meal.calories) kcal", systemImage: "flame.fill")
                    Label(meal.date.formatted(date: .abbreviated, time: .shortened),
                          systemImage: "clock")
                    if let confidence = meal.aiConfidence {
                        Label("Identified by AI (\(Int(confidence * 100))% sure)",
                              systemImage: "sparkles")
                            .foregroundStyle(.purple)
                    }
                }
                .cardStyle()

                Button("Delete Meal", systemImage: "trash", role: .destructive) {
                    context.delete(meal)
                    dismiss()
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
        .navigationTitle(meal.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
