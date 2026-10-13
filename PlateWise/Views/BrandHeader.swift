import SwiftUI

/// Reusable brand header: the app's logo next to its name.
struct BrandHeader: View {
    @ScaledMetric private var logoSize: CGFloat = 28      // Grows with Dynamic Type

    var body: some View {
        HStack(spacing: 8) {
            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(width: logoSize, height: logoSize)
                .clipShape(RoundedRectangle(cornerRadius: logoSize * 0.25, style: .continuous))
            Text("PlateWise")
                .font(.system(.title3, design: .rounded, weight: .bold))
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("PlateWise")
        .accessibilityAddTraits(.isHeader)
    }
}

#Preview {
    BrandHeader()
}
