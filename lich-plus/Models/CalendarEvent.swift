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

        return events
    }

    /// Generates lunar events (Mùng 1 and Rằm) for multiple years.
    /// Creates all-day events for the 1st and 15th days of each lunar month.
    /// Handles leap months correctly with "nhuận" indicator.
    ///
    /// - Parameters:
    ///   - startYear: Starting year for event generation
    ///   - yearCount: Number of years to generate events for
    /// - Returns: Array of lunar calendar events (approximately 120-130 events)
    static func createLunarEvents(startYear: Int, yearCount: Int) -> [CalendarEvent] {
        var events: [CalendarEvent] = []

        for yearOffset in 0..<yearCount {
            let year = startYear + yearOffset

            // Iterate through possible lunar months (1-13 to handle leap months)
            for lunarMonth in 1...13 {
                // Determine if this month is a leap month
                let isLeapMonth = LunarCalendarConverter.isLeapMonth(year: year, month: lunarMonth)

                // Skip month 13 if it's not a leap year
                if lunarMonth == 13 && !isLeapMonth {
                    continue
                }

                // Generate Mùng 1 event (1st day of lunar month)
                if let solarDate = LunarCalendarConverter.lunarToSolar(
                    year: year,
                    month: lunarMonth,
                    day: 1,
                    isLeapMonth: isLeapMonth
                ) {
                    let monthLabel = isLeapMonth ? "\(lunarMonth) nhuận" : "\(lunarMonth)"
                    let event = CalendarEvent(
                        title: "Mùng 1 tháng \(monthLabel)",
                        date: solarDate,
                        category: "Sự kiện văn hóa",
                        notes: "Mùng 1 âm lịch",
                        color: "#F8E71C",
                        isAllDay: true
                    )
                    event.isRecurring = true  // Repurposed as system event flag
                    events.append(event)
                }

                // Generate Rằm event (15th day of lunar month)
                if let solarDate = LunarCalendarConverter.lunarToSolar(
                    year: year,
                    month: lunarMonth,
                    day: 15,
                    isLeapMonth: isLeapMonth
                ) {
                    let monthLabel = isLeapMonth ? "\(lunarMonth) nhuận" : "\(lunarMonth)"
                    let event = CalendarEvent(
                        title: "Rằm tháng \(monthLabel)",
                        date: solarDate,
                        category: "Sự kiện văn hóa",
                        notes: "Ngày rằm âm lịch",
                        color: "#F8E71C",
                        isAllDay: true
                    )
                    event.isRecurring = true  // Repurposed as system event flag
                    events.append(event)
                }
            }
        }

        return events
    }
}
