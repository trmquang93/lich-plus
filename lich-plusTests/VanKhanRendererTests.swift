//
//  VanKhanRendererTests.swift
//  lich-plusTests
//

import XCTest
import SwiftData
@testable import lich_plus

@MainActor
final class VanKhanRendererTests: XCTestCase {

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

    private func makeProfile(name: String = "Nguyễn Văn A", address: String = "123 Hà Nội") -> PersonalProfile {
        let p = PersonalProfile(fullName: name, address: address, gender: "nam")
        modelContext.insert(p)
        return p
    }

    func testSubstitutesNameAndAddress() {
        let p = makeProfile()
        let text = VanKhanText(occasionId: "x", body: "Tín chủ con là: {name}\nNgụ tại: {address}")
        let out = VanKhanRenderer.render(text: text, profile: p)
        XCTAssertTrue(out.contains("Nguyễn Văn A"), out)
        XCTAssertTrue(out.contains("123 Hà Nội"), out)
        XCTAssertFalse(out.contains("{name}"))
        XCTAssertFalse(out.contains("{address}"))
    }

    func testUnknownTokenIsPreserved() {
        let p = makeProfile()
        let text = VanKhanText(occasionId: "x", body: "Hello {name}, weather: {weather}")
        let out = VanKhanRenderer.render(text: text, profile: p)
        XCTAssertTrue(out.contains("Hello Nguyễn Văn A"))
        XCTAssertTrue(out.contains("{weather}"), "Unknown tokens must be left in place: \(out)")
    }

    func testEmptyProfileLeavesTokensIntact() {
        let text = VanKhanText(occasionId: "x", body: "Tín chủ con là: {name}\nNgụ tại: {address}")
        let out = VanKhanRenderer.render(text: text, profile: nil)
        XCTAssertTrue(out.contains("{name}"))
        XCTAssertTrue(out.contains("{address}"))
    }

    func testOverridesWinOverProfile() {
        let p = makeProfile(name: "Nguyễn Văn A", address: "Cũ")
        let text = VanKhanText(occasionId: "x", body: "Ngụ tại: {address}")
        let out = VanKhanRenderer.render(
            text: text,
            profile: p,
            overrides: ["address": "Địa chỉ mới"]
        )
        XCTAssertTrue(out.contains("Địa chỉ mới"))
        XCTAssertFalse(out.contains("Cũ"))
    }

    func testDeceasedTokensFromContext() {
        let p = makeProfile()
        let relative = DeceasedRelative(relation: "ông", name: "Nguyễn Văn C", lunarDay: 10, lunarMonth: 7)
        let text = VanKhanText(occasionId: "gio", body: "Giỗ {deceasedRelation} {deceasedName}")
        let out = VanKhanRenderer.render(
            text: text,
            profile: p,
            context: .init(deceasedRelative: relative)
        )
        XCTAssertEqual(out, "Giỗ ông Nguyễn Văn C")
    }

    func testUnresolvedTokensHelper() {
        let s = "Hello {name}, weather: {weather}, fine."
        let unresolved = VanKhanRenderer.unresolvedTokens(in: s).sorted()
        XCTAssertEqual(unresolved, ["name", "weather"])
    }

    func testSolarDateInjected() {
        let p = makeProfile()
        let text = VanKhanText(occasionId: "x", body: "Hôm nay {solarDate}")
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.date(from: DateComponents(year: 2026, month: 1, day: 15))!
        let out = VanKhanRenderer.render(text: text, profile: p, context: .init(date: date))
        XCTAssertTrue(out.contains("15/01/2026"), out)
    }
}
