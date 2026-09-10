//
//  XuatHanhSummaryTests.swift
//  lich-plusTests
//

import XCTest
@testable import lich_plus

final class XuatHanhSummaryTests: XCTestCase {

    func testSummaryHasSixLuckyAndSixAvoidHours() {
        let summary = XuatHanhSummary.forDate(Date())
        XCTAssertEqual(summary.luckyHours.count, 6)
        XCTAssertEqual(summary.avoidHours.count, 6)
        XCTAssertFalse(summary.luckySummary.isEmpty)
        XCTAssertFalse(summary.avoidSummary.isEmpty)
        // Direction comes from day quality when available
        if let direction = summary.luckyDirection {
            XCTAssertFalse(direction.isEmpty)
        }
    }
}
