import Foundation

// MARK: - Lunar Calendar Date Information
struct LunarDateInfo: Codable, Hashable {
    var year: Int
    var month: Int
    var day: Int
    var isLeapMonth: Bool = false
    var canChi: CanChiInfo?

    // MARK: - Display Properties
    var displayString: String {
        let monthStr = isLeapMonth ? "N\(month)" : "\(month)"
        return "Âm \(monthStr)/\(day)"
    }

    var calendarDisplayString: String {
        if day == 1 {
            return "Mùng 1"
        } else if let canChi = canChi {
            return "\(day) \(canChi.displayName)"
        } else {
            return "\(day)"
        }
    }

    // MARK: - Initializer
    init(year: Int, month: Int, day: Int, isLeapMonth: Bool = false, canChi: CanChiInfo? = nil) {
        self.year = year
        self.month = month
        self.day = day
        self.isLeapMonth = isLeapMonth
        self.canChi = canChi
    }

    // MARK: - Hashable Implementation
    func hash(into hasher: inout Hasher) {
        hasher.combine(year)
        hasher.combine(month)
        hasher.combine(day)
        hasher.combine(isLeapMonth)
        hasher.combine(canChi)
    }

    static func == (lhs: LunarDateInfo, rhs: LunarDateInfo) -> Bool {
        lhs.year == rhs.year &&
        lhs.month == rhs.month &&
        lhs.day == rhs.day &&
        lhs.isLeapMonth == rhs.isLeapMonth &&
        lhs.canChi == rhs.canChi
    }
}
