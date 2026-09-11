//
//  FestivalLiveActivityManagerTests.swift
//  lich-plusTests
//

import XCTest
@testable import lich_plus

@MainActor
final class FestivalLiveActivityManagerTests: XCTestCase {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Ho_Chi_Minh") ?? .current
        return calendar
    }

    func testEligibleFestivalWithinWindow() {
        // 30 days before Tết 2026 (Feb 17) — Jan 18, 2026
        let reference = calendar.date(from: DateComponents(year: 2026, month: 1, day: 18))!
        let entry = FestivalLiveActivityManager.shared.eligibleFestival(from: reference)
        XCTAssertNotNil(entry)
        XCTAssertTrue(entry?.isTet == true)
        XCTAssertEqual(entry?.daysUntil, 30)
    }

    func testEligibleFestivalOutsideWindow() {
        // 60 days before Tết 2026 — Dec 19, 2025
        let reference = calendar.date(from: DateComponents(year: 2025, month: 12, day: 19))!
        let entry = FestivalLiveActivityManager.shared.eligibleFestival(from: reference)
        XCTAssertNil(entry)
    }

    func testEligibleFestivalOnTetDay() {
        let reference = calendar.date(from: DateComponents(year: 2026, month: 2, day: 17))!
        let entry = FestivalLiveActivityManager.shared.eligibleFestival(from: reference)
        XCTAssertNotNil(entry)
        XCTAssertEqual(entry?.daysUntil, 0)
        XCTAssertTrue(entry?.isTet == true)
    }

    func testAutoStartPersists() {
        let store = FestivalLiveActivityStore.shared
        let original = store.autoStartEnabled

        store.setAutoStartEnabled(false)
        XCTAssertFalse(UserDefaults.standard.bool(forKey: FestivalLiveActivityConstants.autoStartEnabledKey))
        XCTAssertFalse(WidgetAppGroup.sharedDefaults?.bool(forKey: WidgetAppGroup.liveActivityAutoStartKey) ?? true)

        store.setAutoStartEnabled(true)
        XCTAssertTrue(UserDefaults.standard.bool(forKey: FestivalLiveActivityConstants.autoStartEnabledKey))

        store.setAutoStartEnabled(original)
    }

    func testManualStopDismissesCurrentFestivalFromAutoStart() {
        let store = FestivalLiveActivityStore.shared
        let originalDismissed = store.userDismissedFestivalId

        store.clearDismissedFestival()
        store.dismissFestival(id: "1-1-2026")
        XCTAssertEqual(store.userDismissedFestivalId, "1-1-2026")
        XCTAssertTrue(store.isAutoStartBlocked(for: "1-1-2026"))
        XCTAssertFalse(store.isAutoStartBlocked(for: "8-15-2026"))
        XCTAssertEqual(
            WidgetAppGroup.sharedDefaults?.string(forKey: WidgetAppGroup.liveActivityDismissedFestivalIdKey),
            "1-1-2026"
        )

        store.clearDismissedFestival()
        XCTAssertNil(store.userDismissedFestivalId)

        if let originalDismissed {
            store.dismissFestival(id: originalDismissed)
        }
    }

    func testReEnablingAutoStartClearsDismissedFestival() {
        let store = FestivalLiveActivityStore.shared
        let originalAutoStart = store.autoStartEnabled
        let originalDismissed = store.userDismissedFestivalId

        store.dismissFestival(id: "1-1-2026")
        store.setAutoStartEnabled(false)
        store.setAutoStartEnabled(true)
        XCTAssertNil(store.userDismissedFestivalId)

        store.setAutoStartEnabled(originalAutoStart)
        if let originalDismissed {
            store.dismissFestival(id: originalDismissed)
        } else {
            store.clearDismissedFestival()
        }
    }

    func testFestivalCountdownEntryIsTet() {
        let tet = FestivalCountdownEntry(
            id: "1-1-2026",
            title: "Tet Holiday",
            solarDate: .now,
            daysUntil: 10
        )
        XCTAssertTrue(tet.isTet)

        let midAutumn = FestivalCountdownEntry(
            id: "8-15-2026",
            title: "Mid-Autumn Festival",
            solarDate: .now,
            daysUntil: 10
        )
        XCTAssertFalse(midAutumn.isTet)
    }
}
