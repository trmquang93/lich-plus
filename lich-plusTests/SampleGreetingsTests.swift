//
//  SampleGreetingsTests.swift
//  lich-plusTests
//
//  Tests for SampleGreetings offline greeting generation
//  Verifies template coverage, randomization, and name replacement
//

import XCTest
@testable import lich_plus

@MainActor
final class SampleGreetingsTests: XCTestCase {

    // MARK: - Template Coverage Tests

    func testRandomGreetingReturnsNonEmptyForAllRecipientTypes() {
        let tones: [GreetingTone] = [.formal, .casual, .funny, .romantic]
        let year = 2026

        // Test all 8 recipient types
        for recipientType in RecipientType.allCases {
            for tone in tones {
                let request = GreetingRequest(
                    recipientType: recipientType,
                    tone: tone,
                    occasion: .tet,
                    year: year
                )

                let greeting = SampleGreetings.randomGreeting(for: request)

                XCTAssertFalse(greeting.isEmpty,
                               "Greeting should not be empty for \(recipientType.displayName) + \(tone.displayName)")
                XCTAssertGreaterThan(greeting.count, 10,
                                     "Greeting should be meaningful length for \(recipientType.displayName) + \(tone.displayName)")
            }
        }
    }

    func testRandomGreetingReturnsNonEmptyForAllTones() {
        let recipientTypes: [RecipientType] = [.parents, .friends, .boss, .partner]
        let year = 2026

        for recipientType in recipientTypes {
            for tone in GreetingTone.allCases {
                let request = GreetingRequest(
                    recipientType: recipientType,
                    tone: tone,
                    occasion: .tet,
                    year: year
                )

                let greeting = SampleGreetings.randomGreeting(for: request)

                XCTAssertFalse(greeting.isEmpty,
                               "Greeting should not be empty for \(recipientType.displayName) + \(tone.displayName)")
            }
        }
    }

    // MARK: - Year-Specific Content Tests

    func testTemplateIncludes2026CanChi() {
        let request = GreetingRequest(
            recipientType: .parents,
            tone: .formal,
            occasion: .tet,
            year: 2026
        )

        let greeting = SampleGreetings.randomGreeting(for: request)

        // 2026 = Bính Ngọ
        XCTAssertTrue(greeting.contains("Bính Ngọ") || greeting.contains("🐴 Ngọ"),
                      "Greeting for 2026 should contain 'Bính Ngọ' or zodiac animal. Got: \(greeting)")
    }

    func testTemplateIncludes2025CanChi() {
        let request = GreetingRequest(
            recipientType: .boss,
            tone: .formal,
            occasion: .tet,
            year: 2025
        )

        let greeting = SampleGreetings.randomGreeting(for: request)

        // 2025 = Ất Tỵ
        XCTAssertTrue(greeting.contains("Ất Tỵ") || greeting.contains("🐍 Tỵ"),
                      "Greeting for 2025 should contain 'Ất Tỵ' or zodiac animal. Got: \(greeting)")
    }

    func testTemplateIncludes2024CanChi() {
        let request = GreetingRequest(
            recipientType: .friends,
            tone: .casual,
            occasion: .tet,
            year: 2024
        )

        let greeting = SampleGreetings.randomGreeting(for: request)

        // 2024 = Giáp Thìn
        XCTAssertTrue(greeting.contains("Giáp Thìn") || greeting.contains("🐉 Thìn"),
                      "Greeting for 2024 should contain 'Giáp Thìn' or zodiac animal. Got: \(greeting)")
    }

    // MARK: - Name Replacement Tests

    func testNameReplacementForGrandparents() {
        let request = GreetingRequest(
            recipientType: .grandparents,
            tone: .formal,
            occasion: .tet,
            recipientName: "Ông Nội",
            year: 2026
        )

        let greeting = SampleGreetings.randomGreeting(for: request)

        // Should contain the custom name
        XCTAssertTrue(greeting.contains("Ông Nội"),
                      "Greeting should contain custom name 'Ông Nội'. Got: \(greeting)")
    }

    func testNameReplacementForParents() {
        let request = GreetingRequest(
            recipientType: .parents,
            tone: .casual,
            occasion: .tet,
            recipientName: "Ba Má",
            year: 2026
        )

        let greeting = SampleGreetings.randomGreeting(for: request)

        // Should contain the custom name
        XCTAssertTrue(greeting.contains("Ba Má"),
                      "Greeting should contain custom name 'Ba Má'. Got: \(greeting)")
    }

    func testNameReplacementForBoss() {
        let request = GreetingRequest(
            recipientType: .boss,
            tone: .formal,
            occasion: .tet,
            recipientName: "Anh Tuấn",
            year: 2026
        )

        let greeting = SampleGreetings.randomGreeting(for: request)

        // Should contain the custom name
        XCTAssertTrue(greeting.contains("Anh Tuấn"),
                      "Greeting should contain custom name 'Anh Tuấn'. Got: \(greeting)")
    }

    func testNameReplacementForTeachers() {
        let request = GreetingRequest(
            recipientType: .teachers,
            tone: .formal,
            occasion: .tet,
            recipientName: "Cô Lan",
            year: 2026
        )

        let greeting = SampleGreetings.randomGreeting(for: request)

        // Should contain the custom name
        XCTAssertTrue(greeting.contains("Cô Lan"),
                      "Greeting should contain custom name 'Cô Lan'. Got: \(greeting)")
    }

    func testNameReplacementForFriends() {
        let request = GreetingRequest(
            recipientType: .friends,
            tone: .casual,
            occasion: .tet,
            recipientName: "Minh",
            year: 2026
        )

        let greeting = SampleGreetings.randomGreeting(for: request)

        // Should contain the custom name
        XCTAssertTrue(greeting.contains("Minh"),
                      "Greeting should contain custom name 'Minh'. Got: \(greeting)")
    }

    func testNameReplacementForPartner() {
        let request = GreetingRequest(
            recipientType: .partner,
            tone: .romantic,
            occasion: .tet,
            recipientName: "Yêu",
            year: 2026
        )

        let greeting = SampleGreetings.randomGreeting(for: request)

        // Should contain the custom name
        XCTAssertTrue(greeting.contains("Yêu"),
                      "Greeting should contain custom name 'Yêu'. Got: \(greeting)")
    }

    func testNameReplacementForChildren() {
        let request = GreetingRequest(
            recipientType: .children,
            tone: .casual,
            occasion: .tet,
            recipientName: "Bé Hạnh",
            year: 2026
        )

        let greeting = SampleGreetings.randomGreeting(for: request)

        // Should contain the custom name
        XCTAssertTrue(greeting.contains("Bé Hạnh"),
                      "Greeting should contain custom name 'Bé Hạnh'. Got: \(greeting)")
    }

    func testNoNameReplacementWhenNameIsNil() {
        let request = GreetingRequest(
            recipientType: .parents,
            tone: .formal,
            occasion: .tet,
            recipientName: nil,
            year: 2026
        )

        let greeting = SampleGreetings.randomGreeting(for: request)

        // Should contain generic "Bố Mẹ" when no custom name
        XCTAssertTrue(greeting.contains("Bố Mẹ") || greeting.contains("bố mẹ"),
                      "Greeting without custom name should contain generic 'Bố Mẹ'. Got: \(greeting)")
    }

    func testNoNameReplacementWhenNameIsEmpty() {
        let request = GreetingRequest(
            recipientType: .friends,
            tone: .casual,
            occasion: .tet,
            recipientName: "",
            year: 2026
        )

        let greeting = SampleGreetings.randomGreeting(for: request)

        // Should use generic greeting when name is empty string
        XCTAssertFalse(greeting.isEmpty,
                       "Greeting should still be generated when name is empty string")
    }

    // MARK: - Randomization Tests

    func testRandomGreetingVariesAcrossMultipleCalls() {
        let request = GreetingRequest(
            recipientType: .friends,
            tone: .casual,
            occasion: .tet,
            year: 2026
        )

        // Generate multiple greetings
        var greetings = Set<String>()
        for _ in 0..<20 {
            let greeting = SampleGreetings.randomGreeting(for: request)
            greetings.insert(greeting)
        }

        // Should have variation (at least 2 different templates)
        // Note: This assumes there are multiple templates for friends + casual
        XCTAssertGreaterThanOrEqual(greetings.count, 2,
                                    "Should have at least 2 different templates for variety")
    }

    // MARK: - Fallback Tests

    func testRandomGreetingHandlesUnsupportedCombinations() {
        // Test a combination that may not have dedicated templates
        let request = GreetingRequest(
            recipientType: .children,
            tone: .romantic, // Unusual combination
            occasion: .tet,
            year: 2026
        )

        let greeting = SampleGreetings.randomGreeting(for: request)

        // Should still return a valid greeting (fallback to default)
        XCTAssertFalse(greeting.isEmpty,
                       "Should return fallback greeting for unsupported combination")
        XCTAssertGreaterThan(greeting.count, 10,
                             "Fallback greeting should be meaningful length")
    }

    // MARK: - Special Tone Tests

    func testFunnyToneGreeting() {
        let request = GreetingRequest(
            recipientType: .friends,
            tone: .funny,
            occasion: .tet,
            year: 2026
        )

        let greeting = SampleGreetings.randomGreeting(for: request)

        // Funny greetings often contain emojis or casual language
        XCTAssertFalse(greeting.isEmpty, "Funny greeting should not be empty")
    }

    func testRomanticToneGreeting() {
        let request = GreetingRequest(
            recipientType: .partner,
            tone: .romantic,
            occasion: .tet,
            year: 2026
        )

        let greeting = SampleGreetings.randomGreeting(for: request)

        // Romantic greetings often contain heart emojis or love-related words
        XCTAssertFalse(greeting.isEmpty, "Romantic greeting should not be empty")
    }
}
