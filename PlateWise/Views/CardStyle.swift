import SwiftUI

/// Custom ViewModifier: gives any view the app's rounded card look.
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.background.secondary, in: RoundedRectangle(cornerRadius: 20))
    }
}

extension View {
    /// Usage: anyView.cardStyle()
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}
