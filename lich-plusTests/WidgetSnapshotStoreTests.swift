//
//  WidgetSnapshotStoreTests.swift
//  lich-plusTests
//

import XCTest
@testable import lich_plus

final class WidgetSnapshotStoreTests: XCTestCase {
    override func tearDown() {
        WidgetAppGroup.sharedDefaults?.removeObject(forKey: WidgetAppGroup.snapshotKey)
        super.tearDown()
    }

    func testSaveAndLoadSnapshotRoundTrip() {
        let day = WidgetDayEntry(
            date: Date(timeIntervalSince1970: 1_700_000_000),
            solarDay: 7,
            solarMonth: 9,
            solarYear: 2026,
            lunarDay: 16,
            lunarMonth: 7,
            lunarYear: 2026,
            dayCanChi: "Giáp Thìn",
            specialChips: ["Ngày Rằm"],
            nextHolidayTitle: "Tết",
            nextHolidayDate: Date(timeIntervalSince1970: 1_800_000_000),
            nextHolidayDaysUntil: 12
        )

        let snapshot = WidgetTimelineSnapshot(
            generatedAt: Date(timeIntervalSince1970: 1_700_000_001),
            localeCode: "vi",
            days: [day]
        )

        WidgetSnapshotStore.save(snapshot)
        let loaded = WidgetSnapshotStore.load()

        XCTAssertEqual(loaded, snapshot)
    }
}
