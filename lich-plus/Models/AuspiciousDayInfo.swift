import Foundation

// MARK: - Day Type Enum
enum DayType: String, Codable, Hashable {
    case auspicious
    case inauspicious
    case neutral
}

// MARK: - Auspicious Day Information
struct AuspiciousDayInfo: Codable, Hashable {
    var type: DayType
    var reason: String?

    // MARK: - Initializer
    init(type: DayType, reason: String? = nil) {
        self.type = type
        self.reason = reason
    }

    // MARK: - Hashable Implementation
    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        hasher.combine(reason)
    }

    // MARK: - Equatable Implementation
    static func == (lhs: AuspiciousDayInfo, rhs: AuspiciousDayInfo) -> Bool {
        lhs.type == rhs.type && lhs.reason == rhs.reason
    }
}
