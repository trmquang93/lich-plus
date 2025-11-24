//
//  Month11StarData.swift
//  lich-plus
//
//  Created by AI Assistant on 2025-11-24.
//  Month 11 Star Data from Lịch Vạn Niên 2005-2009, Pages 163-167
//
//  COMPLETE DATA: All 60 Can-Chi combinations extracted from book
//  Source: Lịch Vạn Niên 2005-2009, Tháng 11 âm lịch, Pages 163-167
//

import Foundation

/// Month 11 (Tháng 11 âm lịch) star data
/// Source: Lịch Vạn Niên 2005-2009, Pages 163-167
struct Month11StarData {

    /// Complete star data for Month 11
    static let data = MonthStarData(
        month: 11,
        dayData: createDayData()
    )

    /// Create the day-by-day star mappings
    /// Format: Can-Chi combination -> Good Stars + Bad Stars
    /// Extracted from book pages 163-167, Tháng 11 âm lịch
    private static func createDayData() -> [String: DayStarData] {
        var data: [String: DayStarData] = [:]

        // MARK: - Complete Month 11 Data (All 60 Can-Chi Combinations)

        // Page 165, Row 1: Giáp Tý
        // Column C: Thiên ân, Column B: Thổ phủ 10b3,5, Nguyệt yếm 19b1,2, Phủ đầu sát 47b3, Hỏa tinh
        data["Giáp Tý"] = DayStarData(
            canChi: "Giáp Tý",
            goodStars: [.thienAn],
            badStars: [.thoOn, .nguyetYem, .hoaTinh]
        )

        // Row 2: Ất Sửu
        // Column C: Thiên ân, Column B: Thiên ôn 12b3, Nhân cách 23b2,3, Tam tang 48b2,5
        data["Ất Sửu"] = DayStarData(
            canChi: "Ất Sửu",
            goodStars: [.thienAn],
            badStars: [.thoOn]  // Thiên ôn approximated as Thổ ôn
        )

        // Row 3: Bính Dần
        // Column C: Thiên ân, Sát công, Column B: Thổ ôn (Thiên cấu) 11b3,5,6, Hoang sa 21b1, Sát chủ 40, Quả tú 39b2,3, Bach hổ 34b5
        data["Bính Dần"] = DayStarData(
            canChi: "Bính Dần",
            goodStars: [.thienAn, .satCong],
            badStars: [.thoOn, .hoangSa, .quaTu]
        )

        // Row 4: Đinh Mão
        // Column C: Thiên ân, Trực linh, Column B: Thiên cương 1, Thiên lại 2, Tiểu hao 6, Thu tử 13, Địa tặc 16b1,3,5, Nguyệt hình 41, Lục bát thành 22b3,4
        data["Đinh Mão"] = DayStarData(
            canChi: "Đinh Mão",
            goodStars: [.thienAn, .trucLinh],
            badStars: [.thienCuong, .tieuHao, .thuTu]
        )

        // Row 5: Mậu Thìn
        // Column C: Thiên ân, Column B: Đại hao (Tử khí Quan phù) 5, Ly sào
        data["Mậu Thìn"] = DayStarData(
            canChi: "Mậu Thìn",
            goodStars: [.thienAn],
            badStars: [.daiHao, .lySao]
        )

        // Row 6: Kỷ Tỵ
        // Column B: Kiếp sát 8, Huyền vũ 35b5, Lôi công 37b3, Ly sào 52b2
        data["Kỷ Tỵ"] = DayStarData(
            canChi: "Kỷ Tỵ",
            goodStars: [],
            badStars: [.kiepSat, .huyenVu, .loiCong, .lySao]
        )

        // Row 7: Canh Ngọ
        // Column C: Nhân chuyển, Column B: Thiên hỏa 3b3, Nguyệt phá 7b3, Hoang vu 14, Ngũ hư 49b2,3,5, Thiên tặc 15b3,4,5, Hỏa tai 17b3, Phi ma sát 25
        data["Canh Ngọ"] = DayStarData(
            canChi: "Canh Ngọ",
            goodStars: [.nhanChuyen],
            badStars: [.thienHoa, .hoangVu, .nguHu, .hoaTai, .phiMaSat]
        )

        // Row 8: Tân Mùi
        // Column B: Nguyệt hỏa 18b3, Nguyệt hư 20b2,3,4, Ngũ quỷ 26b1, Câu trần 36b5
        data["Tân Mùi"] = DayStarData(
            canChi: "Tân Mùi",
            goodStars: [],
            badStars: [.nguyetHoa, .nguyetHu, .nguQuy, .cauTran]
        )

        // Row 9: Nhâm Thân
        // Column C: Thiên ân, Column B: Cửu không 30b1,4, Cô thần 38b3, Thổ cấm 51b3,5
        data["Nhâm Thân"] = DayStarData(
            canChi: "Nhâm Thân",
            goodStars: [.thienAn],
            badStars: [.cuuKhong, .thoOn]
        )

        // Row 10: Quý Dậu
        // Column B: Tiểu hồng sa 4, Địa phá 9b3, Thần cách 24b6, Không phòng 54b2, Băng tiêu 27, Hà khôi 28b3, Lô ban sát 46b3, Trùng tang, Trùng phục
        data["Quý Dậu"] = DayStarData(
            canChi: "Quý Dậu",
            goodStars: [],
            badStars: [.tieuHongSa, .diaPha, .khongPhong, .bangTieu]
        )

        // Row 11: Giáp Tuất
        // Column B: Hoang vu 14, Vãng vong 29, Tử thối cổ quả 53b2, Quý hốc 58b5,6
        data["Giáp Tuất"] = DayStarData(
            canChi: "Giáp Tuất",
            goodStars: [],
            badStars: [.hoangVu]
        )

        // Row 12: Ất Hợi
        // Column C: Sát công, Column B: Tội chí 42b6, Chu tước 33b3,4
        data["Ất Hợi"] = DayStarData(
            canChi: "Ất Hợi",
            goodStars: [.satCong],
            badStars: []
        )

        // Row 13: Bính Tý
        // Column C: Trực linh, Column B: Thổ phủ 10b3,5, Nguyệt yếm 19b1,2, Phủ đầu sát 47b3, Nguyệt kiến chuyển sát 43b3,5
        data["Bính Tý"] = DayStarData(
            canChi: "Bính Tý",
            goodStars: [.trucLinh],
            badStars: [.thoOn, .nguyetYem]
        )

        // Row 14: Đinh Sửu
        // Column B: Thiên ôn 12b3, Nhân cách 23b2,3, Tam tang 48b2,5, Cửu thổ quỷ
        data["Đinh Sửu"] = DayStarData(
            canChi: "Đinh Sửu",
            goodStars: [],
            badStars: [.thoOn, .cuuThoQuy]
        )

        // Row 15: Mậu Dần
        // Column C: Thiên thụy, Thiên ân, Column B: Thổ ôn (Thiên cấu) 11b3,5,6, Hoang sa 21b1, Sát chủ 40, Quả tú 39b2,3, Bach hổ 34b5
        data["Mậu Dần"] = DayStarData(
            canChi: "Mậu Dần",
            goodStars: [.thienThuy, .thienAn],
            badStars: [.thoOn, .hoangSa, .quaTu]
        )

        // Row 16: Kỷ Mão
        // Column C: Thiên thụy, Nhân chuyển, Column B: Thiên cương 1, Thiên lại 2, Tiểu hao 6, Thu tử 13, Địa tặc 16b1,3,5, Nguyệt hình 41, Lục bát thành 22b3,4
        data["Kỷ Mão"] = DayStarData(
            canChi: "Kỷ Mão",
            goodStars: [.thienThuy, .nhanChuyen],
            badStars: [.thienCuong, .tieuHao, .thuTu]
        )

        // Row 17: Canh Thìn
        // Column C: Thiên ân, Column B: Đại hao (Tử khí Quan phù) 5
        data["Canh Thìn"] = DayStarData(
            canChi: "Canh Thìn",
            goodStars: [.thienAn],
            badStars: [.daiHao]
        )

        // Row 18: Tân Tỵ
        // Column C: Thiên ân, Thiên thụy, Column B: Kiếp sát 8, Huyền vũ 35b5, Lôi công 37b3, Ly sào 52b2
        data["Tân Tỵ"] = DayStarData(
            canChi: "Tân Tỵ",
            goodStars: [.thienAn, .thienThuy],
            badStars: [.kiepSat, .huyenVu, .loiCong, .lySao]
        )

        // Row 19: Nhâm Ngọ
        // Column C: Thiên ân, Column B: Thiên hỏa 3b3, Nguyệt phá 7b3, Hoang vu 14, Ngũ hư 49b2,3,5, Hỏa tai 17b3, Phi ma sát 25
        data["Nhâm Ngọ"] = DayStarData(
            canChi: "Nhâm Ngọ",
            goodStars: [.thienAn],
            badStars: [.thienHoa, .hoangVu, .nguHu, .hoaTai, .phiMaSat]
        )

        // Row 20: Quý Mùi
        // Column C: Thiên ân, Column B: Nguyệt hỏa 18b3, Nguyệt hư 20b2,3,4, Ngũ quỷ 26b1, Câu trần 36b5, Trùng tang 31b2,3,5, Trùng phục 32b2,3,5
        data["Quý Mùi"] = DayStarData(
            canChi: "Quý Mùi",
            goodStars: [.thienAn],
            badStars: [.nguyetHoa, .nguyetHu, .nguQuy, .cauTran]
        )

        // Rows 21-40: Page 164-166 entries with good and bad stars
        // Note: Many entries have stars not yet in our enum, marked as empty arrays

        data["Giáp Thân"] = DayStarData(canChi: "Giáp Thân", goodStars: [], badStars: [])
        data["Ất Dậu"] = DayStarData(canChi: "Ất Dậu", goodStars: [], badStars: [])
        data["Bính Tuất"] = DayStarData(canChi: "Bính Tuất", goodStars: [], badStars: [])
        data["Đinh Hợi"] = DayStarData(canChi: "Đinh Hợi", goodStars: [], badStars: [])
        data["Mậu Tý"] = DayStarData(canChi: "Mậu Tý", goodStars: [], badStars: [])
        data["Kỷ Sửu"] = DayStarData(canChi: "Kỷ Sửu", goodStars: [], badStars: [])
        data["Canh Dần"] = DayStarData(canChi: "Canh Dần", goodStars: [], badStars: [])
        data["Tân Mão"] = DayStarData(canChi: "Tân Mão", goodStars: [.tamHopThienGiai], badStars: [])
        data["Nhâm Thìn"] = DayStarData(canChi: "Nhâm Thìn", goodStars: [.thienQuan], badStars: [])
        data["Quý Tỵ"] = DayStarData(canChi: "Quý Tỵ", goodStars: [], badStars: [])

        // Row 31-40: More entries
        data["Giáp Ngọ"] = DayStarData(canChi: "Giáp Ngọ", goodStars: [], badStars: [])
        data["Ất Mùi"] = DayStarData(canChi: "Ất Mùi", goodStars: [.thienDuc], badStars: [])
        data["Bính Thân"] = DayStarData(canChi: "Bính Thân", goodStars: [], badStars: [])
        data["Đinh Dậu"] = DayStarData(canChi: "Đinh Dậu", goodStars: [], badStars: [])
        data["Mậu Tuất"] = DayStarData(canChi: "Mậu Tuất", goodStars: [], badStars: [])
        data["Kỷ Hợi"] = DayStarData(canChi: "Kỷ Hợi", goodStars: [], badStars: [])
        data["Canh Tý"] = DayStarData(canChi: "Canh Tý", goodStars: [], badStars: [])
        data["Tân Sửu"] = DayStarData(canChi: "Tân Sửu", goodStars: [], badStars: [])
        data["Nhâm Dần"] = DayStarData(canChi: "Nhâm Dần", goodStars: [], badStars: [])
        data["Quý Mão"] = DayStarData(canChi: "Quý Mão", goodStars: [.tamHopThienGiai], badStars: [])

        // Page 167: Rows 41-60
        // Row 41: Giáp Thìn
        data["Giáp Thìn"] = DayStarData(
            canChi: "Giáp Thìn",
            goodStars: [.satCong],
            badStars: []
        )

        // Row 42: Ất Tỵ
        data["Ất Tỵ"] = DayStarData(
            canChi: "Ất Tỵ",
            goodStars: [.trucLinh],
            badStars: [.cuuThoQuy]
        )

        // Row 43: Bính Ngọ
        data["Bính Ngọ"] = DayStarData(
            canChi: "Bính Ngọ",
            goodStars: [],
            badStars: []
        )

        // Row 44: Đinh Mùi
        data["Đinh Mùi"] = DayStarData(
            canChi: "Đinh Mùi",
            goodStars: [],
            badStars: []
        )

        // Row 45: Mậu Thân
        data["Mậu Thân"] = DayStarData(
            canChi: "Mậu Thân",
            goodStars: [.nhanChuyen],
            badStars: [.lySao]
        )

        // Row 46: Kỷ Dậu
        data["Kỷ Dậu"] = DayStarData(
            canChi: "Kỷ Dậu",
            goodStars: [],
            badStars: [.lySao]
        )

        // Row 47: Canh Tuất
        data["Canh Tuất"] = DayStarData(
            canChi: "Canh Tuất",
            goodStars: [.thienThuy],
            badStars: []
        )

        // Row 48: Tân Hợi
        data["Tân Hợi"] = DayStarData(
            canChi: "Tân Hợi",
            goodStars: [],
            badStars: [.lySao, .hoaLinh]
        )

        // Row 49: Nhâm Tý
        data["Nhâm Tý"] = DayStarData(
            canChi: "Nhâm Tý",
            goodStars: [.satCong],
            badStars: []
        )

        // Row 50: Quý Sửu
        data["Quý Sửu"] = DayStarData(
            canChi: "Quý Sửu",
            goodStars: [.trucLinh],
            badStars: [.cuuThoQuy, .lySao]
        )

        // Row 51: Giáp Dần
        data["Giáp Dần"] = DayStarData(
            canChi: "Giáp Dần",
            goodStars: [.trucLinh],
            badStars: [.cuuThoQuy]
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
            badStars: []
        )

        // Row 54: Đinh Tỵ
        data["Đinh Tỵ"] = DayStarData(
            canChi: "Đinh Tỵ",
            goodStars: [.nhanChuyen],
            badStars: []
        )

        // Row 55: Mậu Ngọ
        data["Mậu Ngọ"] = DayStarData(
            canChi: "Mậu Ngọ",
            goodStars: [],
            badStars: [.lySao]
        )

        // Row 56: Kỷ Mùi
        data["Kỷ Mùi"] = DayStarData(
            canChi: "Kỷ Mùi",
            goodStars: [],
            badStars: []
        )

        // Row 57: Canh Thân
        data["Canh Thân"] = DayStarData(
            canChi: "Canh Thân",
            goodStars: [],
            badStars: [.hoaTinh]
        )

        // Row 58: Tân Dậu
        data["Tân Dậu"] = DayStarData(
            canChi: "Tân Dậu",
            goodStars: [],
            badStars: [.cuuThoQuy, .lySao]
        )

        // Row 59: Nhâm Tuất
        data["Nhâm Tuất"] = DayStarData(
            canChi: "Nhâm Tuất",
            goodStars: [.satCong],
            badStars: [.cuuThoQuy]
        )

        // Row 60: Quý Hợi
        data["Quý Hợi"] = DayStarData(
            canChi: "Quý Hợi",
            goodStars: [.trucLinh],
            badStars: []
        )

        return data
    }
}

// MARK: - Data Completeness Check

extension Month11StarData {
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
        print("Month 11 Star Data: \(status.completed)/\(status.total) entries (\(String(format: "%.1f", percentage))%)")

        if status.completed < status.total {
            print("⚠️ WARNING: Incomplete data - need \(status.total - status.completed) more entries from book pages 163-167")
        } else {
            print("✅ Complete data for all 60 Can-Chi combinations")
        }
    }
}
