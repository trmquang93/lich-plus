import Foundation

// MARK: - Can Chi Calculator
class CanChiCalculator {
    // MARK: - Constants

    // Thiên Can (Heavenly Stems) - 10 elements
    private static let thienCan: [String] = [
        "Giáp", "Ất", "Bính", "Đinh", "Mậu",
        "Kỷ", "Canh", "Tân", "Nhâm", "Quý"
    ]

    // Địa Chi (Earthly Branches) - 12 elements
    private static let diaChi: [String] = [
        "Tý", "Sửu", "Dần", "Mão", "Thìn", "Tỵ",
        "Ngọ", "Mùi", "Thân", "Dậu", "Tuất", "Hợi"
    ]

    // Julian Day Number epoch: January 1, 2000 at 00:00:00
    private static let jdnEpoch = 2451545.0

    // Maximum cache size to prevent memory growth
    private static let maxCacheSize = 1000

    // MARK: - Cache
    private static var cache = [Double: CanChiInfo]()

    // MARK: - Public Methods

    /// Calculate Can Chi for a given Julian Day Number
    /// - Parameter jdn: Julian Day Number
    /// - Returns: CanChiInfo with Can and Chi values
    static func calculateCanChi(for jdn: Double) -> CanChiInfo {
        // Check cache first
        if let cached = cache[jdn] {
            return cached
        }

        // Calculate offset from epoch
        let offset = Int(jdn - jdnEpoch)

        // Calculate Can index
        // JDN 2451545.0 (January 1, 2000) = Giáp Tý (index 0, 0)
        let canIndex = offset % 10
        let normalizedCanIndex = canIndex >= 0 ? canIndex : canIndex + 10

        // Calculate Chi index
        // JDN 2451545.0 (January 1, 2000) = Giáp Tý (index 0, 0)
        let chiIndex = offset % 12
        let normalizedChiIndex = chiIndex >= 0 ? chiIndex : chiIndex + 12

        // Get Can and Chi strings
        let can = thienCan[normalizedCanIndex]
        let chi = diaChi[normalizedChiIndex]

        // Create CanChiInfo
        let canChi = CanChiInfo(can: can, chi: chi)

        // Store in cache (with size limit)
        if cache.count < maxCacheSize {
            cache[jdn] = canChi
        } else if cache.count == maxCacheSize {
            // Clear cache when reaching limit to prevent unbounded growth
            cache.removeAll()
            cache[jdn] = canChi
        }

        return canChi
    }

    /// Calculate Can Chi for a given Date
    /// - Parameter date: Date to calculate Can Chi for
    /// - Returns: CanChiInfo with Can and Chi values
    static func calculateCanChi(for date: Date) -> CanChiInfo {
        // Convert date to Julian Day Number
        let jdn = LunarCalendarConverter.dateToJDN(date)

        // Calculate Can Chi using JDN
        return calculateCanChi(for: jdn)
    }

    // MARK: - Cache Management

    /// Clear the internal cache
    /// This can be useful for memory management in long-running apps
    static func clearCache() {
        cache.removeAll()
    }

    /// Get current cache size
    /// Useful for testing and monitoring
    static func getCacheSize() -> Int {
        return cache.count
    }
}
