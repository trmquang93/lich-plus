import Foundation

// MARK: - Auspicious Day Service Protocol

/// Protocol defining the interface for retrieving auspicious day information
/// This design allows easy swapping between different implementations
/// (e.g., static rules, API calls, or lunar calendar libraries)
protocol AuspiciousDayServiceProtocol {
    /// Get auspicious day information for a given date
    /// - Parameter date: The solar date to check
    /// - Returns: AuspiciousDayInfo containing the day type and optional reason
    func getAuspiciousInfo(for date: Date) -> AuspiciousDayInfo
}

// MARK: - Static Auspicious Day Service

/// Static implementation of auspicious day service using simplified rules
///
/// **IMPORTANT**: This is a PLACEHOLDER implementation with simplified rules.
/// The real Vietnamese lunar calendar uses the 12 Trực (Twelve Officers) system
/// which is much more complex and considers multiple factors.
///
/// **Simplified Rules**:
/// - Lunar days 1, 15, 16: AUSPICIOUS (good for important activities)
/// - Lunar days 7, 14, 23: INAUSPICIOUS (avoid important activities)
/// - All other days: NEUTRAL (normal days)
///
/// **Future Integration**:
/// This service can be easily replaced with a real API or library:
/// ```swift
/// AuspiciousDayServiceFactory.setService(APIAuspiciousDayService())
/// ```
class StaticAuspiciousDayService: AuspiciousDayServiceProtocol {

    // MARK: - Auspicious Day Rules

    /// Lunar days considered auspicious (good fortune)
    private let auspiciousDays: Set<Int> = [1, 15, 16]

    /// Lunar days considered inauspicious (avoid important activities)
    private let inauspiciousDays: Set<Int> = [7, 14, 23]

    // MARK: - Public Methods

    func getAuspiciousInfo(for date: Date) -> AuspiciousDayInfo {
        // Convert solar date to lunar date
        let lunarDate = LunarCalendarConverter.getLunarDate(for: date)
        let lunarDay = lunarDate.day

        // Check day type based on lunar day
        if auspiciousDays.contains(lunarDay) {
            return createAuspiciousInfo(lunarDay: lunarDay)
        } else if inauspiciousDays.contains(lunarDay) {
            return createInauspiciousInfo(lunarDay: lunarDay)
        } else {
            return createNeutralInfo()
        }
    }

    // MARK: - Private Helper Methods

    /// Create auspicious day information with Vietnamese reason
    private func createAuspiciousInfo(lunarDay: Int) -> AuspiciousDayInfo {
        let reason: String
        switch lunarDay {
        case 1:
            reason = "Mùng 1 - Ngày tốt, thích hợp làm việc quan trọng"
        case 15:
            reason = "Rằm - Ngày tốt, thích hợp cúng bái và làm việc quan trọng"
        case 16:
            reason = "16 Âm lịch - Ngày tốt, thích hợp khởi công"
        default:
            reason = "Ngày tốt"
        }
        return AuspiciousDayInfo(type: .auspicious, reason: reason)
    }

    /// Create inauspicious day information with Vietnamese reason
    private func createInauspiciousInfo(lunarDay: Int) -> AuspiciousDayInfo {
        let reason: String
        switch lunarDay {
        case 7:
            reason = "Ngày xấu - Tránh các công việc quan trọng"
        case 14:
            reason = "Ngày xấu - Tránh khởi công và việc quan trọng"
        case 23:
            reason = "Ngày xấu - Không nên làm việc quan trọng"
        default:
            reason = "Ngày xấu"
        }
        return AuspiciousDayInfo(type: .inauspicious, reason: reason)
    }

    /// Create neutral day information (no special significance)
    private func createNeutralInfo() -> AuspiciousDayInfo {
        return AuspiciousDayInfo(type: .neutral, reason: nil)
    }
}

// MARK: - Auspicious Day Service Factory

/// Factory for creating and managing auspicious day service instances
/// Enables dependency injection and easy swapping of service implementations
class AuspiciousDayServiceFactory {

    // MARK: - Shared Instance

    /// The shared service instance (can be swapped via setService)
    static var shared: AuspiciousDayServiceProtocol = StaticAuspiciousDayService()

    // MARK: - Service Management

    /// Set a custom service implementation (useful for testing or API integration)
    /// - Parameter service: The service to use as the shared instance
    ///
    /// **Example usage**:
    /// ```swift
    /// // For testing
    /// AuspiciousDayServiceFactory.setService(MockAuspiciousDayService())
    ///
    /// // For API integration
    /// AuspiciousDayServiceFactory.setService(APIAuspiciousDayService())
    /// ```
    static func setService(_ service: AuspiciousDayServiceProtocol) {
        shared = service
    }

    /// Reset to default static service implementation
    static func resetToDefault() {
        shared = StaticAuspiciousDayService()
    }

    // Private init to prevent instantiation
    private init() {}
}
