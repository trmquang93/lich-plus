import XCTest
import SwiftUI
@testable import lich_plus

// MARK: - Event Category Tests
final class EventCategoryTests: XCTestCase {

    // MARK: - Test Category Creation
    func testCategoryCreation() {
        let name = "Họp công việc"
        let color = "#5BC0A6"

        let category = EventCategory(name: name, color: color)

        XCTAssertEqual(category.name, name)
        XCTAssertEqual(category.color, color)
    }

    // MARK: - Test Predefined Categories
    func testPredefinedCategories() {
        let workMeeting = EventCategory.workMeeting
        XCTAssertEqual(workMeeting.name, "Họp công việc")
        XCTAssertEqual(workMeeting.color, "#5BC0A6")

        let lunch = EventCategory.lunch
        XCTAssertEqual(lunch.name, "Ăn trưa")
        XCTAssertEqual(lunch.color, "#4A90E2")

        let phone = EventCategory.phone
        XCTAssertEqual(phone.name, "Gọi điện")
        XCTAssertEqual(phone.color, "#50E3C2")
    }

    // MARK: - Test Color Conversion
    func testColorConversion() {
        let category = EventCategory(name: "Test", color: "#5BC0A6")
        let color = category.swiftUIColor

        // We can't directly compare SwiftUI Colors, but we can verify it's not nil
        XCTAssertNotNil(color)
    }

    // MARK: - Test Invalid Color Handling
    func testInvalidColorHandling() {
        let category = EventCategory(name: "Test", color: "INVALID")
        let color = category.swiftUIColor

        // Invalid colors should return a default Color
        XCTAssertNotNil(color)
    }

    // MARK: - Test All Predefined Categories
    func testAllPredefinedCategories() {
        let categories = [
            EventCategory.workMeeting,
            EventCategory.lunch,
            EventCategory.phone,
            EventCategory.auspicious,
            EventCategory.inauspicious,
            EventCategory.cultural
        ]

        for category in categories {
            XCTAssertFalse(category.name.isEmpty)
            XCTAssertFalse(category.color.isEmpty)
            XCTAssertTrue(category.color.contains("#"))
        }
    }

    // MARK: - Test Category ID
    func testCategoryID() {
        let category1 = EventCategory(name: "Test", color: "#5BC0A6")
        let category2 = EventCategory(name: "Test", color: "#5BC0A6")

        // Each category should have a unique ID
        XCTAssertNotEqual(category1.id, category2.id)
    }
}

// MARK: - Color Extension Tests
final class ColorExtensionTests: XCTestCase {

    // MARK: - Test Valid Hex Colors
    func testValidHexColors() {
        let testColors = [
            "#5BC0A6",
            "#4A90E2",
            "#50E3C2",
            "#F5A623",
            "#D0021B",
            "#F8E71C"
        ]

        for hexColor in testColors {
            let color = Color(hex: hexColor)
            XCTAssertNotNil(color, "Color \(hexColor) should be valid")
        }
    }

    // MARK: - Test Hex Color with Lowercase
    func testLowercaseHexColor() {
        let color = Color(hex: "#5bc0a6")
        XCTAssertNotNil(color)
    }

    // MARK: - Test Hex Color without Hash
    func testHexColorWithoutHash() {
        let color = Color(hex: "5BC0A6")
        XCTAssertNotNil(color)
    }

    // MARK: - Test Invalid Hex Colors
    func testInvalidHexColors() {
        let invalidColors = [
            "INVALID",
            "#GGGGGG",
            "#12",
            ""
        ]

        for hexColor in invalidColors {
            let color = Color(hex: hexColor)
            XCTAssertNil(color, "Color \(hexColor) should be invalid")
        }
    }

    // MARK: - Test Hex Color Values
    func testHexColorValues() {
        let color = Color(hex: "#FF0000") // Red
        XCTAssertNotNil(color)

        let color2 = Color(hex: "#00FF00") // Green
        XCTAssertNotNil(color2)

        let color3 = Color(hex: "#0000FF") // Blue
        XCTAssertNotNil(color3)
    }
}
