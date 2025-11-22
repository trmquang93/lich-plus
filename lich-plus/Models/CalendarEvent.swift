import Foundation
import SwiftData

// MARK: - Calendar Event Model
@Model
final class CalendarEvent: Identifiable {
    var id: UUID = UUID()
    var title: String
    var date: Date // Solar calendar date
    var startTime: Date?
    var endTime: Date?
    var location: String?
    var category: String // Reference to category by name
    var notes: String?
    var color: String // Hex color code
    var isAllDay: Bool = false
    var isRecurring: Bool = false
    var recurringType: String? // Daily, Weekly, Monthly, Yearly

    // MARK: - Initializer
    init(
        title: String,
        date: Date,
        startTime: Date? = nil,
        endTime: Date? = nil,
        location: String? = nil,
        category: String = "Công việc",
        notes: String? = nil,
        color: String = "#5BC0A6",
        isAllDay: Bool = false
    ) {
        self.title = title
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.location = location
        self.category = category
        self.notes = notes
        self.color = color
        self.isAllDay = isAllDay
    }

    // MARK: - Computed Properties
    var timeRangeString: String? {
        guard let start = startTime, let end = endTime else { return nil }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "vi_VN")
        let startStr = formatter.string(from: start)
        let endStr = formatter.string(from: end)
        return "\(startStr) - \(endStr)"
    }

    var startTimeString: String? {
        guard let start = startTime else { return nil }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "vi_VN")
        return formatter.string(from: start)
    }

    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "vi_VN")
        return formatter.string(from: date)
    }

    var dateWithDayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, dd/MM/yyyy"
        formatter.locale = Locale(identifier: "vi_VN")
        return formatter.string(from: date)
    }

    /// Determines if this event should be displayed based on lunar event visibility settings
    /// - Parameters:
    ///   - showRamEvents: Whether to show Rằm (15th day) events
    ///   - showMung1Events: Whether to show Mùng 1 (1st day) events
    /// - Returns: True if event should be visible, false if it should be filtered out
    func shouldDisplay(showRamEvents: Bool, showMung1Events: Bool) -> Bool {
        // Only filter system events (lunar events)
        guard isRecurring else { return true }

        // Filter Rằm events when setting is disabled
        if title.contains("Rằm") && !showRamEvents {
            return false
        }

        // Filter Mùng 1 events when setting is disabled
        if title.contains("Mùng 1") && !showMung1Events {
            return false
        }

        return true
    }
}

// MARK: - Sample Data Utilities
extension CalendarEvent {
    static func createSampleEvents(for year: Int, month: Int) -> [CalendarEvent] {
        let calendar = Calendar.current
        var events: [CalendarEvent] = []

        // Helper function to create date
        func makeDate(day: Int, hour: Int = 0, minute: Int = 0) -> Date {
            var components = DateComponents()
            components.year = year
            components.month = month
            components.day = day
            components.hour = hour
            components.minute = minute
            return calendar.date(from: components) ?? Date()
        }

        // Helper function to create time
        func makeTime(hour: Int, minute: Int = 0) -> Date {
            var components = DateComponents()
            components.hour = hour
            components.minute = minute
            return calendar.date(from: components) ?? Date()
        }

        // August 2024 Sample Events

        // August 7 - "Họp team tuần" 7:00-8:00 AM (Green)
        events.append(CalendarEvent(
            title: "Họp team tuần",
            date: makeDate(day: 7),
            startTime: makeTime(hour: 7),
            endTime: makeTime(hour: 8),
            location: "Phòng họp A",
            category: "Họp công việc",
            color: "#5BC0A6"
        ))

        // August 8 - "Giờ tối: Tỵ (9h-11h)" (Orange)
        events.append(CalendarEvent(
            title: "Giờ tối: Tỵ (9h-11h)",
            date: makeDate(day: 8),
            category: "Giờ hoàng đạo",
            notes: "Thời gian không thuận lợi",
            color: "#F5A623"
        ))

        // August 9 - "Ăn trưa với khách hàng" 12:30 PM (Blue)
        events.append(CalendarEvent(
            title: "Ăn trưa với khách hàng",
            date: makeDate(day: 9),
            startTime: makeTime(hour: 12, minute: 30),
            location: "Nhà hàng Việt Thắng",
            category: "Ăn trưa",
            color: "#4A90E2"
        ))

        // August 10 - "Gọi điện cho đối tác" 3:00-3:30 PM (Teal)
        events.append(CalendarEvent(
            title: "Gọi điện cho đối tác",
            date: makeDate(day: 10),
            startTime: makeTime(hour: 15),
            endTime: makeTime(hour: 15, minute: 30),
            category: "Gọi điện",
            color: "#50E3C2"
        ))

        // August 11 - "Giờ xấu: Dâu (17h-19h)" (Red)
        events.append(CalendarEvent(
            title: "Giờ xấu: Dâu (17h-19h)",
            date: makeDate(day: 11),
            category: "Giờ xấu",
            notes: "Thời gian không thuận lợi",
            color: "#D0021B"
        ))

        // August 15 - "Hợp team dự án" 9:00 AM (Green)
        events.append(CalendarEvent(
            title: "Hợp team dự án",
            date: makeDate(day: 15),
            startTime: makeTime(hour: 9),
            location: "Trực tuyến Zoom",
            category: "Họp công việc",
            color: "#5BC0A6"
        ))

        // August 16 - "Ăn trưa với gia đình" 12:00 PM (Teal)
        events.append(CalendarEvent(
            title: "Ăn trưa với gia đình",
            date: makeDate(day: 16),
            startTime: makeTime(hour: 12),
            location: "Nhà",
            category: "Ăn trưa",
            color: "#50E3C2"
        ))

        // August 19 - "Lễ Vu Lan" (All day, Yellow/Gold)
        events.append(CalendarEvent(
            title: "Lễ Vu Lan",
            date: makeDate(day: 19),
            category: "Sự kiện văn hóa",
            notes: "Ngày lễ truyền thống",
            color: "#F8E71C",
            isAllDay: true
        ))

        // August 25 - "Ngày Hoàng Dao (Tối)" (Yellow)
        events.append(CalendarEvent(
            title: "Ngày Hoàng Dao (Tối)",
            date: makeDate(day: 25),
            category: "Sự kiện văn hóa",
            notes: "Thời gian hoàng đạo tối",
            color: "#F8E71C",
            isAllDay: true
        ))

        // August 30 - "Báo cáo tiến độ dự án" 2:00 PM (Blue)
        events.append(CalendarEvent(
            title: "Báo cáo tiến độ dự án",
            date: makeDate(day: 30),
            startTime: makeTime(hour: 14),
            location: "Phòng họp B",
            category: "Họp công việc",
            color: "#4A90E2"
        ))

        return events
    }

    /// Generates lunar calendar events (Mùng 1 and Rằm) for multiple years.
    ///
    /// This method creates all-day events for the 1st and 15th days of each lunar month,
    /// spanning the specified number of years. These are system events that cannot be edited
    /// or deleted by users, identified by setting isRecurring=true (repurposed flag).
    ///
    /// The method handles leap months correctly, appending "nhuận" to month labels for
    /// non-standard lunar months that occur in leap years (e.g., "5 nhuận").
    ///
    /// **Note on isRecurring Flag**: The isRecurring property is repurposed to mark system
    /// events (lunar events) as protected. User-created events have isRecurring=false,
    /// while system events have isRecurring=true.
    ///
    /// - Parameters:
    ///   - startYear: Starting year for event generation (e.g., 2024)
    ///   - yearCount: Number of years to generate events for (typically 5 for 5-year coverage)
    ///
    /// - Returns: Array of lunar calendar events.
    ///   - Typical yield: ~24 events per year (12 months × 2 events), plus extra events
    ///     for leap months (~26 events in leap years), resulting in ~120-130 total events
    ///     for a 5-year span (2024-2029).
    ///
    /// Example:
    /// ```swift
    /// let lunarEvents = CalendarEvent.createLunarEvents(startYear: 2024, yearCount: 5)
    /// // Generates ~120 events from lunar calendar
    /// ```
    static func createLunarEvents(startYear: Int, yearCount: Int) -> [CalendarEvent] {
        var events: [CalendarEvent] = []

        for yearOffset in 0..<yearCount {
            let year = startYear + yearOffset

            // Iterate through all 12 regular lunar months
            for lunarMonth in 1...12 {
                // Always create events for regular months (non-leap)
                createLunarEventPair(
                    for: year,
                    month: lunarMonth,
                    isLeapMonth: false,
                    into: &events
                )

                // Additionally create events for leap month if this month is a leap month
                if LunarCalendarConverter.isLeapMonth(year: year, month: lunarMonth) {
                    createLunarEventPair(
                        for: year,
                        month: lunarMonth,
                        isLeapMonth: true,
                        into: &events
                    )
                }
            }
        }

        return events
    }

    /// Helper method to create both Mùng 1 (New Moon) and Rằm (Full Moon) events for a lunar month
    private static func createLunarEventPair(
        for year: Int,
        month: Int,
        isLeapMonth: Bool,
        into events: inout [CalendarEvent]
    ) {
        // Format month label: regular months (e.g., "5"), leap months (e.g., "5 nhuận")
        let monthLabel = isLeapMonth ? "\(month) nhuận" : "\(month)"

        // Generate Mùng 1 event (1st day of lunar month / New Moon)
        if let solarDate = LunarCalendarConverter.lunarToSolar(
            year: year,
            month: month,
            day: 1,
            isLeapMonth: isLeapMonth
        ) {
            let event = CalendarEvent(
                title: "Mùng 1 tháng \(monthLabel)",
                date: solarDate,
                category: "Sự kiện văn hóa",
                notes: "Mùng 1 âm lịch",
                color: "#F8E71C",
                isAllDay: true
            )
            // Mark as system event using isRecurring flag (protected from editing/deletion)
            event.isRecurring = true
            events.append(event)
        }

        // Generate Rằm event (15th day of lunar month / Full Moon)
        if let solarDate = LunarCalendarConverter.lunarToSolar(
            year: year,
            month: month,
            day: 15,
            isLeapMonth: isLeapMonth
        ) {
            let event = CalendarEvent(
                title: "Rằm tháng \(monthLabel)",
                date: solarDate,
                category: "Sự kiện văn hóa",
                notes: "Ngày rằm âm lịch",
                color: "#F8E71C",
                isAllDay: true
            )
            // Mark as system event using isRecurring flag (protected from editing/deletion)
            event.isRecurring = true
            events.append(event)
        }
    }
}
