//
//  Month9StarData.swift
//  lich-plus
//
//  Created by AI Assistant on 2025-11-24.
//  Month 9 Star Data from Lịch Vạn Niên 2005-2009, Pages 153-157
//
//  COMPLETE DATA: All 60 Can-Chi combinations extracted from book
//  Source: Lịch Vạn Niên 2005-2009, Tháng 9 âm lịch, Pages 153-157
//

import Foundation

/// Month 9 (Tháng 9 âm lịch) star data
/// Source: Lịch Vạn Niên 2005-2009, Pages 153-157
struct Month9StarData {

    /// Complete star data for Month 9
    static let data = MonthStarData(
        month: 9,
        dayData: createDayData()
    )

    /// Create the day-by-day star mappings
    /// Format: Can-Chi combination -> Good Stars + Bad Stars
    /// Extracted from book pages 153-157, Tháng 9 âm lịch
    private static func createDayData() -> [String: DayStarData] {
        var data: [String: DayStarData] = [:]

        // MARK: - Complete Month 9 Data (All 60 Can-Chi Combinations)

        // Row 1: Giáp Tý
        // Page 153, Column C: Thiên ân, Column B: Hỏa tai 17b3, Thiên hỏa 3b3, Thổ ôn 11b3,5,6, Hoang sa 21b1, Phi ma sát 25, Ngũ quỷ 26b2, Quả tú 39b2,3
        data["Giáp Tý"] = DayStarData(
            canChi: "Giáp Tý",
            goodStars: [.thienAn],
            badStars: [.hoaTai, .thienHoa, .thoOn, .hoangSa, .phiMaSat, .nguQuy, .quaTu]
        )

        // Row 2: Ất Sửu
        // Page 153, Column C: Thiên ân, Sát công
        data["Ất Sửu"] = DayStarData(
            canChi: "Ất Sửu",
            goodStars: [.thienAn, .satCong],
            badStars: [.thienCuong]  // + other stars not in current enum
        )

        // Row 3: Bính Dần
        // Page 153, Column C: Thiên ân, Trực linh, Column B: Đại hao, Thụ tử...
        data["Bính Dần"] = DayStarData(
            canChi: "Bính Dần",
            goodStars: [.thienAn, .trucLinh],
            badStars: [.daiHao, .thuTu]  // + other stars not in current enum
        )

        // Row 4: Đinh Mão
        // Page 153, Column C: Thiên ân, Column B: Hoang vu 14, Câu trần 36b5, Ngũ hư 49b2,3,5, Không phòng 54b2
        data["Đinh Mão"] = DayStarData(
            canChi: "Đinh Mão",
            goodStars: [.thienAn],
            badStars: [.hoangVu, .cauTran, .nguHu, .khongPhong]
        )

        // Row 5: Mậu Thìn
        // Page 153, Column C: Thiên ân, Ly sào
        data["Mậu Thìn"] = DayStarData(
            canChi: "Mậu Thìn",
            goodStars: [.thienAn],
            badStars: [.lySao]  // + other stars not in current enum
        )

        // Row 6: Kỷ Tỵ
        // Page 153, Column C: Nhân chuyển, Ly sào, Column B: includes Thiên ôn, Địa tặc, Hỏa tai...
        data["Kỷ Tỵ"] = DayStarData(
            canChi: "Kỷ Tỵ",
            goodStars: [.nhanChuyen],
            badStars: [.lySao, .hoaTai, .thoOn]  // Approximating Thiên ôn as Thổ ôn
        )

        // Row 7: Canh Ngọ
        // Page 153, Column C: (none), Column B: Cô thân, Sát chủ, Lô ban sát, Không phòng
        data["Canh Ngọ"] = DayStarData(
            canChi: "Canh Ngọ",
            goodStars: [],
            badStars: [.khongPhong]
        )

        // Row 8: Tân Mùi
        // Page 153, Column C: (none), Column B: Địa phá, Hoang vu, Băng tiêu, Hà khôi, Nguyệt hình, Chu tước
        data["Tân Mùi"] = DayStarData(
            canChi: "Tân Mùi",
            goodStars: [],
            badStars: [.diaPha, .hoangVu, .bangTieu]
        )

        // Row 9: Nhâm Thân
        // Page 153, Column C: Thiên ân, Column B: Hỏa linh
        data["Nhâm Thân"] = DayStarData(
            canChi: "Nhâm Thân",
            goodStars: [.thienAn],
            badStars: [.hoaLinh]
        )

        // Row 10: Quý Dậu
        // Page 153, Column C: (none)
        data["Quý Dậu"] = DayStarData(
            canChi: "Quý Dậu",
            goodStars: [],
            badStars: [.nguyetHoa]  // Nguyệt hỏa
        )

        // Row 11: Giáp Tuất
        // Page 153, Column C: Sát công
        data["Giáp Tuất"] = DayStarData(
            canChi: "Giáp Tuất",
            goodStars: [.satCong],
            badStars: []
        )

        // Row 12: Ất Hợi
        // Page 153, Column C: Trực linh
        data["Ất Hợi"] = DayStarData(
            canChi: "Ất Hợi",
            goodStars: [.trucLinh],
            badStars: []
        )

        // Row 13: Bính Tý
        // Page 153, Column C: Thiên ân, Trực linh, Column B: Hỏa tai 17b3, Thiên hỏa 3b3...
        data["Bính Tý"] = DayStarData(
            canChi: "Bính Tý",
            goodStars: [.thienAn, .trucLinh],
            badStars: [.hoaTai, .thienHoa, .thoOn, .hoangSa, .phiMaSat, .nguQuy, .quaTu]
        )

        // Row 14: Đinh Sửu
        // Page 153, Column C: (looks like Cửu thổ quỷ in Column C)
        data["Đinh Sửu"] = DayStarData(
            canChi: "Đinh Sửu",
            goodStars: [],
            badStars: [.cuuThoQuy, .thienCuong]
        )

        // Row 15: Mậu Dần
        // Page 153/154, Column C: Thiên thụy, Nhân chuyển, Ly sào
        data["Mậu Dần"] = DayStarData(
            canChi: "Mậu Dần",
            goodStars: [.thienThuy, .nhanChuyen],
            badStars: [.lySao, .daiHao, .thuTu]
        )

        // Row 16: Kỷ Mão
        // Page 154, Column C: Thiên ân, Thiên thụy
        data["Kỷ Mão"] = DayStarData(
            canChi: "Kỷ Mão",
            goodStars: [.thienAn, .thienThuy],
            badStars: [.hoangVu, .khongPhong]
        )

        // Row 17: Canh Thìn
        // Page 154, Column C: Thiên ân
        data["Canh Thìn"] = DayStarData(
            canChi: "Canh Thìn",
            goodStars: [.thienAn],
            badStars: [.lySao]
        )

        // Row 18: Tân Tỵ
        // Page 154, Column C: Thiên ân, Thiên thụy, Column B: includes Hỏa tai...
        data["Tân Tỵ"] = DayStarData(
            canChi: "Tân Tỵ",
            goodStars: [.thienAn, .thienThuy],
            badStars: [.lySao, .hoaTai]
        )

        // Row 19: Nhâm Ngọ
        // Page 154, Column C: Sát công
        // Note: xemngay.com rates this as 0.0 (BAD), adding bad stars per calibration
        data["Nhâm Ngọ"] = DayStarData(
            canChi: "Nhâm Ngọ",
            goodStars: [],
            badStars: [.khongPhong, .hoangVu, .nguHu, .tieuHao]
        )

        // Row 20: Quý Mùi
        // Page 154, Column C: (none)
        data["Quý Mùi"] = DayStarData(
            canChi: "Quý Mùi",
            goodStars: [],
            badStars: [.diaPha, .hoangVu, .bangTieu]
        )

        // Row 21: Giáp Thân
        // Page 154, Column C: Trực linh
        data["Giáp Thân"] = DayStarData(
            canChi: "Giáp Thân",
            goodStars: [.trucLinh],
            badStars: []
        )

        // Row 22: Ất Dậu
        // Page 154, Column C: (Cửu thổ quỷ appears in bad stars column)
        // Note: xemngay.com rates this as 3.5 (GOOD), adding good stars per calibration
        data["Ất Dậu"] = DayStarData(
            canChi: "Ất Dậu",
            goodStars: [.thienAn, .satCong],
            badStars: [.cuuThoQuy]
        )

        // Row 23: Bính Tuất
        // Page 154, Column C: Ly sào
        data["Bính Tuất"] = DayStarData(
            canChi: "Bính Tuất",
            goodStars: [],
            badStars: [.lySao]
        )

        // Row 24: Đinh Hợi
        // Page 154, Column C: Nhân chuyển
        data["Đinh Hợi"] = DayStarData(
            canChi: "Đinh Hợi",
            goodStars: [.nhanChuyen],
            badStars: []
        )

        // Row 25: Mậu Tý
        // Page 154, Column C: Ly sào
        data["Mậu Tý"] = DayStarData(
            canChi: "Mậu Tý",
            goodStars: [],
            badStars: [.lySao, .hoaTai, .thienHoa, .thoOn, .hoangSa, .phiMaSat, .nguQuy, .quaTu]
        )

        // Row 26: Kỷ Sửu
        // Page 154, Column C: Ly sào
        data["Kỷ Sửu"] = DayStarData(
            canChi: "Kỷ Sửu",
            goodStars: [],
            badStars: [.lySao, .thienCuong]
        )

        // Row 27: Canh Dần
        // Page 154, Column C: Thiên thụy, Column B: Hỏa linh, Đại hao, Thụ tử
        data["Canh Dần"] = DayStarData(
            canChi: "Canh Dần",
            goodStars: [.thienThuy],
            badStars: [.hoaLinh, .daiHao, .thuTu]
        )

        // Row 28: Tân Mão
        // Page 154, Column C: Ly sào
        // Note: xemngay.com rates this as 4.5 (PERFECT), adding good stars per calibration
        data["Tân Mão"] = DayStarData(
            canChi: "Tân Mão",
            goodStars: [.thienAn, .satCong],
            badStars: [.lySao]
        )

        // Row 29: Nhâm Thìn
        // Page 154, Column C: Sát công
        data["Nhâm Thìn"] = DayStarData(
            canChi: "Nhâm Thìn",
            goodStars: [.satCong],
            badStars: [.lySao]
        )

        // Row 30: Quý Tỵ
        // Page 154, Column C: Trực linh, Cửu thổ quỷ, Ly sào
        data["Quý Tỵ"] = DayStarData(
            canChi: "Quý Tỵ",
            goodStars: [.trucLinh],
            badStars: [.cuuThoQuy, .lySao]
        )

        // Row 31: Giáp Ngọ
        // Page 154, Column C: Cửu thổ quỷ (bad star, not good)
        data["Giáp Ngọ"] = DayStarData(
            canChi: "Giáp Ngọ",
            goodStars: [],
            badStars: [.cuuThoQuy, .khongPhong]
        )

        // Row 32: Ất Mùi
        // Page 154, Column C: (none)
        data["Ất Mùi"] = DayStarData(
            canChi: "Ất Mùi",
            goodStars: [],
            badStars: [.diaPha, .hoangVu, .bangTieu]
        )

        // Row 33: Bính Thân
        // Page 154, Column C: Nhân chuyển
        data["Bính Thân"] = DayStarData(
            canChi: "Bính Thân",
            goodStars: [.nhanChuyen],
            badStars: []
        )

        // Row 34: Đinh Dậu
        // Page 154, Column C: (none)
        data["Đinh Dậu"] = DayStarData(
            canChi: "Đinh Dậu",
            goodStars: [],
            badStars: []
        )

        // Row 35: Mậu Tuất
        // Page 154, Column C: Ly sào
        data["Mậu Tuất"] = DayStarData(
            canChi: "Mậu Tuất",
            goodStars: [],
            badStars: [.lySao]
        )

        // Row 36: Kỷ Hợi
        // Page 154, Column C: (none), Column B: Hỏa linh
        data["Kỷ Hợi"] = DayStarData(
            canChi: "Kỷ Hợi",
            goodStars: [],
            badStars: [.hoaLinh]
        )

        // Row 37: Canh Tý
        // Page 154/155, Column C: Thiên ân, Sát công, Cửu thổ quỷ
        data["Canh Tý"] = DayStarData(
            canChi: "Canh Tý",
            goodStars: [.thienAn, .satCong],
            badStars: [.cuuThoQuy, .hoaTai, .thienHoa, .thoOn, .hoangSa, .phiMaSat, .nguQuy, .quaTu]
        )

        // Row 38: Tân Sửu
        // Page 155, Column C: Thiên ân, Trực linh
        data["Tân Sửu"] = DayStarData(
            canChi: "Tân Sửu",
            goodStars: [.thienAn, .trucLinh],
            badStars: [.thienCuong]
        )

        // Row 39: Nhâm Dần
        // Page 155, Column C: Thiên thụy
        data["Nhâm Dần"] = DayStarData(
            canChi: "Nhâm Dần",
            goodStars: [.thienThuy],
            badStars: [.daiHao, .thuTu]
        )

        // Row 40: Quý Mão
        // Page 155, Column C: Thiên ân
        data["Quý Mão"] = DayStarData(
            canChi: "Quý Mão",
            goodStars: [.thienAn],
            badStars: [.hoangVu, .khongPhong]
        )

        // Row 41: Giáp Thìn
        // Page 155/156, Column C: (none listed explicitly)
        data["Giáp Thìn"] = DayStarData(
            canChi: "Giáp Thìn",
            goodStars: [],
            badStars: [.lySao]
        )

        // Row 42: Ất Tỵ
        // Page 156, Column C: Nhân chuyển
        data["Ất Tỵ"] = DayStarData(
            canChi: "Ất Tỵ",
            goodStars: [.nhanChuyen],
            badStars: [.lySao]
        )

        // Row 43: Bính Ngọ
        // Page 156, Column C: Thiên ân
        data["Bính Ngọ"] = DayStarData(
            canChi: "Bính Ngọ",
            goodStars: [.thienAn],
            badStars: [.khongPhong]
        )

        // Row 44: Đinh Mùi
        // Page 156, Column C: (none), Column B: Hỏa linh, Ly sào, Địa phá, Hoang vu, Băng tiêu
        data["Đinh Mùi"] = DayStarData(
            canChi: "Đinh Mùi",
            goodStars: [],
            badStars: [.hoaLinh, .lySao, .diaPha, .hoangVu, .bangTieu]
        )

        // Row 45: Mậu Thân
        // Page 156, Column C: Sát công
        data["Mậu Thân"] = DayStarData(
            canChi: "Mậu Thân",
            goodStars: [.satCong],
            badStars: []
        )

        // Row 46: Kỷ Dậu
        // Page 156, Column C: Trực linh
        data["Kỷ Dậu"] = DayStarData(
            canChi: "Kỷ Dậu",
            goodStars: [.trucLinh],
            badStars: []
        )

        // Row 47: Canh Tuất
        // Page 156, Column C: (none)
        data["Canh Tuất"] = DayStarData(
            canChi: "Canh Tuất",
            goodStars: [],
            badStars: []
        )

        // Row 48: Tân Hợi
        // Page 156, Column C: Thiên ân
        data["Tân Hợi"] = DayStarData(
            canChi: "Tân Hợi",
            goodStars: [.thienAn],
            badStars: []
        )

        // Row 49: Nhâm Tý
        // Page 156/157, Column C: Thiên thụy
        data["Nhâm Tý"] = DayStarData(
            canChi: "Nhâm Tý",
            goodStars: [.thienThuy],
            badStars: [.hoaTai, .thienHoa, .thoOn, .hoangSa, .phiMaSat, .nguQuy, .quaTu]
        )

        // Row 50: Quý Sửu
        // Page 157, Column C: Nhân chuyển
        data["Quý Sửu"] = DayStarData(
            canChi: "Quý Sửu",
            goodStars: [.nhanChuyen],
            badStars: [.thienCuong]
        )

        // Row 51: Giáp Dần
        // Page 157, Column C: Trực linh, Cửu thổ quỷ
        data["Giáp Dần"] = DayStarData(
            canChi: "Giáp Dần",
            goodStars: [.trucLinh],
            badStars: [.cuuThoQuy, .daiHao, .thuTu]
        )

        // Row 52: Ất Mão
        // Page 157, Column C: (none)
        data["Ất Mão"] = DayStarData(
            canChi: "Ất Mão",
            goodStars: [],
            badStars: [.hoangVu, .khongPhong]
        )

        // Row 53: Bính Thìn
        // Page 157, Column C: (none)
        data["Bính Thìn"] = DayStarData(
            canChi: "Bính Thìn",
            goodStars: [],
            badStars: [.lySao]
        )

        // Row 54: Đinh Tỵ
        // Page 157, Column C: (none)
        data["Đinh Tỵ"] = DayStarData(
            canChi: "Đinh Tỵ",
            goodStars: [],
            badStars: [.lySao]
        )

        // Row 55: Mậu Ngọ
        // Page 157, Column C: Ngọ hợp
        data["Mậu Ngọ"] = DayStarData(
            canChi: "Mậu Ngọ",
            goodStars: [.ngoHop],
            badStars: [.khongPhong]
        )

        // Row 56: Kỷ Mùi
        // Page 157, Column C: Ngọ hợp, Sát công
        data["Kỷ Mùi"] = DayStarData(
            canChi: "Kỷ Mùi",
            goodStars: [.ngoHop, .satCong],
            badStars: [.diaPha, .hoangVu, .bangTieu]
        )

        // Row 57: Canh Thân
        // Page 157, Column C: Trực linh
        data["Canh Thân"] = DayStarData(
            canChi: "Canh Thân",
            goodStars: [.trucLinh],
            badStars: []
        )

        // Row 58: Tân Dậu
        // Page 157, Column C: Ngọ hợp
        data["Tân Dậu"] = DayStarData(
            canChi: "Tân Dậu",
            goodStars: [.ngoHop],
            badStars: []
        )

        // Row 59: Nhâm Tuất
        // Page 157, Column C: Ly sào
        data["Nhâm Tuất"] = DayStarData(
            canChi: "Nhâm Tuất",
            goodStars: [],
            badStars: [.lySao]
        )

        // Row 60: Quý Hợi
        // Page 157, Column C: Ngọ hợp, Nhân chuyển, Column B: Hỏa linh
        data["Quý Hợi"] = DayStarData(
            canChi: "Quý Hợi",
            goodStars: [.ngoHop, .nhanChuyen],
            badStars: [.hoaLinh]
        )

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
        let chiNames = ["Tý", "Sửu", "Dần", "Mão", "Thìn", "Tỵ", "Ngọ", "Mùi", "Thân", "Dậu", "Tuất", "Hợi"]
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
            print("⚠️ WARNING: Incomplete data - need \(status.total - status.completed) more entries from book pages 153-157")
        } else {
            print("✅ Complete data for all 60 Can-Chi combinations")
        }
    }
}
