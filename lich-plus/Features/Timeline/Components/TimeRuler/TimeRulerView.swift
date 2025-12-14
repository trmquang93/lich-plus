//
//  TimeRulerView.swift
//  lich-plus
//
//  Full 24-hour time ruler column for timeline view
//  Displays Vietnamese Chi names and auspicious hour indicators
//

import SwiftUI

struct TimeRulerView: View {
    let hourHeight: CGFloat
    let auspiciousHours: Set<Int>  // Hours that are auspicious today (0-11, representing 2-hour blocks)
    let currentHour: Int           // Current hour for past/present detection (0-23)

    var body: some View {
        LazyVStack(spacing: 0) {
            ForEach(0..<24, id: \.self) { hour in
                TimeRulerCell(
                    hour: hour,
                    chiHour: Self.chiForHour(hour),
                    hoangDaoLevel: hoangDaoLevelForHour(hour),
                    isPast: hour < currentHour,
                    hourHeight: hourHeight
                )
            }
        }
        .frame(width: 50)
    }

    // MARK: - Hour to Chi Mapping

    /// Map a 24-hour format hour (0-23) to its corresponding Chi (Earthly Branch)
    /// Each Chi covers a 2-hour period
    ///
    /// Mapping:
    /// - 23-01: Tý (Hour 0-1, wraps from 23)
    /// - 01-03: Sửu (Hour 1-3)
    /// - 03-05: Dần (Hour 3-5)
    /// - 05-07: Mão (Hour 5-7)
    /// - 07-09: Thìn (Hour 7-9)
    /// - 09-11: Tỵ (Hour 9-11)
    /// - 11-13: Ngọ (Hour 11-13)
    /// - 13-15: Mùi (Hour 13-15)
    /// - 15-17: Thân (Hour 15-17)
    /// - 17-19: Dậu (Hour 17-19)
    /// - 19-21: Tuất (Hour 19-21)
    /// - 21-23: Hợi (Hour 21-23)
    static func chiForHour(_ hour: Int) -> String {
        let chiNames = [
            "Tý",      // 0-1   (23-01)
            "Sửu",     // 1-3   (01-03)
            "Dần",     // 3-5   (03-05)
            "Mão",     // 5-7   (05-07)
            "Thìn",    // 7-9   (07-09)
            "Tỵ",      // 9-11  (09-11)
            "Ngọ",     // 11-13 (11-13)
            "Mùi",     // 13-15 (13-15)
            "Thân",    // 15-17 (15-17)
            "Dậu",     // 17-19 (17-19)
            "Tuất",    // 19-21 (19-21)
            "Hợi"      // 21-23 (21-23)
        ]

        // Map hour to Chi index (0-11)
        // Each Chi covers 2 hours, but we need to handle the mapping correctly
        // Hour 0 = Tý, Hour 1 = Tý, Hour 2 = Sửu, Hour 3 = Sửu, etc.
        let chiIndex = hour / 2
        return chiNames[chiIndex]
    }

    // MARK: - Hoang Dao Level Calculation

    /// Determine the hoang dao star level for a given hour
    /// The hoang dao hours are part of a 2-hour Chi period
    /// If that Chi period is auspicious, return 1-2 stars
    ///
    /// - Parameter hour: Hour in 24-hour format (0-23)
    /// - Returns: Level (0 = not auspicious, 1-2 = auspicious with stars)
    private func hoangDaoLevelForHour(_ hour: Int) -> Int {
        // Get the Chi index (0-11) for this hour
        // Each Chi covers 2 hours
        let chiIndex = hour / 2

        // Check if this Chi period is auspicious
        if auspiciousHours.contains(chiIndex) {
            // Return 1 or 2 stars based on hour position within the Chi period
            // First hour of the period gets 1 star, second hour gets 2 stars
            let positionInChiPeriod = hour % 2
            return positionInChiPeriod == 0 ? 1 : 2
        }

        return 0
    }
}

#Preview {
    // Create a preview with realistic auspicious hours
    // Simulate today's auspicious hours from HoangDaoCalculator
    let currentHour = Calendar.current.component(.hour, from: Date())
    let auspiciousHours: Set<Int> = [0, 1, 4, 5, 7, 10]  // Sample auspicious Chi periods

    ScrollView {
        TimeRulerView(
            hourHeight: 60,
            auspiciousHours: auspiciousHours,
            currentHour: currentHour
        )
        .background(AppColors.background)
    }
}
