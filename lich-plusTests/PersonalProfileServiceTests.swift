//
//  PersonalProfileServiceTests.swift
//  lich-plusTests
//

import XCTest
import SwiftData
@testable import lich_plus

@MainActor
final class PersonalProfileServiceTests: XCTestCase {

    var service: PersonalProfileService!
    var modelContext: ModelContext!

    override func setUp() async throws {
        try await super.setUp()
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: PersonalProfile.self, DeceasedRelative.self,
            configurations: config
        )
        modelContext = ModelContext(container)
        service = PersonalProfileService(modelContext: modelContext)
    }

    override func tearDown() async throws {
        service = nil
        modelContext = nil
        try await super.tearDown()
    }

    func testGetProfile_createsDefaultIfNotExists() {
        let profile = service.getProfile()
        XCTAssertEqual(profile.id, "personal_profile")
        XCTAssertEqual(profile.fullName, "")
        XCTAssertTrue(profile.deceasedRelatives.isEmpty)
    }

    func testGetProfile_isSingleton() {
        let a = service.getProfile()
        a.fullName = "Nguyễn Văn A"
        service.save()

        let b = service.getProfile()
        XCTAssertEqual(b.id, a.id)
        XCTAssertEqual(b.fullName, "Nguyễn Văn A")

        let all = try? modelContext.fetch(FetchDescriptor<PersonalProfile>())
        XCTAssertEqual(all?.count, 1)
    }

    func testUpdateProfile_persists() {
        let p = service.getProfile()
        p.fullName = "Trần Thị B"
        p.address = "123 Đường ABC, Hà Nội"
        p.gender = "nữ"
        service.save()

        let fetched = service.getProfile()
        XCTAssertEqual(fetched.fullName, "Trần Thị B")
        XCTAssertEqual(fetched.address, "123 Đường ABC, Hà Nội")
        XCTAssertEqual(fetched.gender, "nữ")
    }

    func testAddRemoveDeceasedRelative() {
        let p = service.getProfile()
        let r = DeceasedRelative(relation: "ông", name: "Nguyễn Văn C", lunarDay: 10, lunarMonth: 7)
        service.addDeceasedRelative(r, to: p)

        XCTAssertEqual(p.deceasedRelatives.count, 1)
        XCTAssertEqual(p.deceasedRelatives.first?.name, "Nguyễn Văn C")
        XCTAssertEqual(p.deceasedRelatives.first?.lunarDay, 10)

        service.removeDeceasedRelative(r, from: p)
        XCTAssertTrue(p.deceasedRelatives.isEmpty)
    }
}
