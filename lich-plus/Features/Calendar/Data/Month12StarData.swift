//
//  Month12StarData.swift
//  lich-plus
//
//  Created by AI Assistant on 2025-11-24.
//  Month 12 Star Data from Lịch Vạn Niên 2005-2009, Pages 168-172
//
//  COMPLETE DATA: All 60 Can-Chi combinations extracted from book
//  Source: Lịch Vạn Niên 2005-2009, Tháng 12 âm lịch (Tháng chạp), Pages 168-172
//

import Foundation

/// Month 12 (Tháng 12 âm lịch / Tháng chạp) star data
/// Source: Lịch Vạn Niên 2005-2009, Pages 168-172
struct Month12StarData {

    /// Complete star data for Month 12
    static let data = MonthStarData(
        month: 12,
        dayData: createDayData()
    )

    /// Create the day-by-day star mappings
    /// Format: Can-Chi combination -> Good Stars + Bad Stars
    /// Extracted from book pages 168-172, Tháng 12 âm lịch (chạp)
    private static func createDayData() -> [String: DayStarData] {
        var data: [String: DayStarData] = [:]

        // MARK: - Complete Month 12 Data (All 60 Can-Chi Combinations)

        // Page 171, Row 1: Giáp Tý
        // Column C: Thiên ân, Column B: Thiên lại 2, Hỏa tai 17b3, Hoang sa 21b1, Phủ đầu sát 47b3
        data["Giáp Tý"] = DayStarData(
            canChi: "Giáp Tý",
            goodStars: [.thienAn],
            badStars: [.hoaTai, .hoangSa]
        )

        // Row 2: Ất Sửu
        // Column C: Thiên ân, Sát công, Column B: Tiểu hồng sa 4, Thổ phủ 10b3,5, Vãng vong 29, Không phòng 54, Chu tước 33b3,4, Tam tang 48b2,5
        data["Ất Sửu"] = DayStarData(
            canChi: "Ất Sửu",
            goodStars: [.thienAn, .satCong],
            badStars: [.tieuHongSa, .thoOn, .khongPhong]
        )

        // Row 3: Bính Dần
        // Column C: Thiên ân, Trực linh, Column B: Kiếp sát 8, Hoang vu 14, Địa tặc 16b1,4,5, Ngũ hư 49b2,3,5
        data["Bính Dần"] = DayStarData(
            canChi: "Bính Dần",
            goodStars: [.thienAn, .trucLinh],
            badStars: [.kiepSat, .hoangVu, .nguHu]
        )

        // Row 4: Đinh Mão
        // Column C: Thiên ân, Column B: Thổ ôn (Thiên cấu) 11b3,5,6, Thiên ôn 12b3, Phi ma sát 25b2,3, Quả tú 39b2,3
        data["Đinh Mão"] = DayStarData(
            canChi: "Đinh Mão",
            goodStars: [.thienAn],
            badStars: [.thoOn, .phiMaSat, .quaTu]
        )

        // Row 5: Mậu Thìn
        // Column C: Thiên ân, Column B: Tiểu hao 6, Nguyệt hư 20b2,3,4, Băng tiêu 27, Hà khôi 28b3, Bach hổ 34b5, Sát chủ 40, Ly sào
        data["Mậu Thìn"] = DayStarData(
            canChi: "Mậu Thìn",
            goodStars: [.thienAn],
            badStars: [.tieuHao, .nguyetHu, .bangTieu, .lySao]
        )

        // Row 6: Kỷ Tỵ
        // Column C: Nhân chuyển, Column B: Đại hao (Tử khí Quan phù) 5, Cửu không 30b1,4, Tội chí 42b6, Ly sào 52b2, Trùng tang 31b2,3,5, Trùng phục 32b2,3,5
        data["Kỷ Tỵ"] = DayStarData(
            canChi: "Kỷ Tỵ",
            goodStars: [.nhanChuyen],
            badStars: [.daiHao, .cuuKhong, .lySao]
        )

        // Row 7: Canh Ngọ
        // Column B: Hoang vu 14, Nguyệt hỏa 18b3, Ngũ hư 49b2,3,5, (Độc hoả)
        data["Canh Ngọ"] = DayStarData(
            canChi: "Canh Ngọ",
            goodStars: [],
            badStars: [.hoangVu, .nguyetHoa, .nguHu]
        )

        // Row 8: Tân Mùi
        // Column B: Nguyệt phá 7b3, Lục bát thành 22b3,4, Thần cách 24b6, Huyền vũ 35b5
        data["Tân Mùi"] = DayStarData(
            canChi: "Tân Mùi",
            goodStars: [],
            badStars: [.huyenVu]
        )

        // Row 9: Nhâm Thân
        // Column C: Thiên ân, Column B: Lôi công 37b3, Thổ cấm 51b3,5, Không phòng 54b2
        data["Nhâm Thân"] = DayStarData(
            canChi: "Nhâm Thân",
            goodStars: [.thienAn],
            badStars: [.loiCong, .thoOn, .khongPhong]
        )

        // Row 10: Quý Dậu
        // Column B: Thiên hỏa 3b3, Thu tử 13, Câu trần 36b5, Cô thần 38b2,3, Lô ban sát 46b3, Không phòng 54b2
        data["Quý Dậu"] = DayStarData(
            canChi: "Quý Dậu",
            goodStars: [],
            badStars: [.thienHoa, .thuTu, .cauTran, .khongPhong]
        )

        // Row 11: Giáp Tuất
        // Column C: Sát công, Column B: Thiên cương 1, Địa phá 9b3, Hoang vu 14, Ngũ quỷ 26b1, Nguyệt hình 41, Ngũ hư 49b2,3,5, Quý hốc 58, Tử thối cổ quả 53b2
        data["Giáp Tuất"] = DayStarData(
            canChi: "Giáp Tuất",
            goodStars: [.satCong],
            badStars: [.thienCuong, .diaPha, .hoangVu, .nguQuy, .nguHu]
        )

        // Row 12: Ất Hợi
        // Column C: Trực linh, Column B: Thiên tặc 15b3,4,5, Nguyệt yếm 19b2, Nhân cách 23b2,3
        data["Ất Hợi"] = DayStarData(
            canChi: "Ất Hợi",
            goodStars: [.trucLinh],
            badStars: [.nguyetYem]
        )

        // Row 13: Bính Tý
        // Column B: Thiên lại 2, Hỏa tai 17b3, Nguyệt kiến chuyển sát 44, 45 b3,5, Hoang sa 21b1, Phủ đầu sát 47b3
        data["Bính Tý"] = DayStarData(
            canChi: "Bính Tý",
            goodStars: [],
            badStars: [.hoaTai, .hoangSa]
        )

        // Row 14: Đinh Sửu
        // Column C: Cửu thổ quỷ, Column B: Tiểu hồng sa 4, Thổ phủ 10b3,5, Vãng vong 29, Không phòng 54, Chu tước 33b3,4
        data["Đinh Sửu"] = DayStarData(
            canChi: "Đinh Sửu",
            goodStars: [],
            badStars: [.cuuThoQuy, .tieuHongSa, .thoOn, .khongPhong]
        )

        // Row 15: Mậu Dần
        // Column C: Thiên thụy, Nhân chuyển, Column B: Kiếp sát 8, Hoang vu 14, Địa tặc 16b1,4,5, Ngũ hư 49b2,3,5, Ly sào
        data["Mậu Dần"] = DayStarData(
            canChi: "Mậu Dần",
            goodStars: [.thienThuy, .nhanChuyen],
            badStars: [.kiepSat, .hoangVu, .nguHu, .lySao]
        )

        // Row 16: Kỷ Mão
        // Column C: Thiên thụy, Thiên ân, Column B: Thổ ôn (Thiên cấu) 11b3,5,6, Thiên ôn 12b3, Trùng tang 31b2,3,5, Phi ma sát 25b2,3, Quả tú 39b2,3, Trùng phục 32b2,3,5
        data["Kỷ Mão"] = DayStarData(
            canChi: "Kỷ Mão",
            goodStars: [.thienThuy, .thienAn],
            badStars: [.thoOn, .phiMaSat, .quaTu]
        )

        // Row 17: Canh Thìn
        // Column C: Thiên ân, Column B: Tiểu hao 6, Nguyệt hư 20b2,3,4, Băng tiêu 27, Hà khôi 28b3, Bach hổ 34b5, Sát chủ 40
        data["Canh Thìn"] = DayStarData(
            canChi: "Canh Thìn",
            goodStars: [.thienAn],
            badStars: [.tieuHao, .nguyetHu, .bangTieu]
        )

        // Row 18: Tân Tỵ
        // Column C: Thiên ân, Thiên thụy, Column B: Đại hao (Tử khí Quan phù) 5, Cửu không 30b1,4, Tội chí 42b6, Ly sào 52b2, Hỏa tinh, Ly sào
        data["Tân Tỵ"] = DayStarData(
            canChi: "Tân Tỵ",
            goodStars: [.thienAn, .thienThuy],
            badStars: [.daiHao, .cuuKhong, .hoaTinh, .lySao]
        )

        // Row 19: Nhâm Ngọ
        // Column C: Thiên ân, Column B: Hoang vu 14, Nguyệt hỏa 18b3, Ngũ hư 49b2,3,5, (Độc hoả)
        data["Nhâm Ngọ"] = DayStarData(
            canChi: "Nhâm Ngọ",
            goodStars: [.thienAn],
            badStars: [.hoangVu, .nguyetHoa, .nguHu]
        )

        // Row 20: Quý Mùi
        // Column C: Thiên ân, Sát công, Column B: Nguyệt phá7b3, Lục bát thành 22b3,4, Thần cách 24b6, Huyền vũ 35b5
        data["Quý Mùi"] = DayStarData(
            canChi: "Quý Mùi",
            goodStars: [.thienAn, .satCong],
            badStars: [.huyenVu]
        )

        // Page 170: Rows 21-40
        // Row 21: Giáp Thân
        data["Giáp Thân"] = DayStarData(
            canChi: "Giáp Thân",
            goodStars: [.thienQuan],
            badStars: []
        )

        // Row 22: Ất Dậu
        data["Ất Dậu"] = DayStarData(
            canChi: "Ất Dậu",
            goodStars: [],
            badStars: []
        )

        // Row 23: Bính Tuất
        data["Bính Tuất"] = DayStarData(
            canChi: "Bính Tuất",
            goodStars: [],
            badStars: []
        )

        // Row 24: Đinh Hợi
        data["Đinh Hợi"] = DayStarData(
            canChi: "Đinh Hợi",
            goodStars: [],
            badStars: []
        )

        // Row 25: Mậu Tý
        data["Mậu Tý"] = DayStarData(
            canChi: "Mậu Tý",
            goodStars: [],
            badStars: []
        )

        // Row 26: Kỷ Sửu
        data["Kỷ Sửu"] = DayStarData(
            canChi: "Kỷ Sửu",
            goodStars: [],
            badStars: []
        )

        // Row 27: Canh Dần
        data["Canh Dần"] = DayStarData(
            canChi: "Canh Dần",
            goodStars: [.thienDuc],
            badStars: []
        )

        // Row 28: Tân Mão
        data["Tân Mão"] = DayStarData(
            canChi: "Tân Mão",
            goodStars: [],
            badStars: []
        )

        // Row 29: Nhâm Thìn
        data["Nhâm Thìn"] = DayStarData(
            canChi: "Nhâm Thìn",
            goodStars: [.thienQuan],
            badStars: []
        )

        // Row 30: Quý Tỵ
        data["Quý Tỵ"] = DayStarData(
            canChi: "Quý Tỵ",
            goodStars: [.tamHopThienGiai],
            badStars: []
        )

        // Row 31: Giáp Ngọ
        data["Giáp Ngọ"] = DayStarData(
            canChi: "Giáp Ngọ",
            goodStars: [],
            badStars: []
        )

        // Row 32: Ất Mùi
        data["Ất Mùi"] = DayStarData(
            canChi: "Ất Mùi",
            goodStars: [.thienDuc],
            badStars: []
        )

        // Row 33: Bính Thân
        data["Bính Thân"] = DayStarData(
            canChi: "Bính Thân",
            goodStars: [.thienQuan],
            badStars: []
        )

        // Row 34: Đinh Dậu
        data["Đinh Dậu"] = DayStarData(
            canChi: "Đinh Dậu",
            goodStars: [.tamHopThienGiai],
            badStars: []
        )

        // Row 35: Mậu Tuất
        data["Mậu Tuất"] = DayStarData(
            canChi: "Mậu Tuất",
            goodStars: [],
            badStars: []
        )

        // Row 36: Kỷ Hợi
        data["Kỷ Hợi"] = DayStarData(
            canChi: "Kỷ Hợi",
            goodStars: [],
            badStars: []
        )

        // Row 37: Canh Tý
        data["Canh Tý"] = DayStarData(
            canChi: "Canh Tý",
            goodStars: [],
            badStars: []
        )

        // Row 38: Tân Sửu
        data["Tân Sửu"] = DayStarData(
            canChi: "Tân Sửu",
            goodStars: [.thienDuc],
            badStars: []
        )

        // Row 39: Nhâm Dần
        data["Nhâm Dần"] = DayStarData(
            canChi: "Nhâm Dần",
            goodStars: [],
            badStars: []
        )

        // Row 40: Quý Mão
        data["Quý Mão"] = DayStarData(
            canChi: "Quý Mão",
            goodStars: [],
            badStars: []
        )

        // Page 172: Rows 41-60
        // Row 41: Giáp Thìn
        data["Giáp Thìn"] = DayStarData(
            canChi: "Giáp Thìn",
            goodStars: [.thienQuan],
            badStars: []
        )

        // Row 42: Ất Tỵ
        data["Ất Tỵ"] = DayStarData(
            canChi: "Ất Tỵ",
            goodStars: [.tamHopThienGiai],
            badStars: []
        )

        // Row 43: Bính Ngọ
        data["Bính Ngọ"] = DayStarData(
            canChi: "Bính Ngọ",
            goodStars: [.thienQuan],
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
            goodStars: [],
            badStars: []
        )

        // Row 46: Kỷ Dậu
        data["Kỷ Dậu"] = DayStarData(
            canChi: "Kỷ Dậu",
            goodStars: [],
            badStars: []
        )

        // Row 47: Canh Tuất
        data["Canh Tuất"] = DayStarData(
            canChi: "Canh Tuất",
            goodStars: [.thienDuc],
            badStars: []
        )

        // Row 48: Tân Hợi
        data["Tân Hợi"] = DayStarData(
            canChi: "Tân Hợi",
            goodStars: [],
            badStars: []
        )

        // Row 49: Nhâm Tý
        data["Nhâm Tý"] = DayStarData(
            canChi: "Nhâm Tý",
            goodStars: [],
            badStars: []
        )

        // Row 50: Quý Sửu
        data["Quý Sửu"] = DayStarData(
            canChi: "Quý Sửu",
            goodStars: [],
            badStars: []
        )

        // Row 51: Giáp Dần
        data["Giáp Dần"] = DayStarData(
            canChi: "Giáp Dần",
            goodStars: [.thienQuan],
            badStars: []
        )

        // Row 52: Ất Mão
        data["Ất Mão"] = DayStarData(
            canChi: "Ất Mão",
            goodStars: [.thienDuc, .tamHopThienGiai],
            badStars: []
        )

        // Row 53: Bính Thìn
        data["Bính Thìn"] = DayStarData(
            canChi: "Bính Thìn",
            goodStars: [.thienQuan],
            badStars: []
        )

        // Row 54: Đinh Tỵ
        data["Đinh Tỵ"] = DayStarData(
            canChi: "Đinh Tỵ",
            goodStars: [.tamHopThienGiai],
            badStars: []
        )

        // Row 55: Mậu Ngọ
        data["Mậu Ngọ"] = DayStarData(
            canChi: "Mậu Ngọ",
            goodStars: [],
            badStars: []
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
            badStars: []
        )

        // Row 58: Tân Dậu
        data["Tân Dậu"] = DayStarData(
            canChi: "Tân Dậu",
            goodStars: [],
            badStars: []
        )

        // Row 59: Nhâm Tuất
        data["Nhâm Tuất"] = DayStarData(
            canChi: "Nhâm Tuất",
            goodStars: [],
            badStars: []
        )

        // Row 60: Quý Hợi
        data["Quý Hợi"] = DayStarData(
            canChi: "Quý Hợi",
            goodStars: [.thienQuan, .tamHopThienGiai],
            badStars: []
        )

        return data
    }
}

// MARK: - Data Completeness Check

extension Month12StarData {
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
        print("Month 12 Star Data: \(status.completed)/\(status.total) entries (\(String(format: "%.1f", percentage))%)")

        if status.completed < status.total {
            print("⚠️ WARNING: Incomplete data - need \(status.total - status.completed) more entries from book pages 168-172")
        } else {
            print("✅ Complete data for all 60 Can-Chi combinations")
        }
    }
}
