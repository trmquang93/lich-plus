import Foundation
import SwiftUI
import SwiftData

// MARK: - Event Category Model
@Model
final class EventCategory: Identifiable {
    var id: UUID = UUID()
    var name: String
    var color: String // Stored as hex color code

    init(name: String, color: String) {
        self.name = name
        self.color = color
    }

    // Predefined categories with Vietnamese names
    static let workMeeting = EventCategory(name: "Họp công việc", color: "#5BC0A6")
    static let lunch = EventCategory(name: "Ăn trưa", color: "#4A90E2")
    static let phone = EventCategory(name: "Gọi điện", color: "#50E3C2")
    static let auspicious = EventCategory(name: "Giờ hoàng đạo", color: "#F5A623")
    static let inauspicious = EventCategory(name: "Giờ xấu", color: "#D0021B")
    static let cultural = EventCategory(name: "Sự kiện văn hóa", color: "#F8E71C")

    // MARK: - Color Helper
    var swiftUIColor: Color {
        Color(hex: color) ?? Color.blue
    }
}

// MARK: - Color Extension for Hex Support
extension Color {
    /// Initializes a Color from a hex string (e.g., "#5BC0A6" or "5BC0A6")
    /// Returns nil if the hex string is invalid (wrong length or non-hex characters)
    init?(hex: String) {
        let cleanHex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))

        // Hex color must be exactly 6 characters
        guard cleanHex.count == 6 else {
            return nil
        }

        guard let int = Int(cleanHex, radix: 16) else {
            return nil
        }

        let red = Double((int >> 16) & 0xFF) / 255.0
        let green = Double((int >> 8) & 0xFF) / 255.0
        let blue = Double(int & 0xFF) / 255.0

        self.init(red: red, green: green, blue: blue)
    }
}
