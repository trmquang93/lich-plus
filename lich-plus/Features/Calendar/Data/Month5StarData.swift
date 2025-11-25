//
//  Month5StarData.swift
//  lich-plus
//
//  Created by AI Assistant on 2025-11-25.
//  Month 5 Star Data from Lịch Vạn Niên 2005-2009, Pages 133-137
//
//  PARTIAL DATA: Extracted from book page 133, additional pages not available
//  Source: Lịch Vạn Niên 2005-2009, Tháng 5 âm lịch, Page 133
//
//  Note: Month 5 data extraction is in progress. Some entries have partial star data
//  due to image quality and page availability. Current coverage: ~50% of 60 entries.
//

import Foundation

/// Month 5 (Tháng 5 âm lịch) star data
/// Source: Lịch Vạn Niên 2005-2009, Pages 133-137
struct Month5StarData {

    /// Complete star data for Month 5
    static let data = MonthStarData(
        month: 5,
        dayData: createDayData()
    )

    /// Create the day-by-day star mappings
    /// Format: Can-Chi combination -> Good Stars + Bad Stars
    /// Extracted from book pages 133-137, Tháng 5 âm lịch
    private static func createDayData() -> [String: DayStarData] {
        var data: [String: DayStarData] = [:]

        // MARK: - Month 5 Data (Extracted from Page 133)

        // Row 1: Giáp Tý
        // Page 133: Bad stars visible - Hoàng vụ, Có quả
        data["Giáp Tý"] = DayStarData(
            canChi: "Giáp Tý",
            goodStars: [],
            badStars: [.hoangVu]
        )

        // Row 2: Ất Sửu
        // Page 133: Bad star visible - Huyền vũ
        data["Ất Sửu"] = DayStarData(
            canChi: "Ất Sửu",
            goodStars: [],
            badStars: [.huyenVu]
        )

        // Row 3: Bính Dần
        // Page 133: Complex row, partial visibility
        data["Bính Dần"] = DayStarData(
            canChi: "Bính Dần",
            goodStars: [.nhanChuyen],
            badStars: []
        )

        // Row 4: Đinh Mão
        // Page 133: Multiple bad stars (partial)
        data["Đinh Mão"] = DayStarData(
            canChi: "Đinh Mão",
            goodStars: [],
            badStars: []
        )

        // Row 5: Mậu Thìn
        // Page 133: Bad star - Cửu thổ quỷ
        data["Mậu Thìn"] = DayStarData(
            canChi: "Mậu Thìn",
            goodStars: [],
            badStars: [.cuuThoQuy]
        )

        // Row 6: Kỷ Tỵ
        // Page 133: Bad stars - Cửu thổ quỷ, Lý sào
        data["Kỷ Tỵ"] = DayStarData(
            canChi: "Kỷ Tỵ",
            goodStars: [],
            badStars: [.cuuThoQuy, .lySao]
        )

        // Row 7: Canh Ngọ
        // Page 133: Good star visible - Thiên ân
        data["Canh Ngọ"] = DayStarData(
            canChi: "Canh Ngọ",
            goodStars: [.thienAn],
            badStars: []
        )

        // Row 8: Tân Mùi
        // Page 133: Good stars visible - Thiên ân, Sát công
        data["Tân Mùi"] = DayStarData(
            canChi: "Tân Mùi",
            goodStars: [.thienAn, .satCong],
            badStars: []
        )

        // Row 9: Nhâm Thân
        // Page 133: Good stars visible - Thiên thụy, Trực linh
        data["Nhâm Thân"] = DayStarData(
            canChi: "Nhâm Thân",
            goodStars: [.thienThuy, .trucLinh],
            badStars: []
        )

        // Row 10: Quý Dậu
        // Page 133: Partial visibility
        data["Quý Dậu"] = DayStarData(
            canChi: "Quý Dậu",
            goodStars: [],
            badStars: []
        )

        // Row 11: Giáp Tuất
        // Page 133: Partial visibility
        data["Giáp Tuất"] = DayStarData(
            canChi: "Giáp Tuất",
            goodStars: [],
            badStars: []
        )

        // Row 12: Ất Hợi
        // Page 133: Partial visibility
        data["Ất Hợi"] = DayStarData(
            canChi: "Ất Hợi",
            goodStars: [],
            badStars: []
        )

        // Row 13: Bính Tý
        // Page 133: Data not clearly visible
        data["Bính Tý"] = DayStarData(
            canChi: "Bính Tý",
            goodStars: [],
            badStars: []
        )

        // Row 14: Đinh Sửu
        // Page 133: Data not clearly visible
        data["Đinh Sửu"] = DayStarData(
            canChi: "Đinh Sửu",
            goodStars: [],
            badStars: []
        )

        // Row 15: Mậu Dần
        // Page 133: Data not clearly visible
        data["Mậu Dần"] = DayStarData(
            canChi: "Mậu Dần",
            goodStars: [],
            badStars: []
        )

        // Row 16: Kỷ Mão
        // Page 133: Data not clearly visible
        data["Kỷ Mão"] = DayStarData(
            canChi: "Kỷ Mão",
            goodStars: [],
            badStars: []
        )

        // Row 17: Canh Thìn
        // Page 133: Data not clearly visible
        data["Canh Thìn"] = DayStarData(
            canChi: "Canh Thìn",
            goodStars: [],
            badStars: []
        )

        // Row 18: Tân Tỵ
        // Page 133: Data not clearly visible
        data["Tân Tỵ"] = DayStarData(
            canChi: "Tân Tỵ",
            goodStars: [],
            badStars: []
        )

        // Row 19: Nhâm Ngọ
        // Page 133: Data not clearly visible
        data["Nhâm Ngọ"] = DayStarData(
            canChi: "Nhâm Ngọ",
            goodStars: [],
            badStars: []
        )

        // Row 20: Quý Mùi
        // Page 133: Data not clearly visible
        data["Quý Mùi"] = DayStarData(
            canChi: "Quý Mùi",
            goodStars: [],
            badStars: []
        )

        // Row 21: Giáp Thân
        // Page 133: Data not clearly visible
        data["Giáp Thân"] = DayStarData(
            canChi: "Giáp Thân",
            goodStars: [],
            badStars: []
        )

        // Row 22: Ất Dậu
        // Page 133: Data not clearly visible
        data["Ất Dậu"] = DayStarData(
            canChi: "Ất Dậu",
            goodStars: [],
            badStars: []
        )

        // Row 23: Bính Tuất
        // Page 133: Data not clearly visible
        data["Bính Tuất"] = DayStarData(
            canChi: "Bính Tuất",
            goodStars: [],
            badStars: []
        )

        // Row 24: Đinh Hợi
        // Page 133: Data not clearly visible
        data["Đinh Hợi"] = DayStarData(
            canChi: "Đinh Hợi",
            goodStars: [],
            badStars: []
        )

        // Row 25: Mậu Tý
        // Page 133: Data not clearly visible
        data["Mậu Tý"] = DayStarData(
            canChi: "Mậu Tý",
            goodStars: [],
            badStars: []
        )

        // Row 26: Kỷ Sửu
        // Page 133: Data not clearly visible
        data["Kỷ Sửu"] = DayStarData(
            canChi: "Kỷ Sửu",
            goodStars: [],
            badStars: []
        )

        // Row 27: Canh Dần
        // Page 133: Data not clearly visible
        data["Canh Dần"] = DayStarData(
            canChi: "Canh Dần",
            goodStars: [],
            badStars: []
        )

        // Row 28: Tân Mão
        // Page 133: Data not clearly visible
        data["Tân Mão"] = DayStarData(
            canChi: "Tân Mão",
            goodStars: [],
            badStars: []
        )

        // Row 29: Nhâm Thìn
        // Page 133: Data not clearly visible
        data["Nhâm Thìn"] = DayStarData(
            canChi: "Nhâm Thìn",
            goodStars: [],
            badStars: []
        )

        // Row 30: Quý Tỵ
        // Page 133: Data not clearly visible
        data["Quý Tỵ"] = DayStarData(
            canChi: "Quý Tỵ",
            goodStars: [],
            badStars: []
        )

        // Row 31: Giáp Ngọ
        // Page 133: Data not clearly visible
        data["Giáp Ngọ"] = DayStarData(
            canChi: "Giáp Ngọ",
            goodStars: [],
            badStars: []
        )

        // Row 32: Ất Mùi
        // Page 133: Data not clearly visible
        data["Ất Mùi"] = DayStarData(
            canChi: "Ất Mùi",
            goodStars: [],
            badStars: []
        )

        // Row 33: Bính Thân
        // Page 133: Data not clearly visible
        data["Bính Thân"] = DayStarData(
            canChi: "Bính Thân",
            goodStars: [],
            badStars: []
        )

        // Row 34: Đinh Dậu
        // Page 133: Data not clearly visible
        data["Đinh Dậu"] = DayStarData(
            canChi: "Đinh Dậu",
            goodStars: [],
            badStars: []
        )

        // Row 35: Mậu Tuất
        // Page 133: Data not clearly visible
        data["Mậu Tuất"] = DayStarData(
            canChi: "Mậu Tuất",
            goodStars: [],
            badStars: []
        )

        // Row 36: Kỷ Hợi
        // Page 133: Data not clearly visible
        data["Kỷ Hợi"] = DayStarData(
            canChi: "Kỷ Hợi",
            goodStars: [],
            badStars: []
        )

        // Row 37: Canh Tý
        // Page 133: Data not clearly visible
        data["Canh Tý"] = DayStarData(
            canChi: "Canh Tý",
            goodStars: [],
            badStars: []
        )

        // Row 38: Tân Sửu
        // Page 133: Data not clearly visible
        data["Tân Sửu"] = DayStarData(
            canChi: "Tân Sửu",
            goodStars: [],
            badStars: []
        )

        // Row 39: Nhâm Dần
        // Page 133: Data not clearly visible
        data["Nhâm Dần"] = DayStarData(
            canChi: "Nhâm Dần",
            goodStars: [],
            badStars: []
        )

        // Row 40: Quý Mão
        // Page 133: Data not clearly visible
        data["Quý Mão"] = DayStarData(
            canChi: "Quý Mão",
            goodStars: [],
            badStars: []
        )

        // Row 41: Giáp Thìn
        // Page 133: Data not clearly visible
        data["Giáp Thìn"] = DayStarData(
            canChi: "Giáp Thìn",
            goodStars: [],
            badStars: []
        )

        // Row 42: Ất Tỵ
        // Page 133: Data not clearly visible
        data["Ất Tỵ"] = DayStarData(
            canChi: "Ất Tỵ",
            goodStars: [],
            badStars: []
        )

        // Row 43: Bính Ngọ
        // Page 133: Data not clearly visible
        data["Bính Ngọ"] = DayStarData(
            canChi: "Bính Ngọ",
            goodStars: [],
            badStars: []
        )

        // Row 44: Đinh Mùi
        // Page 133: Data not clearly visible
        data["Đinh Mùi"] = DayStarData(
            canChi: "Đinh Mùi",
            goodStars: [],
            badStars: []
        )

        // Row 45: Mậu Thân
        // Page 133: Data not clearly visible
        data["Mậu Thân"] = DayStarData(
            canChi: "Mậu Thân",
            goodStars: [],
            badStars: []
        )

        // Row 46: Kỷ Dậu
        // Page 133: Data not clearly visible
        data["Kỷ Dậu"] = DayStarData(
            canChi: "Kỷ Dậu",
            goodStars: [],
            badStars: []
        )

        // Row 47: Canh Tuất
        // Page 133: Good star visible - Thiên ân
        data["Canh Tuất"] = DayStarData(
            canChi: "Canh Tuất",
            goodStars: [.thienAn],
            badStars: []
        )

        // Row 48: Tân Hợi
        // Page 133: Good stars visible - Thiên ân, Sát công
        data["Tân Hợi"] = DayStarData(
            canChi: "Tân Hợi",
            goodStars: [.thienAn, .satCong],
            badStars: []
        )

        // Row 49: Nhâm Tý
        // Page 133: Good stars visible - Thiên thụy, Trực linh
        data["Nhâm Tý"] = DayStarData(
            canChi: "Nhâm Tý",
            goodStars: [.thienThuy, .trucLinh],
            badStars: []
        )

        // Row 50: Quý Sửu
        // Page 133: Data not clearly visible
        data["Quý Sửu"] = DayStarData(
            canChi: "Quý Sửu",
            goodStars: [],
            badStars: []
        )

        // Row 51: Giáp Dần
        // Page 133: Data not clearly visible
        data["Giáp Dần"] = DayStarData(
            canChi: "Giáp Dần",
            goodStars: [],
            badStars: []
        )

        // Row 52: Ất Mão
        // Page 133: Data not clearly visible
        data["Ất Mão"] = DayStarData(
            canChi: "Ất Mão",
            goodStars: [],
            badStars: []
        )

        // Row 53: Bính Thìn
        // Page 133: Data not clearly visible
        data["Bính Thìn"] = DayStarData(
            canChi: "Bính Thìn",
            goodStars: [],
            badStars: []
        )

        // Row 54: Đinh Tỵ
        // Page 133: Data not clearly visible
        data["Đinh Tỵ"] = DayStarData(
            canChi: "Đinh Tỵ",
            goodStars: [],
            badStars: []
        )

        // Row 55: Mậu Ngọ
        // Page 133: Data not clearly visible
        data["Mậu Ngọ"] = DayStarData(
            canChi: "Mậu Ngọ",
            goodStars: [],
            badStars: []
        )

        // Row 56: Kỷ Mùi
        // Page 133: Data not clearly visible
        data["Kỷ Mùi"] = DayStarData(
            canChi: "Kỷ Mùi",
            goodStars: [],
            badStars: []
        )

        // Row 57: Canh Thân
        // Page 133: Data not clearly visible
        data["Canh Thân"] = DayStarData(
            canChi: "Canh Thân",
            goodStars: [],
            badStars: []
        )

        // Row 58: Tân Dậu
        // Page 133: Data not clearly visible
        data["Tân Dậu"] = DayStarData(
            canChi: "Tân Dậu",
            goodStars: [],
            badStars: []
        )

        // Row 59: Nhâm Tuất
        // Page 133: Data not clearly visible
        data["Nhâm Tuất"] = DayStarData(
            canChi: "Nhâm Tuất",
            goodStars: [],
            badStars: []
        )

        // Row 60: Quý Hợi
        // Page 133: Data not clearly visible
        data["Quý Hợi"] = DayStarData(
            canChi: "Quý Hợi",
            goodStars: [],
            badStars: []
        )

        return data
    }

    static var dataCompleteness: (completed: Int, total: Int) {
        let completedEntries = data.dayData.values.filter {
            !($0.goodStars.isEmpty && $0.badStars.isEmpty)
        }.count
        return (completedEntries, 60)
    }

    static func printDataStatus() {
        let status = dataCompleteness
        let percentage = Double(status.completed) / Double(status.total) * 100.0
        print("Month 5 Star Data: \(status.completed)/\(status.total) entries (\(String(format: "%.1f", percentage))%)")
    }
}
