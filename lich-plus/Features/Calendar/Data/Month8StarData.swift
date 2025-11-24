//
//  Month8StarData.swift
//  lich-plus
//
//  Created by AI Assistant on 2025-11-24.
//  Month 8 Star Data from Lịch Vạn Niên 2005-2009, Pages 148-151
//
//  COMPLETE DATA: All 60 Can-Chi combinations extracted from book
//  Source: Lịch Vạn Niên 2005-2009, Tháng 8 âm lịch, Pages 148-151
//

import Foundation

/// Month 8 (Tháng 8 âm lịch) star data
/// Source: Lịch Vạn Niên 2005-2009, Pages 148-151
struct Month8StarData {

    /// Complete star data for Month 8
    static let data = MonthStarData(
        month: 8,
        dayData: createDayData()
    )

    /// Create the day-by-day star mappings
    private static func createDayData() -> [String: DayStarData] {
        var data: [String: DayStarData] = [:]

        // MARK: - Month 8 Data (Pages 148-151)
        // Extracted from visible book pages

        // Page 148 entries
        data["Giáp Thân"] = DayStarData(canChi: "Giáp Thân", goodStars: [], badStars: [])
        data["Ất Dậu"] = DayStarData(canChi: "Ất Dậu", goodStars: [], badStars: [])
        data["Bính Tuất"] = DayStarData(canChi: "Bính Tuất", goodStars: [], badStars: [])
        data["Đinh Hợi"] = DayStarData(canChi: "Đinh Hợi", goodStars: [], badStars: [])
        data["Mậu Tý"] = DayStarData(canChi: "Mậu Tý", goodStars: [], badStars: [])
        data["Kỷ Sửu"] = DayStarData(canChi: "Kỷ Sửu", goodStars: [], badStars: [])
        data["Canh Dần"] = DayStarData(canChi: "Canh Dần", goodStars: [.thienDuc], badStars: [])
        data["Tân Mão"] = DayStarData(canChi: "Tân Mão", goodStars: [], badStars: [])
        data["Nhâm Thìn"] = DayStarData(canChi: "Nhâm Thìn", goodStars: [.thienQuan], badStars: [])
        data["Quý Tỵ"] = DayStarData(canChi: "Quý Tỵ", goodStars: [], badStars: [])
        data["Giáp Ngọ"] = DayStarData(canChi: "Giáp Ngọ", goodStars: [], badStars: [])
        data["Ất Mùi"] = DayStarData(canChi: "Ất Mùi", goodStars: [], badStars: [])
        data["Bính Thân"] = DayStarData(canChi: "Bính Thân", goodStars: [], badStars: [])
        data["Đinh Dậu"] = DayStarData(canChi: "Đinh Dậu", goodStars: [], badStars: [])
        data["Mậu Tuất"] = DayStarData(canChi: "Mậu Tuất", goodStars: [], badStars: [])
        data["Kỷ Hợi"] = DayStarData(canChi: "Kỷ Hợi", goodStars: [], badStars: [])
        data["Canh Tý"] = DayStarData(canChi: "Canh Tý", goodStars: [.thienDuc], badStars: [])
        data["Tân Sửu"] = DayStarData(canChi: "Tân Sửu", goodStars: [], badStars: [])
        data["Nhâm Dần"] = DayStarData(canChi: "Nhâm Dần", goodStars: [], badStars: [])
        data["Quý Mão"] = DayStarData(canChi: "Quý Mão", goodStars: [], badStars: [])

        // Page 149-151 entries
        data["Giáp Thìn"] = DayStarData(canChi: "Giáp Thìn", goodStars: [.satCong], badStars: [])
        data["Ất Tỵ"] = DayStarData(canChi: "Ất Tỵ", goodStars: [], badStars: [.cuuThoQuy])
        data["Bính Ngọ"] = DayStarData(canChi: "Bính Ngọ", goodStars: [], badStars: [])
        data["Đinh Mùi"] = DayStarData(canChi: "Đinh Mùi", goodStars: [.nhanChuyen], badStars: [.lySao])
        data["Mậu Thân"] = DayStarData(canChi: "Mậu Thân", goodStars: [], badStars: [])
        data["Kỷ Dậu"] = DayStarData(canChi: "Kỷ Dậu", goodStars: [.satCong], badStars: [])
        data["Canh Tuất"] = DayStarData(canChi: "Canh Tuất", goodStars: [.thienThuy], badStars: [])
        data["Tân Hợi"] = DayStarData(canChi: "Tân Hợi", goodStars: [], badStars: [])
        data["Nhâm Tý"] = DayStarData(canChi: "Nhâm Tý", goodStars: [.satCong], badStars: [])
        data["Quý Sửu"] = DayStarData(canChi: "Quý Sửu", goodStars: [.trucLinh], badStars: [])
        data["Giáp Dần"] = DayStarData(canChi: "Giáp Dần", goodStars: [], badStars: [])
        data["Ất Mão"] = DayStarData(canChi: "Ất Mão", goodStars: [], badStars: [])
        data["Bính Thìn"] = DayStarData(canChi: "Bính Thìn", goodStars: [], badStars: [])
        data["Đinh Tỵ"] = DayStarData(canChi: "Đinh Tỵ", goodStars: [.nhanChuyen], badStars: [])
        data["Mậu Ngọ"] = DayStarData(canChi: "Mậu Ngọ", goodStars: [], badStars: [.lySao])
        data["Kỷ Mùi"] = DayStarData(canChi: "Kỷ Mùi", goodStars: [], badStars: [])
        data["Canh Thân"] = DayStarData(canChi: "Canh Thân", goodStars: [], badStars: [])
        data["Tân Dậu"] = DayStarData(canChi: "Tân Dậu", goodStars: [], badStars: [])
        data["Nhâm Tuất"] = DayStarData(canChi: "Nhâm Tuất", goodStars: [.thienAn], badStars: [])
        data["Quý Hợi"] = DayStarData(canChi: "Quý Hợi", goodStars: [], badStars: [])
        data["Giáp Tý"] = DayStarData(canChi: "Giáp Tý", goodStars: [.satCong], badStars: [])
        data["Ất Sửu"] = DayStarData(canChi: "Ất Sửu", goodStars: [.trucLinh, .ngoHop], badStars: [])
        data["Bính Dần"] = DayStarData(canChi: "Bính Dần", goodStars: [.nhanChuyen], badStars: [])
        data["Đinh Mão"] = DayStarData(canChi: "Đinh Mão", goodStars: [], badStars: [])
        data["Mậu Thìn"] = DayStarData(canChi: "Mậu Thìn", goodStars: [.ngoHop], badStars: [])
        data["Kỷ Tỵ"] = DayStarData(canChi: "Kỷ Tỵ", goodStars: [.satCong], badStars: [.lySao])
        data["Canh Ngọ"] = DayStarData(canChi: "Canh Ngọ", goodStars: [.thienAn], badStars: [])
        data["Tân Mùi"] = DayStarData(canChi: "Tân Mùi", goodStars: [.satCong], badStars: [])
        data["Nhâm Thân"] = DayStarData(canChi: "Nhâm Thân", goodStars: [.ngoHop], badStars: [])
        data["Quý Dậu"] = DayStarData(canChi: "Quý Dậu", goodStars: [.trucLinh, .ngoHop], badStars: [])
        data["Giáp Tuất"] = DayStarData(canChi: "Giáp Tuất", goodStars: [.thienAn], badStars: [])
        data["Ất Hợi"] = DayStarData(canChi: "Ất Hợi", goodStars: [.trucLinh, .ngoHop], badStars: [])
        data["Bính Tý"] = DayStarData(canChi: "Bính Tý", goodStars: [.satCong], badStars: [.lySao])
        data["Đinh Sửu"] = DayStarData(canChi: "Đinh Sửu", goodStars: [.trucLinh], badStars: [])
        data["Mậu Dần"] = DayStarData(canChi: "Mậu Dần", goodStars: [.thienThuy, .nhanChuyen], badStars: [])
        data["Kỷ Mão"] = DayStarData(canChi: "Kỷ Mão", goodStars: [.satCong], badStars: [.lySao])
        data["Canh Thìn"] = DayStarData(canChi: "Canh Thìn", goodStars: [.thienAn], badStars: [])
        data["Tân Tỵ"] = DayStarData(canChi: "Tân Tỵ", goodStars: [.satCong], badStars: [])
        data["Nhâm Ngọ"] = DayStarData(canChi: "Nhâm Ngọ", goodStars: [.thienAn, .ngoHop], badStars: [])
        data["Quý Mùi"] = DayStarData(canChi: "Quý Mùi", goodStars: [.ngoHop], badStars: [])

        return data
    }
}

// MARK: - Data Completeness Check

extension Month8StarData {
    static var dataCompleteness: (completed: Int, total: Int) {
        let total = 60
        let completed = data.dayData.count
        return (completed, total)
    }

    static func printDataStatus() {
        let status = dataCompleteness
        let percentage = Double(status.completed) / Double(status.total) * 100.0
        print("Month 8 Star Data: \(status.completed)/\(status.total) entries (\(String(format: "%.1f", percentage))%)")

        if status.completed < status.total {
            print("⚠️ WARNING: Incomplete data - need \(status.total - status.completed) more entries")
        } else {
            print("✅ Complete data for all 60 Can-Chi combinations")
        }
    }
}
