import XCTest
@testable import lich_plus

// MARK: - Event Filtering Tests
final class EventFilteringTests: XCTestCase {

    // MARK: - Test Setup

    /// Creates sample test events for filtering tests
    /// - Returns: Tuple containing system events (lunar) and user events
    func createTestEvents() -> (systemEvents: [CalendarEvent], userEvents: [CalendarEvent]) {
        let calendar = Calendar.current
        let testDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: Date()) ?? Date()

        // Create system events (lunar events)
        var systemEvents: [CalendarEvent] = []

        let ramEvent = CalendarEvent(
            title: "Rằm tháng 6",
            date: testDate,
            category: "Sự kiện văn hóa",
            notes: "Ngày rằm âm lịch",
            color: "#F8E71C",
            isAllDay: true
        )
        ramEvent.isRecurring = true
        systemEvents.append(ramEvent)

        let mung1Event = CalendarEvent(
            title: "Mùng 1 tháng 6",
            date: calendar.date(byAdding: .day, value: 1, to: testDate) ?? testDate,
            category: "Sự kiện văn hóa",
            notes: "Mùng 1 âm lịch",
            color: "#F8E71C",
            isAllDay: true
        )
        mung1Event.isRecurring = true
        systemEvents.append(mung1Event)

        // Create user events
        var userEvents: [CalendarEvent] = []

        let userEvent1 = CalendarEvent(
            title: "Họp team",
            date: testDate,
            startTime: calendar.date(bySettingHour: 9, minute: 0, second: 0, of: testDate),
            endTime: calendar.date(bySettingHour: 10, minute: 0, second: 0, of: testDate),
            category: "Họp công việc",
            color: "#5BC0A6"
        )
        userEvent1.isRecurring = false
        userEvents.append(userEvent1)

        let userEvent2 = CalendarEvent(
            title: "Ăn trưa",
            date: calendar.date(byAdding: .day, value: 1, to: testDate) ?? testDate,
            category: "Ăn trưa",
            color: "#4A90E2"
        )
        userEvent2.isRecurring = false
        userEvents.append(userEvent2)

        return (systemEvents, userEvents)
    }

    // MARK: - Test Lunar Events Detection

    /// Test that events with "Rằm" in title are correctly identified as system events
    func testRamEventDetection() {
        let (systemEvents, _) = createTestEvents()
        let ramEvents = systemEvents.filter { $0.title.contains("Rằm") && $0.isRecurring }

        XCTAssertEqual(ramEvents.count, 1)
        XCTAssertEqual(ramEvents.first?.title, "Rằm tháng 6")
        XCTAssertTrue(ramEvents.first?.isRecurring ?? false)
    }

    /// Test that events with "Mùng 1" in title are correctly identified as system events
    func testMung1EventDetection() {
        let (systemEvents, _) = createTestEvents()
        let mung1Events = systemEvents.filter { $0.title.contains("Mùng 1") && $0.isRecurring }

        XCTAssertEqual(mung1Events.count, 1)
        XCTAssertEqual(mung1Events.first?.title, "Mùng 1 tháng 6")
        XCTAssertTrue(mung1Events.first?.isRecurring ?? false)
    }

    // MARK: - Test Filtering Logic

    /// Test filtering Ram events when showRamEvents is false
    func testFilterRamEventsWhenDisabled() {
        let (systemEvents, _) = createTestEvents()
        let showRamEvents = false

        let filteredEvents = systemEvents.filter { event in
            if event.isRecurring {
                if event.title.contains("Rằm") && !showRamEvents {
                    return false
                }
            }
            return true
        }

        // Should only contain Mùng 1 event
        XCTAssertEqual(filteredEvents.count, 1)
        XCTAssertEqual(filteredEvents.first?.title, "Mùng 1 tháng 6")
        XCTAssertFalse(filteredEvents.contains { $0.title.contains("Rằm") })
    }

    /// Test filtering Mùng 1 events when showMung1Events is false
    func testFilterMung1EventsWhenDisabled() {
        let (systemEvents, _) = createTestEvents()
        let showMung1Events = false

        let filteredEvents = systemEvents.filter { event in
            if event.isRecurring {
                if event.title.contains("Mùng 1") && !showMung1Events {
                    return false
                }
            }
            return true
        }

        // Should only contain Rằm event
        XCTAssertEqual(filteredEvents.count, 1)
        XCTAssertEqual(filteredEvents.first?.title, "Rằm tháng 6")
        XCTAssertFalse(filteredEvents.contains { $0.title.contains("Mùng 1") })
    }

    /// Test filtering both Ram and Mùng 1 events when both are disabled
    func testFilterBothLunarEventsWhenDisabled() {
        let (systemEvents, _) = createTestEvents()
        let showRamEvents = false
        let showMung1Events = false

        let filteredEvents = systemEvents.filter { event in
            if event.isRecurring {
                if event.title.contains("Rằm") && !showRamEvents {
                    return false
                }
                if event.title.contains("Mùng 1") && !showMung1Events {
                    return false
                }
            }
            return true
        }

        // Should be empty
        XCTAssertEqual(filteredEvents.count, 0)
    }

    /// Test that all lunar events are shown when both toggles are enabled
    func testAllLunarEventsShownWhenEnabled() {
        let (systemEvents, _) = createTestEvents()
        let showRamEvents = true
        let showMung1Events = true

        let filteredEvents = systemEvents.filter { event in
            if event.isRecurring {
                if event.title.contains("Rằm") && !showRamEvents {
                    return false
                }
                if event.title.contains("Mùng 1") && !showMung1Events {
                    return false
                }
            }
            return true
        }

        // Should contain both events
        XCTAssertEqual(filteredEvents.count, 2)
    }

    // MARK: - Test User Events Always Visible

    /// Test that user events are always visible regardless of filtering settings
    func testUserEventsAlwaysVisible() {
        let (_, userEvents) = createTestEvents()
        let showRamEvents = false
        let showMung1Events = false

        let filteredEvents = userEvents.filter { event in
            if event.isRecurring {
                if event.title.contains("Rằm") && !showRamEvents {
                    return false
                }
                if event.title.contains("Mùng 1") && !showMung1Events {
                    return false
                }
            }
            return true
        }

        // All user events should be visible
        XCTAssertEqual(filteredEvents.count, userEvents.count)
        XCTAssertEqual(filteredEvents.count, 2)
    }

    /// Test that non-system events are not affected by lunar event filters
    func testNonSystemEventsIgnoredByFilters() {
        let (_, userEvents) = createTestEvents()

        for event in userEvents {
            XCTAssertFalse(event.isRecurring, "User events should have isRecurring = false")
        }
    }

    // MARK: - Test Combined Filtering (System + User Events)

    /// Test filtering combined system and user events
    func testCombinedEventsFiltering() {
        let (systemEvents, userEvents) = createTestEvents()
        let allEvents = systemEvents + userEvents
        let showRamEvents = false
        let showMung1Events = true

        let filteredEvents = allEvents.filter { event in
            if event.isRecurring {
                if event.title.contains("Rằm") && !showRamEvents {
                    return false
                }
                if event.title.contains("Mùng 1") && !showMung1Events {
                    return false
                }
            }
            return true
        }

        // Should have:
        // - 0 Rằm events (filtered out)
        // - 1 Mùng 1 event
        // - 2 user events
        XCTAssertEqual(filteredEvents.count, 3)
        XCTAssertFalse(filteredEvents.contains { $0.title.contains("Rằm") })
        XCTAssertTrue(filteredEvents.contains { $0.title.contains("Mùng 1") })
    }

    /// Test that disabling both lunar filters leaves only user events
    func testDisableBothFiltersLeavesOnlyUserEvents() {
        let (systemEvents, userEvents) = createTestEvents()
        let allEvents = systemEvents + userEvents
        let showRamEvents = false
        let showMung1Events = false

        let filteredEvents = allEvents.filter { event in
            if event.isRecurring {
                if event.title.contains("Rằm") && !showRamEvents {
                    return false
                }
                if event.title.contains("Mùng 1") && !showMung1Events {
                    return false
                }
            }
            return true
        }

        // Should have only user events
        XCTAssertEqual(filteredEvents.count, userEvents.count)
        for event in filteredEvents {
            XCTAssertFalse(event.isRecurring)
        }
    }

    // MARK: - Test Edge Cases

    /// Test filtering with empty event list
    func testFilteringEmptyEventList() {
        let emptyEvents: [CalendarEvent] = []
        let showRamEvents = false

        let filteredEvents = emptyEvents.filter { event in
            if event.isRecurring {
                if event.title.contains("Rằm") && !showRamEvents {
                    return false
                }
            }
            return true
        }

        XCTAssertEqual(filteredEvents.count, 0)
    }

    /// Test filtering with single event
    func testFilteringSingleEvent() {
        let (systemEvents, _) = createTestEvents()
        let singleEvent = [systemEvents[0]]
        let showRamEvents = false

        let filteredEvents = singleEvent.filter { event in
            if event.isRecurring {
                if event.title.contains("Rằm") && !showRamEvents {
                    return false
                }
            }
            return true
        }

        XCTAssertEqual(filteredEvents.count, 0)
    }

    /// Test that events with similar titles but different content are filtered correctly
    func testSimilarTitleEventFiltering() {
        let calendar = Calendar.current
        let testDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: Date()) ?? Date()

        // Create event with "Rằm" in middle of title
        let ramRelatedEvent = CalendarEvent(
            title: "Kỷ niệm Rằm tháng 6",
            date: testDate,
            category: "Sự kiện văn hóa",
            color: "#F8E71C",
            isAllDay: true
        )
        ramRelatedEvent.isRecurring = true

        let events = [ramRelatedEvent]
        let showRamEvents = false

        let filteredEvents = events.filter { event in
            if event.isRecurring {
                if event.title.contains("Rằm") && !showRamEvents {
                    return false
                }
            }
            return true
        }

        XCTAssertEqual(filteredEvents.count, 0)
    }
}
