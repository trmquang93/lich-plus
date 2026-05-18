//
//  VanKhanOccasionMatcherTests.swift
//  lich-plusTests
//

import XCTest
import SwiftData
@testable import lich_plus

@MainActor
final class VanKhanOccasionMatcherTests: XCTestCase {

    private var modelContext: ModelContext!

    override func setUp() async throws {
        try await super.setUp()
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: PersonalProfile.self, DeceasedRelative.self,
            configurations: config
        )
        modelContext = ModelContext(container)
    }

    override func tearDown() async throws {
        modelContext = nil
        try await super.tearDown()
    }

    /// Build a solar Date from a given lunar (day, month, year) via existing
    /// LunarCalendar.lunarToSolar so the test is independent of system clock.
    private func solarFromLunar(day: Int, month: Int, year: Int) -> Date {
        LunarCalendar.lunarToSolar(day: day, month: month, year: year)
    }

    func testMatchesMung1() {
        let date = solarFromLunar(day: 1, month: 5, year: 2026)
        let matches = VanKhanOccasionMatcher.match(date: date, profile: nil)
        XCTAssertTrue(matches.contains { $0.occasion.id == "mung-1-hang-thang" },
                      "expected mùng 1 monthly match, got \(matches.map { $0.occasion.id })")
    }

    func testMatchesRam() {
        let date = solarFromLunar(day: 15, month: 5, year: 2026)
        let matches = VanKhanOccasionMatcher.match(date: date, profile: nil)
        XCTAssertTrue(matches.contains { $0.occasion.id == "ram-hang-thang" },
                      "expected rằm monthly match, got \(matches.map { $0.occasion.id })")
    }

    func testFestivalWinsOverMonthlyOnRamThangGieng() {
        let date = solarFromLunar(day: 15, month: 1, year: 2026)
        let matches = VanKhanOccasionMatcher.match(date: date, profile: nil)
        XCTAssertTrue(matches.contains { $0.occasion.id == "ram-thang-gieng" })
        XCTAssertFalse(matches.contains { $0.occasion.id == "ram-hang-thang" },
                       "monthly rằm should be suppressed by festival rằm tháng giêng")
    }

    func testMatchesVuLan() {
        let date = solarFromLunar(day: 15, month: 7, year: 2026)
        let matches = VanKhanOccasionMatcher.match(date: date, profile: nil)
        XCTAssertTrue(matches.contains { $0.occasion.id == "vu-lan" })
    }

    func testMatchesTrungThu() {
        let date = solarFromLunar(day: 15, month: 8, year: 2026)
        let matches = VanKhanOccasionMatcher.match(date: date, profile: nil)
        XCTAssertTrue(matches.contains { $0.occasion.id == "trung-thu" })
    }

    func testMatchesOngTao() {
        let date = solarFromLunar(day: 23, month: 12, year: 2026)
        let matches = VanKhanOccasionMatcher.match(date: date, profile: nil)
        XCTAssertTrue(matches.contains { $0.occasion.id == "ong-cong-ong-tao" })
    }

    func testMatchesAnniversaryFromProfile() {
        let profile = PersonalProfile(fullName: "A", address: "B")
        let relative = DeceasedRelative(relation: "ông", name: "C", lunarDay: 10, lunarMonth: 3)
        profile.deceasedRelatives = [relative]
        modelContext.insert(profile)

        let date = solarFromLunar(day: 10, month: 3, year: 2026)
        let matches = VanKhanOccasionMatcher.match(date: date, profile: profile)
        XCTAssertTrue(matches.contains { $0.occasion.id == "gio" },
                      "expected giỗ match, got \(matches.map { $0.occasion.id })")
        XCTAssertNotNil(matches.first { $0.occasion.id == "gio" }?.deceasedRelative)
    }

    func testNoMatchOnOrdinaryDay() {
        let date = solarFromLunar(day: 7, month: 5, year: 2026)
        let matches = VanKhanOccasionMatcher.match(date: date, profile: nil)
        XCTAssertTrue(matches.isEmpty, "expected no matches for lunar 7/5, got \(matches.map { $0.occasion.id })")
    }
}
