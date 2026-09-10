//
//  BirthYearStoreTests.swift
//  lich-plusTests
//

import XCTest
@testable import lich_plus

@MainActor
final class BirthYearStoreTests: XCTestCase {

    private var suiteName: String!
    private var defaults: UserDefaults!
    private var store: BirthYearStore!

    override func setUp() async throws {
        try await super.setUp()
        suiteName = "BirthYearStoreTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
        defaults.removePersistentDomain(forName: suiteName)
        store = BirthYearStore(defaults: defaults)
    }

    override func tearDown() async throws {
        defaults.removePersistentDomain(forName: suiteName)
        store = nil
        defaults = nil
        suiteName = nil
        try await super.tearDown()
    }

    func testAcceptedRangePersistsAndNilClears() {
        // WHY: birth year is the only input to tuổi xung and must persist/clear correctly
        store.setBirthYear(1920)
        XCTAssertEqual(store.birthYear, 1920)
        XCTAssertEqual(BirthYearStore(defaults: defaults).birthYear, 1920)

        store.setBirthYear(2100)
        XCTAssertEqual(store.birthYear, 2100)
        XCTAssertTrue(store.hasBirthYear)
        XCTAssertEqual(BirthYearStore(defaults: defaults).birthYear, 2100)

        store.setBirthYear(nil)
        XCTAssertNil(store.birthYear)
        XCTAssertFalse(store.hasBirthYear)
        XCTAssertNil(BirthYearStore(defaults: defaults).birthYear)
    }

    func testYearsOutsideRangeAreRejected() {
        // WHY: out-of-range years must not persist as a natal Can-Chi input
        store.setBirthYear(1990)
        store.setBirthYear(1919)
        XCTAssertNil(store.birthYear)

        store.setBirthYear(1990)
        store.setBirthYear(2101)
        XCTAssertNil(store.birthYear)
    }
}
