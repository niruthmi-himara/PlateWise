import SwiftUI

extension MealType {
    /// Guesses the meal type from the time of day.
    static var forCurrentTime: MealType {
        switch Calendar.current.component(.hour, from: .now) {
        case 5..<11: return .breakfast
        case 11..<16: return .lunch
        case 18..<23: return .dinner
        default: return .snack
        }
    }
}

extension UIImage {
    /// Shrinks big photos so they use less memory and storage.
    func resized(maxDimension: CGFloat) -> UIImage {
        let scale = min(1, maxDimension / max(size.width, size.height))
        guard scale < 1 else { return self }
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        return UIGraphicsImageRenderer(size: newSize).image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
