import SwiftUI
import SwiftData

/// TEMPORARY: lets us test the Today screen. Replaced with photo + AI in Step 4.
struct AddMealView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Photo + AI coming in Step 4")
                    .foregroundStyle(.secondary)
                Button("Add sample meal") {
                    context.insert(Meal(name: "Rice and curry", calories: 650, type: .lunch))
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .navigationTitle("Add Meal")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
