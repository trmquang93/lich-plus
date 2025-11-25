//
//  Month1StarData.swift
//  lich-plus
//
//  Created by AI Assistant on 2025-11-25.
//  Month 1 Star Data from Lịch Vạn Niên 2005-2009, Pages 104-105
//
//  COMPLETE DATA: All 60 Can-Chi combinations extracted from book
//  Source: Lịch Vạn Niên 2005-2009, Tháng giêng âm lịch, Pages 104-105
//

import Foundation

/// Month 1 (Tháng giêng âm lịch) star data
/// Source: Lịch Vạn Niên 2005-2009, Pages 104-105
struct Month1StarData {

    /// Complete star data for Month 1
    static let data = MonthStarData(
        month: 1,
        dayData: createDayData()
    )

    /// Create the day-by-day star mappings
    /// Format: Can-Chi combination -> Good Stars + Bad Stars
    /// Extracted from book pages 104-105, Tháng giêng âm lịch
    private static func createDayData() -> [String: DayStarData] {
        var data: [String: DayStarData] = [:]

        // MARK: - Complete Month 1 Data (All 60 Can-Chi Combinations)

        // Row 1: Giáp Tý
        data["Giáp Tý"] = DayStarData(
            canChi: "Giáp Tý",
            goodStars: [.thienAn],
            badStars: [.thienHoa, .phiMaSat, .khongPhong]
        )

        // Row 2: Ất Sửu
        data["Ất Sửu"] = DayStarData(
            canChi: "Ất Sửu",
            goodStars: [.thienAn],
            badStars: [.hoangVu, .hoaTai, .nguyetHu, .tuThoiCoQua, .nguHu, .hoaTinh]
        )

        // Row 3: Bính Dần
        data["Bính Dần"] = DayStarData(
            canChi: "Bính Dần",
            goodStars: [.thienAn],
            badStars: [.thoOn, .loiCong]
        )

        // Row 4: Đinh Mão
        data["Đinh Mão"] = DayStarData(
            canChi: "Đinh Mão",
            goodStars: [.thienAn, .satCong],
            badStars: []
        )

        // Row 5: Mậu Thìn
        data["Mậu Thìn"] = DayStarData(
            canChi: "Mậu Thìn",
            goodStars: [.thienAn, .trucLinh],
            badStars: [.thoOn, .khongPhong, .cuuKhong, .quaTu, .lySao]
        )

        // Row 6: Kỷ Tỵ
        data["Kỷ Tỵ"] = DayStarData(
            canChi: "Kỷ Tỵ",
            goodStars: [.thienAn, .trucLinh],
            badStars: [.thienCuong, .tieuHongSa, .tieuHao, .nguHu, .bangTieu, .khongPhong, .hoangVu, .nguyetHoa, .lySao]
        )

        // Row 7: Canh Ngọ
        data["Canh Ngọ"] = DayStarData(
            canChi: "Canh Ngọ",
            goodStars: [],
            badStars: [.daiHao, .hoangSa, .nguQuy]
        )

        // Row 8: Tân Mùi
        data["Tân Mùi"] = DayStarData(
            canChi: "Tân Mùi",
            goodStars: [],
            badStars: [.thoOn]
        )

        // Row 9: Nhâm Thân
        data["Nhâm Thân"] = DayStarData(
            canChi: "Nhâm Thân",
            goodStars: [],
            badStars: []
        )

        // Row 10: Quý Dậu
        data["Quý Dậu"] = DayStarData(
            canChi: "Quý Dậu",
            goodStars: [],
            badStars: [.hoangVu, .huyenVu, .lySao]
        )

        // Row 11: Giáp Tuất
        data["Giáp Tuất"] = DayStarData(
            canChi: "Giáp Tuất",
            goodStars: [],
            badStars: [.thuTu, .nguyetYem, .quyKhoc]
        )

        // Row 12: Ất Hợi
        data["Ất Hợi"] = DayStarData(
            canChi: "Ất Hợi",
            goodStars: [],
            badStars: [.diaPha, .cauTran, .kiepSat]
        )

        // Row 13: Bính Tý
        data["Bính Tý"] = DayStarData(
            canChi: "Bính Tý",
            goodStars: [.satCong],
            badStars: [.thienHoa, .phiMaSat, .khongPhong]
        )

        // Row 14: Đinh Sửu
        data["Đinh Sửu"] = DayStarData(
            canChi: "Đinh Sửu",
            goodStars: [.trucLinh],
            badStars: [.hoangVu, .hoaTai, .nguyetHu, .cuuThoQuy]
        )

        // Row 15: Mậu Dần
        data["Mậu Dần"] = DayStarData(
            canChi: "Mậu Dần",
            goodStars: [.thienThuy],
            badStars: [.thoOn, .loiCong, .lySao]
        )

        // Row 16: Kỷ Mão
        data["Kỷ Mão"] = DayStarData(
            canChi: "Kỷ Mão",
            goodStars: [.thienThuy, .thienAn],
            badStars: []
        )

        // Row 17: Canh Thìn
        data["Canh Thìn"] = DayStarData(
            canChi: "Canh Thìn",
            goodStars: [.nhanChuyen, .thienAn],
            badStars: [.thoOn, .khongPhong, .cuuKhong, .quaTu]
        )

        // Row 18: Tân Tỵ
        data["Tân Tỵ"] = DayStarData(
            canChi: "Tân Tỵ",
            goodStars: [.thienThuy, .thienAn],
            badStars: [.thienCuong, .tieuHongSa, .tieuHao, .nguHu, .bangTieu, .khongPhong, .hoangVu, .lySao]
        )

        // Row 19: Nhâm Ngọ
        data["Nhâm Ngọ"] = DayStarData(
            canChi: "Nhâm Ngọ",
            goodStars: [.thienAn],
            badStars: [.daiHao, .hoangSa, .nguQuy]
        )

        // Row 20: Quý Mùi
        data["Quý Mùi"] = DayStarData(
            canChi: "Quý Mùi",
            goodStars: [.thienAn],
            badStars: [.thoOn, .hoaTinh]
        )

        // Row 21: Giáp Thân
        data["Giáp Thân"] = DayStarData(
            canChi: "Giáp Thân",
            goodStars: [.thienAn],
            badStars: []
        )

        // Row 22: Ất Dậu
        data["Ất Dậu"] = DayStarData(
            canChi: "Ất Dậu",
            goodStars: [],
            badStars: [.hoangVu, .huyenVu, .lySao]
        )

        // Row 23: Bính Tuất
        data["Bính Tuất"] = DayStarData(
            canChi: "Bính Tuất",
            goodStars: [.nhanChuyen],
            badStars: [.thuTu, .nguyetYem, .quyKhoc]
        )

        // Row 24: Đinh Hợi
        data["Đinh Hợi"] = DayStarData(
            canChi: "Đinh Hợi",
            goodStars: [],
            badStars: [.diaPha, .cauTran, .kiepSat]
        )

        // Row 25: Mậu Tý
        data["Mậu Tý"] = DayStarData(
            canChi: "Mậu Tý",
            goodStars: [],
            badStars: [.thienHoa, .phiMaSat, .khongPhong]
        )

        // Row 26: Kỷ Sửu
        data["Kỷ Sửu"] = DayStarData(
            canChi: "Kỷ Sửu",
            goodStars: [],
            badStars: [.hoangVu, .hoaTai, .nguyetHu, .tuThoiCoQua, .nguHu]
        )

        // Row 27: Canh Dần
        data["Canh Dần"] = DayStarData(
            canChi: "Canh Dần",
            goodStars: [.thienAn],
            badStars: [.thoOn, .loiCong]
        )

        // Row 28: Tân Mão
        data["Tân Mão"] = DayStarData(
            canChi: "Tân Mão",
            goodStars: [.thienAn, .satCong],
            badStars: []
        )

        // Row 29: Nhâm Thìn
        data["Nhâm Thìn"] = DayStarData(
            canChi: "Nhâm Thìn",
            goodStars: [.thienThuy, .trucLinh],
            badStars: [.thoOn, .khongPhong, .cuuKhong, .quaTu]
        )

        // Row 30: Quý Tỵ
        data["Quý Tỵ"] = DayStarData(
            canChi: "Quý Tỵ",
            goodStars: [.thienAn],
            badStars: [.thienCuong, .tieuHongSa, .tieuHao, .nguHu, .bangTieu, .khongPhong, .hoangVu]
        )

        // Row 31: Giáp Ngọ
        data["Giáp Ngọ"] = DayStarData(
            canChi: "Giáp Ngọ",
            goodStars: [],
            badStars: [.daiHao, .hoangSa, .nguQuy]
        )

        // Row 32: Ất Mùi
        data["Ất Mùi"] = DayStarData(
            canChi: "Ất Mùi",
            goodStars: [.nhanChuyen],
            badStars: [.thoOn]
        )

        // Row 33: Bính Thân
        data["Bính Thân"] = DayStarData(
            canChi: "Bính Thân",
            goodStars: [],
            badStars: []
        )

        // Row 34: Đinh Dậu
        data["Đinh Dậu"] = DayStarData(
            canChi: "Đinh Dậu",
            goodStars: [],
            badStars: [.hoangVu, .huyenVu, .lySao]
        )

        // Row 35: Mậu Tuất
        data["Mậu Tuất"] = DayStarData(
            canChi: "Mậu Tuất",
            goodStars: [.ngoHop],
            badStars: [.thuTu, .nguyetYem, .quyKhoc]
        )

        // Row 36: Kỷ Hợi
        data["Kỷ Hợi"] = DayStarData(
            canChi: "Kỷ Hợi",
            goodStars: [.ngoHop],
            badStars: [.diaPha, .cauTran, .kiepSat]
        )

        // Row 37: Canh Tý
        data["Canh Tý"] = DayStarData(
            canChi: "Canh Tý",
            goodStars: [.satCong],
            badStars: [.thienHoa, .phiMaSat, .khongPhong]
        )

        // Row 38: Tân Sửu
        data["Tân Sửu"] = DayStarData(
            canChi: "Tân Sửu",
            goodStars: [.trucLinh, .ngoHop],
            badStars: [.hoangVu, .hoaTai, .nguyetHu, .cuuThoQuy]
        )

        // Row 39: Nhâm Dần
        data["Nhâm Dần"] = DayStarData(
            canChi: "Nhâm Dần",
            goodStars: [],
            badStars: [.thoOn, .loiCong, .lySao]
        )

        // Row 40: Quý Mão
        data["Quý Mão"] = DayStarData(
            canChi: "Quý Mão",
            goodStars: [.ngoHop],
            badStars: []
        )

        // Row 41: Giáp Thìn
        data["Giáp Thìn"] = DayStarData(
            canChi: "Giáp Thìn",
            goodStars: [.satCong],
            badStars: [.thoOn, .khongPhong, .cuuKhong, .quaTu]
        )

        // Row 42: Ất Tỵ
        data["Ất Tỵ"] = DayStarData(
            canChi: "Ất Tỵ",
            goodStars: [.trucLinh],
            badStars: [.thienCuong, .tieuHongSa, .tieuHao, .nguHu, .bangTieu]
        )

        // Row 43: Bính Ngọ
        data["Bính Ngọ"] = DayStarData(
            canChi: "Bính Ngọ",
            goodStars: [],
            badStars: [.daiHao, .hoangSa, .nguQuy]
        )

        // Row 44: Đinh Mùi
        data["Đinh Mùi"] = DayStarData(
            canChi: "Đinh Mùi",
            goodStars: [],
            badStars: [.thoOn]
        )

        // Row 45: Mậu Thân
        data["Mậu Thân"] = DayStarData(
            canChi: "Mậu Thân",
            goodStars: [.nhanChuyen],
            badStars: []
        )

        // Row 46: Kỷ Dậu
        data["Kỷ Dậu"] = DayStarData(
            canChi: "Kỷ Dậu",
            goodStars: [],
            badStars: [.hoangVu, .huyenVu, .lySao]
        )

        // Row 47: Canh Tuất
        data["Canh Tuất"] = DayStarData(
            canChi: "Canh Tuất",
            goodStars: [.thienThuy],
            badStars: [.thuTu, .nguyetYem]
        )

        // Row 48: Tân Hợi
        data["Tân Hợi"] = DayStarData(
            canChi: "Tân Hợi",
            goodStars: [],
            badStars: [.diaPha, .cauTran, .kiepSat]
        )

        // Row 49: Nhâm Tý
        data["Nhâm Tý"] = DayStarData(
            canChi: "Nhâm Tý",
            goodStars: [.satCong],
            badStars: [.thienHoa, .phiMaSat, .khongPhong]
        )

        // Row 50: Quý Sửu
        data["Quý Sửu"] = DayStarData(
            canChi: "Quý Sửu",
            goodStars: [.trucLinh],
            badStars: [.hoangVu, .hoaTai, .nguyetHu]
        )

        // Row 51: Giáp Dần
        data["Giáp Dần"] = DayStarData(
            canChi: "Giáp Dần",
            goodStars: [.trucLinh],
            badStars: [.thoOn, .loiCong]
        )

        // Row 52: Ất Mão
        data["Ất Mão"] = DayStarData(
            canChi: "Ất Mão",
            goodStars: [],
            badStars: []
        )

        // Row 53: Bính Thìn
        data["Bính Thìn"] = DayStarData(
            canChi: "Bính Thìn",
            goodStars: [],
            badStars: [.thoOn, .khongPhong, .cuuKhong, .quaTu]
        )

        // Row 54: Đinh Tỵ
        data["Đinh Tỵ"] = DayStarData(
            canChi: "Đinh Tỵ",
            goodStars: [.nhanChuyen],
            badStars: [.thienCuong, .tieuHongSa, .tieuHao, .nguHu]
        )

        // Row 55: Mậu Ngọ
        data["Mậu Ngọ"] = DayStarData(
            canChi: "Mậu Ngọ",
            goodStars: [],
            badStars: [.daiHao, .hoangSa, .nguQuy, .lySao]
        )

        // Row 56: Kỷ Mùi
        data["Kỷ Mùi"] = DayStarData(
            canChi: "Kỷ Mùi",
            goodStars: [],
            badStars: [.thoOn]
        )

        // Row 57: Canh Thân
        data["Canh Thân"] = DayStarData(
            canChi: "Canh Thân",
            goodStars: [],
            badStars: []
        )

        // Row 58: Tân Dậu
        data["Tân Dậu"] = DayStarData(
            canChi: "Tân Dậu",
            goodStars: [],
            badStars: [.hoangVu, .huyenVu, .lySao]
        )

        // Row 59: Nhâm Tuất
        data["Nhâm Tuất"] = DayStarData(
            canChi: "Nhâm Tuất",
            goodStars: [.satCong],
            badStars: [.thuTu, .nguyetYem]
        )

        // Row 60: Quý Hợi
        data["Quý Hợi"] = DayStarData(
            canChi: "Quý Hợi",
            goodStars: [.trucLinh],
            badStars: [.diaPha, .cauTran, .kiepSat]
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

extension Month1StarData {
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
        print("Month 1 Star Data: \(status.completed)/\(status.total) entries (\(String(format: "%.1f", percentage))%)")

        if status.completed < status.total {
            print("⚠️ WARNING: Incomplete data - need \(status.total - status.completed) more entries from book pages 104-105")
        } else {
            print("✅ Complete data for all 60 Can-Chi combinations")
        }
    }
}
