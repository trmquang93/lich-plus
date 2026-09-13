//
//  OnboardingStoreTests.swift
//  lich-plusTests
//

import XCTest
@testable import lich_plus

@MainActor
final class OnboardingStoreTests: XCTestCase {
    private var defaults: UserDefaults!
    private var suiteName: String!

    override func setUp() {
        super.setUp()
        suiteName = "OnboardingStoreTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
        defaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        suiteName = nil
        super.tearDown()
    }

    func testMarkCompletedPersistsFlag() {
        let store = OnboardingStore(defaults: defaults)

        XCTAssertFalse(store.hasCompletedOnboarding)

        store.markCompleted()

        XCTAssertTrue(store.hasCompletedOnboarding)
        XCTAssertTrue(defaults.bool(forKey: OnboardingStore.completionKey))
    }

    func testResetForQAClearsFlag() {
        let store = OnboardingStore(defaults: defaults)
        store.markCompleted()

        store.resetForQA()

        XCTAssertFalse(store.hasCompletedOnboarding)
    }
}
