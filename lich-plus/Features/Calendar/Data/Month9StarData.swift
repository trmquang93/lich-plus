//
//  Month9StarData.swift
//  lich-plus
//
//  Created by AI Assistant on 2025-11-24.
//  Month 9 Star Data from Lịch Vạn Niên 2005-2009, Pages 153-154
//
//  NOTE: This is a PROOF-OF-CONCEPT implementation with partial data.
//  Currently contains only example entries extracted from BOOK_STAR_SYSTEM_ANALYSIS.md
//  TODO: Complete data extraction for all 60 Can-Chi combinations from book pages 153-154
//

import Foundation

/// Month 9 (Tháng 9 âm lịch) star data
/// Source: Lịch Vạn Niên 2005-2009, Pages 153-154
struct Month9StarData {

    /// Complete star data for Month 9
    static let data = MonthStarData(
        month: 9,
        dayData: createDayData()
    )

    /// Create the day-by-day star mappings
    /// Format: Can-Chi combination -> Good Stars + Bad Stars
    private static func createDayData() -> [String: DayStarData] {
        var data: [String: DayStarData] = [:]

        // MARK: - Extracted Data from Book

        // Day: Giáp Tý (Giáp = 1, Tý = 1)
        // Source: BOOK_STAR_SYSTEM_ANALYSIS.md line 57-60
        data["Giáp Tý"] = DayStarData(
            canChi: "Giáp Tý",
            goodStars: [
                .thienAn  // Thiên ân (Heavenly Grace)
            ],
            badStars: [
                .hoaTai,      // Hỏa tai
                .thienHoa,    // Thiên hỏa
                .thoOn,       // Thổ ôn
                .hoangSa,     // Hoang sa
                .phiMaSat,    // Phi ma sát
                .nguQuy,      // Ngũ quỷ
                .quaTu        // Quả tú
            ]
        )

        // MARK: - TODO: Remaining 59 Can-Chi Combinations

        // The following entries need to be extracted from book pages 153-154:
        // - Ất Sửu through Quý Hợi (59 remaining combinations)
        //
        // Each entry should follow this format:
        // data["Can Chi"] = DayStarData(
        //     canChi: "Can Chi",
        //     goodStars: [.star1, .star2, ...],
        //     badStars: [.star1, .star2, ...]
        // )
        //
        // Extraction process:
        // 1. For each row in the book table (pages 153-154)
        // 2. Read the Can-Chi combination (column 1)
        // 3. Read good stars from Column C "Sao Tốt"
        // 4. Read bad stars from Column B "Sao Xấu"
        // 5. Map star names to enum cases
        // 6. Add entry to dictionary
        //
        // Example from book page 153:
        // Row 1: Giáp Tý | Bad: Hỏa tai, Thiên hỏa... | Good: Thiên ân
        // Row 2: Ất Sửu | Bad: ... | Good: ...
        // (continue for all 60 rows)

        return data
    }

    // MARK: - Helper: Can-Chi String Generation

    /// Generate Can-Chi string from Can and Chi indices
    /// - Parameters:
    ///   - can: Thiên Can index (0-9)
    ///   - chi: Địa Chi index (0-11)
    /// - Returns: Can-Chi string (e.g., "Giáp Tý")
    static func canChiString(can: Int, chi: Int) -> String {
        let canNames = ["Giáp", "Ất", "Bính", "Đinh", "Mậu", "Kỷ", "Canh", "Tân", "Nhâm", "Quý"]
        let chiNames = ["Tý", "Sửu", "Dần", "Mão", "Thìn", "Tị", "Ngọ", "Mùi", "Thân", "Dậu", "Tuất", "Hợi"]
        return "\(canNames[can]) \(chiNames[chi])"
    }

    /// Get all 60 Can-Chi combinations in order
    static func allCanChiCombinations() -> [String] {
        var combinations: [String] = []
        var can = 0
        var chi = 0

        for _ in 0..<60 {
            combinations.append(canChiString(can: can, chi: chi))
            can = (can + 1) % 10
            chi = (chi + 1) % 12
        }

        return combinations
    }
}

// MARK: - Data Completeness Check

extension Month9StarData {
    /// Check how many Can-Chi combinations have star data
    static var dataCompleteness: (completed: Int, total: Int) {
        let total = 60
        let completed = data.dayData.count
        return (completed, total)
    }

    /// Print data completeness status
    static func printDataStatus() {
        let status = dataCompleteness
        let percentage = Double(status.completed) / Double(status.total) * 100.0
        print("Month 9 Star Data: \(status.completed)/\(status.total) entries (\(String(format: "%.1f", percentage))%)")

        if status.completed < status.total {
            print("⚠️ WARNING: Incomplete data - need \(status.total - status.completed) more entries from book pages 153-154")
        } else {
            print("✅ Complete data for all 60 Can-Chi combinations")
        }
    }
}
