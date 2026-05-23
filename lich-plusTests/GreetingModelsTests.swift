//
//  GreetingModelsTests.swift
//  lich-plusTests
//
//  Tests for Greetings feature models
//  Verifies RecipientType, GreetingTone, GreetingOccasion, GreetingRequest, and GeneratedGreeting
//

import XCTest
@testable import lich_plus

@MainActor
final class GreetingModelsTests: XCTestCase {

    // MARK: - RecipientType Tests

    func testRecipientTypeDisplayNames() {
        XCTAssertEqual(RecipientType.grandparents.displayName, "Ông bà")
        XCTAssertEqual(RecipientType.parents.displayName, "Cha mẹ")
        XCTAssertEqual(RecipientType.boss.displayName, "Sếp")
        XCTAssertEqual(RecipientType.colleagues.displayName, "Đồng nghiệp")
        XCTAssertEqual(RecipientType.teachers.displayName, "Giáo viên")
        XCTAssertEqual(RecipientType.friends.displayName, "Bạn bè")
        XCTAssertEqual(RecipientType.partner.displayName, "Vợ chồng")
        XCTAssertEqual(RecipientType.children.displayName, "Con cái")
    }

    func testRecipientTypeIcons() {
        // Verify each recipient type has a valid SF Symbol icon
        XCTAssertEqual(RecipientType.grandparents.icon, "figure.2.and.child.holdinghands")
        XCTAssertEqual(RecipientType.parents.icon, "figure.2")
        XCTAssertEqual(RecipientType.boss.icon, "briefcase.fill")
        XCTAssertEqual(RecipientType.colleagues.icon, "person.3.fill")
        XCTAssertEqual(RecipientType.teachers.icon, "graduationcap.fill")
        XCTAssertEqual(RecipientType.friends.icon, "person.2.fill")
        XCTAssertEqual(RecipientType.partner.icon, "heart.fill")
        XCTAssertEqual(RecipientType.children.icon, "face.smiling.fill")
    }

    func testRecipientTypeCaseIterable() {
        // Verify CaseIterable conformance
        let allCases = RecipientType.allCases
        XCTAssertEqual(allCases.count, 8)

        // Verify all expected cases are present
        XCTAssertTrue(allCases.contains(.grandparents))
        XCTAssertTrue(allCases.contains(.parents))
        XCTAssertTrue(allCases.contains(.boss))
        XCTAssertTrue(allCases.contains(.colleagues))
        XCTAssertTrue(allCases.contains(.teachers))
        XCTAssertTrue(allCases.contains(.friends))
        XCTAssertTrue(allCases.contains(.partner))
        XCTAssertTrue(allCases.contains(.children))
    }

    func testRecipientTypeIdentifiable() {
        // Verify Identifiable conformance - id should match rawValue
        XCTAssertEqual(RecipientType.grandparents.id, "grandparents")
        XCTAssertEqual(RecipientType.parents.id, "parents")
        XCTAssertEqual(RecipientType.boss.id, "boss")
        XCTAssertEqual(RecipientType.colleagues.id, "colleagues")
        XCTAssertEqual(RecipientType.teachers.id, "teachers")
        XCTAssertEqual(RecipientType.friends.id, "friends")
        XCTAssertEqual(RecipientType.partner.id, "partner")
        XCTAssertEqual(RecipientType.children.id, "children")
    }

    // MARK: - GreetingTone Tests

    func testGreetingToneDisplayNames() {
        XCTAssertEqual(GreetingTone.formal.displayName, "Trang trọng")
        XCTAssertEqual(GreetingTone.casual.displayName, "Thân mật")
        XCTAssertEqual(GreetingTone.funny.displayName, "Vui vẻ")
        XCTAssertEqual(GreetingTone.romantic.displayName, "Lãng mạn")
    }

    func testGreetingToneIcons() {
        // Verify each tone has a valid SF Symbol icon
        XCTAssertEqual(GreetingTone.formal.icon, "text.quote")
        XCTAssertEqual(GreetingTone.casual.icon, "hand.wave.fill")
        XCTAssertEqual(GreetingTone.funny.icon, "face.smiling.fill")
        XCTAssertEqual(GreetingTone.romantic.icon, "heart.fill")
    }

    func testGreetingToneCaseIterable() {
        // Verify CaseIterable conformance
        let allCases = GreetingTone.allCases
        XCTAssertEqual(allCases.count, 4)

        // Verify all expected cases are present
        XCTAssertTrue(allCases.contains(.formal))
        XCTAssertTrue(allCases.contains(.casual))
        XCTAssertTrue(allCases.contains(.funny))
        XCTAssertTrue(allCases.contains(.romantic))
    }

    func testGreetingToneIdentifiable() {
        // Verify Identifiable conformance - id should match rawValue
        XCTAssertEqual(GreetingTone.formal.id, "formal")
        XCTAssertEqual(GreetingTone.casual.id, "casual")
        XCTAssertEqual(GreetingTone.funny.id, "funny")
        XCTAssertEqual(GreetingTone.romantic.id, "romantic")
    }

    // MARK: - GreetingOccasion Tests

    func testGreetingOccasionDisplayNames() {
        XCTAssertEqual(GreetingOccasion.tet.displayName, "Chúc Tết")
        XCTAssertEqual(GreetingOccasion.birthday.displayName, "Sinh nhật")
        XCTAssertEqual(GreetingOccasion.wedding.displayName, "Cưới hỏi")
        XCTAssertEqual(GreetingOccasion.housewarming.displayName, "Mừng tân gia")
        XCTAssertEqual(GreetingOccasion.newYear.displayName, "Năm mới dương lịch")
        XCTAssertEqual(GreetingOccasion.womensDay.displayName, "Ngày 8/3")
        XCTAssertEqual(GreetingOccasion.teachersDay.displayName, "Ngày Nhà giáo")
    }

    func testGreetingOccasionIcons() {
        // Verify each occasion has an emoji icon
        XCTAssertEqual(GreetingOccasion.tet.icon, "🧧")
        XCTAssertEqual(GreetingOccasion.birthday.icon, "🎂")
        XCTAssertEqual(GreetingOccasion.wedding.icon, "💒")
        XCTAssertEqual(GreetingOccasion.housewarming.icon, "🏠")
        XCTAssertEqual(GreetingOccasion.newYear.icon, "🎉")
        XCTAssertEqual(GreetingOccasion.womensDay.icon, "🌷")
        XCTAssertEqual(GreetingOccasion.teachersDay.icon, "📚")
    }

    func testGreetingOccasionCaseIterable() {
        // Verify CaseIterable conformance
        let allCases = GreetingOccasion.allCases
        XCTAssertEqual(allCases.count, 7)

        // Verify all expected cases are present
        XCTAssertTrue(allCases.contains(.tet))
        XCTAssertTrue(allCases.contains(.birthday))
        XCTAssertTrue(allCases.contains(.wedding))
        XCTAssertTrue(allCases.contains(.housewarming))
        XCTAssertTrue(allCases.contains(.newYear))
        XCTAssertTrue(allCases.contains(.womensDay))
        XCTAssertTrue(allCases.contains(.teachersDay))
    }

    func testGreetingOccasionZodiacAnimal() {
        // Test known years and their zodiac animals
        let testCases: [(year: Int, expected: String)] = [
            (2024, "🐉 Thìn"),  // Dragon
            (2025, "🐍 Tỵ"),    // Snake
            (2026, "🐴 Ngọ"),   // Horse
            (2027, "🐐 Mùi"),   // Goat
            (2028, "🐒 Thân"),  // Monkey
            (2029, "🐓 Dậu"),   // Rooster
            (2030, "🐕 Tuất")   // Dog
        ]

        for testCase in testCases {
            let result = GreetingOccasion.zodiacAnimal(for: testCase.year)
            XCTAssertEqual(result, testCase.expected,
                           "Year \(testCase.year) should have zodiac \(testCase.expected)")
        }
    }

    func testGreetingOccasionCanChi() {
        // Test known years and their Can-Chi
        let testCases: [(year: Int, expected: String)] = [
            (2024, "Giáp Thìn"),  // Giap Thin
            (2025, "Ất Tỵ"),      // At Ty
            (2026, "Bính Ngọ"),   // Binh Ngo
            (2027, "Đinh Mùi"),   // Dinh Mui
            (2028, "Mậu Thân"),   // Mau Than
            (2029, "Kỷ Dậu"),     // Ky Dau
            (2030, "Canh Tuất")   // Canh Tuat
        ]

        for testCase in testCases {
            let result = GreetingOccasion.canChi(for: testCase.year)
            XCTAssertEqual(result, testCase.expected,
                           "Year \(testCase.year) should have Can-Chi \(testCase.expected)")
        }
    }

    func testGreetingOccasionTetZodiacAnimal() {
        // Only .tet occasion should return zodiac animal
        XCTAssertNotNil(GreetingOccasion.tet.tetZodiacAnimal)

        // Other occasions should return nil
        XCTAssertNil(GreetingOccasion.birthday.tetZodiacAnimal)
        XCTAssertNil(GreetingOccasion.wedding.tetZodiacAnimal)
        XCTAssertNil(GreetingOccasion.newYear.tetZodiacAnimal)
        XCTAssertNil(GreetingOccasion.womensDay.tetZodiacAnimal)
        XCTAssertNil(GreetingOccasion.teachersDay.tetZodiacAnimal)
    }

    // MARK: - GreetingRequest Tests

    func testGreetingRequestDefaultInitializer() {
        let request = GreetingRequest(
            recipientType: .parents,
            tone: .formal
        )

        XCTAssertEqual(request.recipientType, .parents)
        XCTAssertEqual(request.tone, .formal)
        XCTAssertEqual(request.occasion, .tet) // Default
        XCTAssertNil(request.recipientName) // Default nil
        XCTAssertEqual(request.year, Calendar.current.component(.year, from: Date())) // Current year
    }

    func testGreetingRequestCustomInitializer() {
        let request = GreetingRequest(
            recipientType: .boss,
            tone: .casual,
            occasion: .newYear,
            recipientName: "Nguyễn Văn A",
            year: 2026
        )

        XCTAssertEqual(request.recipientType, .boss)
        XCTAssertEqual(request.tone, .casual)
        XCTAssertEqual(request.occasion, .newYear)
        XCTAssertEqual(request.recipientName, "Nguyễn Văn A")
        XCTAssertEqual(request.year, 2026)
    }

    func testGreetingRequestWithoutRecipientName() {
        let request = GreetingRequest(
            recipientType: .friends,
            tone: .funny,
            occasion: .tet,
            recipientName: nil,
            year: 2025
        )

        XCTAssertNil(request.recipientName)
    }

    // MARK: - GeneratedGreeting Tests

    func testGeneratedGreetingInitialization() {
        let request = GreetingRequest(
            recipientType: .parents,
            tone: .formal,
            occasion: .tet,
            year: 2026
        )

        let greeting = GeneratedGreeting(
            text: "Chúc mừng năm mới!",
            request: request
        )

        XCTAssertEqual(greeting.text, "Chúc mừng năm mới!")
        XCTAssertEqual(greeting.request.recipientType, .parents)
        XCTAssertEqual(greeting.request.tone, .formal)
        XCTAssertNotNil(greeting.id) // UUID should be generated
        XCTAssertNotNil(greeting.createdAt)
    }

    func testGeneratedGreetingUniqueIDs() {
        let request = GreetingRequest(
            recipientType: .friends,
            tone: .casual
        )

        let greeting1 = GeneratedGreeting(text: "Hello", request: request)
        let greeting2 = GeneratedGreeting(text: "World", request: request)

        // Each greeting should have a unique UUID
        XCTAssertNotEqual(greeting1.id, greeting2.id)
    }

    func testGeneratedGreetingEquatable() {
        let request = GreetingRequest(
            recipientType: .parents,
            tone: .formal
        )

        let greeting1 = GeneratedGreeting(text: "Same text", request: request)
        let greeting2 = GeneratedGreeting(text: "Same text", request: request)

        // Equatable is based on ID, so same-content greetings are not equal
        XCTAssertNotEqual(greeting1, greeting2)

        // Same greeting should equal itself
        XCTAssertEqual(greeting1, greeting1)
    }

    func testGeneratedGreetingIdentifiable() {
        let request = GreetingRequest(
            recipientType: .boss,
            tone: .formal
        )

        let greeting = GeneratedGreeting(text: "Test", request: request)

        // id property should exist (Identifiable conformance)
        XCTAssertNotNil(greeting.id)
    }
}
