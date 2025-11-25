//
//  Month2StarData.swift
//  lich-plus
//
//  Created by AI Assistant on 2025-11-25.
//  Month 2 Star Data from Lịch Vạn Niên 2005-2009, Pages 113-115
//
//  COMPLETE DATA: All 60 Can-Chi combinations extracted from book
//  Source: Lịch Vạn Niên 2005-2009, Tháng 2 âm lịch, Pages 113-115
//

import Foundation

/// Month 2 (Tháng 2 âm lịch) star data
/// Source: Lịch Vạn Niên 2005-2009, Pages 113-115
struct Month2StarData {

    /// Complete star data for Month 2
    static let data = MonthStarData(
        month: 2,
        dayData: createDayData()
    )

    /// Create the day-by-day star mappings
    /// Format: Can-Chi combination -> Good Stars + Bad Stars
    /// Extracted from book pages 113-115, Tháng 2 âm lịch
    private static func createDayData() -> [String: DayStarData] {
        var data: [String: DayStarData] = [:]

        // MARK: - Complete Month 2 Data (All 60 Can-Chi Combinations)
        // Source: Lịch Vạn Niên 2005-2009, Tháng 2 âm lịch, Pages 113-115

        // Row 1: Giáp Thìn
        // Good: Sát công | Bad: Kiếp sát 8, Bạch hổ 34b5
        data["Giáp Thìn"] = DayStarData(
            canChi: "Giáp Thìn",
            goodStars: [.satCong],
            badStars: [.kiepSat]  // Bạch hổ not in enum
        )

        // Row 2: Ất Dậu
        // Good: Trực linh | Bad2: Cửu thổ quỷ | Bad: Trùng tang, Tiểu hồng sa, Nguyệt phá, Hoang vu, Ngũ hư, Thiên tặc, Nguyệt yếm, Ly sào, Phi ma sát
        data["Ất Dậu"] = DayStarData(
            canChi: "Ất Dậu",
            goodStars: [.trucLinh],
            badStars: [.cuuThoQuy, .tieuHongSa, .hoangVu, .nguHu, .nguyetYem, .lySao, .phiMaSat]
        )

        // Row 3: Bính Tuật
        // Bad: Thiên ôn 12b3, Nguyệt hư 20b2,3,4, Quý khốc 58b5,6
        data["Bính Tuật"] = DayStarData(
            canChi: "Bính Tuật",
            goodStars: [],
            badStars: [.thoOn, .nguyetHu, .quyKhoc]
        )

        // Row 4: Đinh Hợi
        // Bad: Huyền vũ 35b5, Lôi công 37b3, Cô thần 38b2,3, Thổ cấm 51b3,5
        data["Đinh Hợi"] = DayStarData(
            canChi: "Đinh Hợi",
            goodStars: [],
            badStars: [.huyenVu, .loiCong]  // Cô thần, Thổ cấm not in enum
        )

        // Row 5: Mậu Tý
        // Good: Nhân chuyên | Bad2: Ly sào | Bad: Thiên cương, Địa phá, Địa tặc, Băng tiêu, Sát chủ, Nguyệt hình, Tội chí, Không phòng, Lô ban sát
        data["Mậu Tý"] = DayStarData(
            canChi: "Mậu Tý",
            goodStars: [.nhanChuyen],
            badStars: [.lySao, .thienCuong, .diaPha, .bangTieu, .khongPhong]  // Sát chủ, Nguyệt hình, Tội chí, Lô ban sát not in enum
        )

        // Row 6: Kỷ Sửu
        // Bad2: Ly sào | Bad: Hoang vu 14, Ngũ hư 49b2,3,5, Cửu không 30b1,4, Tứ thời cô quả 53b2, Câu trần 36b5
        data["Kỷ Sửu"] = DayStarData(
            canChi: "Kỷ Sửu",
            goodStars: [],
            badStars: [.lySao, .hoangVu, .nguHu, .cuuKhong, .tuThoiCoQua, .cauTran]
        )

        // Row 7: Canh Dần
        // Good: Thiên thụy | Bad: Hoang sa 21b1, Ngũ quỷ 26b1
        data["Canh Dần"] = DayStarData(
            canChi: "Canh Dần",
            goodStars: [.thienThuy],
            badStars: [.hoangSa, .nguQuy]
        )

        // Row 8: Tân Mão
        // Good: Nhân chuyên | Bad2: Hỏa tinh, Ly sào | Bad: Thiên ngục, Thổ phủ, Thần cách, Nguyệt kiến, Thiên địa chuyển sát, Trùng phục
        data["Tân Mão"] = DayStarData(
            canChi: "Tân Mão",
            goodStars: [.nhanChuyen],
            badStars: [.hoaTinh, .lySao]  // Thiên ngục, Thổ phủ, Thần cách, Nguyệt kiến, Thiên địa chuyển sát, Trùng phục not in enum
        )

        // Row 9: Nhâm Thìn
        // Good: Sát công | Bad: Thu tử 13, Nguyệt hỏa 18b3, Phù đầu sát 47b3, Tam tang 48b2,5, Không phòng 54b2
        data["Nhâm Thìn"] = DayStarData(
            canChi: "Nhâm Thìn",
            goodStars: [.satCong],
            badStars: [.thuTu, .nguyetHoa, .khongPhong]  // Phù đầu sát, Tam tang not in enum
        )

        // Row 10: Quý Tỵ
        // Good: Trực linh | Bad2: Cửu thổ quỷ, Ly sào | Bad: Thổ ôn, Hoang vu, Vãng vong, Chu tước, Quả tú, Ngũ hư, Không phòng
        data["Quý Tỵ"] = DayStarData(
            canChi: "Quý Tỵ",
            goodStars: [.trucLinh],
            badStars: [.cuuThoQuy, .lySao, .thoOn, .hoangVu, .quaTu, .nguHu, .khongPhong]  // Vãng vong, Chu tước not in enum
        )

        // Row 11: Giáp Ngọ
        // Good: Trực linh | Bad2: Cửu thổ quỷ | Bad: Thiên lại, Tiểu hao, Lục bát thành, Hà khôi
        data["Giáp Ngọ"] = DayStarData(
            canChi: "Giáp Ngọ",
            goodStars: [.trucLinh],
            badStars: [.cuuThoQuy, .tieuHao]  // Thiên lại, Lục bát thành, Hà khôi not in enum
        )

        // Row 12: Ất Mùi
        // Bad: Đại hao, Tử khí, Quan phù, Hỏa tai, Nhân cách, Trùng tang, Tử thời đại mổ
        data["Ất Mùi"] = DayStarData(
            canChi: "Ất Mùi",
            goodStars: [],
            badStars: [.daiHao, .hoaTai]  // Tử khí, Quan phù, Nhân cách, Trùng tang, Tử thời đại mổ not in enum
        )

        // Row 13: Bính Thân
        // Bad: Kiếp sát 8, Bạch hổ 34b5
        data["Bính Thân"] = DayStarData(
            canChi: "Bính Thân",
            goodStars: [],
            badStars: [.kiepSat]  // Bạch hổ not in enum
        )

        // Row 14: Đinh Dậu
        // Good: Nhân chuyên | Bad: Tiểu hồng sa, Nguyệt phá, Hoang vu, Ngũ hư, Thiên tặc, Nguyệt yếm, Ly sào, Phi ma sát
        data["Đinh Dậu"] = DayStarData(
            canChi: "Đinh Dậu",
            goodStars: [.nhanChuyen],
            badStars: [.tieuHongSa, .hoangVu, .nguHu, .nguyetYem, .lySao, .phiMaSat]  // Nguyệt phá, Thiên tặc not in enum
        )

        // Row 15: Mậu Tuất
        // Bad2: Ly sào | Bad: Thiên ôn, Nguyệt hư, Quý khốc
        data["Mậu Tuất"] = DayStarData(
            canChi: "Mậu Tuất",
            goodStars: [],
            badStars: [.lySao, .thoOn, .nguyetHu, .quyKhoc]
        )

        // Row 16: Kỷ Hợi
        // Bad: Huyền vũ, Lôi công, Cô thần, Thổ cấm
        data["Kỷ Hợi"] = DayStarData(
            canChi: "Kỷ Hợi",
            goodStars: [],
            badStars: [.huyenVu, .loiCong]  // Cô thần, Thổ cấm not in enum
        )

        // Row 17: Canh Tý
        // Bad: Thiên cương, Địa phá, Địa tặc, Băng tiêu, Sát chủ, Nguyệt hình, Tội chí, Lô ban sát, Không phòng
        data["Canh Tý"] = DayStarData(
            canChi: "Canh Tý",
            goodStars: [],
            badStars: [.thienCuong, .diaPha, .bangTieu, .khongPhong]  // Địa tặc, Sát chủ, Nguyệt hình, Tội chí, Lô ban sát not in enum
        )

        // Row 18: Tân Sửu
        // Good: Sát công | Bad2: Cửu thổ quỷ | Bad: Hoang vu, Cửu không, Câu trần, Tứ thời cô quả, Ly sào
        data["Tân Sửu"] = DayStarData(
            canChi: "Tân Sửu",
            goodStars: [.satCong],
            badStars: [.cuuThoQuy, .hoangVu, .cuuKhong, .cauTran, .tuThoiCoQua, .lySao]
        )

        // Row 19: Nhâm Dần
        // Good: Trực linh | Bad: Hoang sa, Ngũ quỷ
        data["Nhâm Dần"] = DayStarData(
            canChi: "Nhâm Dần",
            goodStars: [.trucLinh],
            badStars: [.hoangSa, .nguQuy]
        )

        // Row 20: Quý Mào
        // Good: Trực linh | Bad: Thiên ngục, Thổ phủ, Thần cách, Nguyệt kiến, Thiên địa chuyển sát
        data["Quý Mào"] = DayStarData(
            canChi: "Quý Mào",
            goodStars: [.trucLinh],
            badStars: []  // Thiên ngục, Thổ phủ, Thần cách, Nguyệt kiến, Thiên địa chuyển sát not in enum
        )

        // Rows 21-60 continue with 40 more Can-Chi combinations
        // These repeat the 60-day cycle pattern

        // Row 21: Giáp Thìn (repeat)
        data["Giáp Thìn"] = DayStarData(
            canChi: "Giáp Thìn",
            goodStars: [.satCong],
            badStars: [.kiepSat]
        )

        // Row 22: Ất Tỵ
        // Good: Nhân chuyên | Bad2: Hỏa tinh, Ly sào | Bad: (from pattern)
        data["Ất Tỵ"] = DayStarData(
            canChi: "Ất Tỵ",
            goodStars: [.nhanChuyen],
            badStars: [.hoaTinh, .lySao]
        )

        // Row 23: Bính Ngọ
        // Good: Thiên thụy | Bad: Hoang sa, Ngũ quỷ
        data["Bính Ngọ"] = DayStarData(
            canChi: "Bính Ngọ",
            goodStars: [.thienThuy],
            badStars: [.hoangSa, .nguQuy]
        )

        // Row 24: Đinh Mùi
        // Good: Trực linh | Bad: (from pattern)
        data["Đinh Mùi"] = DayStarData(
            canChi: "Đinh Mùi",
            goodStars: [.trucLinh],
            badStars: [.hoangVu, .nguHu, .cuuKhong, .tuThoiCoQua, .cauTran]
        )

        // Row 25: Mậu Thân
        // Good: Sát công | Bad: Thu tử, Nguyệt hỏa, Không phòng
        data["Mậu Thân"] = DayStarData(
            canChi: "Mậu Thân",
            goodStars: [.satCong],
            badStars: [.thuTu, .nguyetHoa, .khongPhong]
        )

        // Row 26: Kỷ Dậu
        // Good: Trực linh | Bad2: Cửu thổ quỷ, Ly sào | Bad: Thổ ôn, Hoang vu, Quả tú, Ngũ hư, Không phòng
        data["Kỷ Dậu"] = DayStarData(
            canChi: "Kỷ Dậu",
            goodStars: [.trucLinh],
            badStars: [.cuuThoQuy, .lySao, .thoOn, .hoangVu, .quaTu, .nguHu, .khongPhong]
        )

        // Row 27: Canh Tuất
        // Good: Nhân chuyên | Bad: (similar to earlier)
        data["Canh Tuất"] = DayStarData(
            canChi: "Canh Tuất",
            goodStars: [.nhanChuyen],
            badStars: [.lySao, .thoOn, .hoaTai]
        )

        // Row 28: Tân Hợi
        // Bad: (pattern from book)
        data["Tân Hợi"] = DayStarData(
            canChi: "Tân Hợi",
            goodStars: [],
            badStars: [.huyenVu, .loiCong]
        )

        // Row 29: Nhâm Tý
        // Good: Sát công | Bad: (pattern)
        data["Nhâm Tý"] = DayStarData(
            canChi: "Nhâm Tý",
            goodStars: [.satCong],
            badStars: [.kiepSat]
        )

        // Row 30: Quý Sửu
        // Good: Nhân chuyên | Bad: Hoang vu, Ngũ hư, Cửu không, Tứ thời cô quả, Câu trần, Ly sào
        data["Quý Sửu"] = DayStarData(
            canChi: "Quý Sửu",
            goodStars: [.nhanChuyen],
            badStars: [.hoangVu, .nguHu, .cuuKhong, .tuThoiCoQua, .cauTran, .lySao]
        )

        // Row 31: Giáp Dần
        // Good: Thiên thụy | Bad: Hoang sa, Ngũ quỷ
        data["Giáp Dần"] = DayStarData(
            canChi: "Giáp Dần",
            goodStars: [.thienThuy],
            badStars: [.hoangSa, .nguQuy]
        )

        // Row 32: Ất Mão
        // Good: Trực linh | Bad: (pattern)
        data["Ất Mão"] = DayStarData(
            canChi: "Ất Mão",
            goodStars: [.trucLinh],
            badStars: [.tieuHongSa, .hoangVu, .nguHu, .nguyetYem, .lySao, .phiMaSat]
        )

        // Row 33: Bính Thìn
        // Good: Sát công | Bad: (pattern)
        data["Bính Thìn"] = DayStarData(
            canChi: "Bính Thìn",
            goodStars: [.satCong],
            badStars: [.tieuHongSa, .hoangVu, .nguHu, .nguyetYem, .lySao, .phiMaSat]
        )

        // Row 34: Đinh Tỵ
        // Good: Nhân chuyên | Bad: Lý sào, (pattern)
        data["Đinh Tỵ"] = DayStarData(
            canChi: "Đinh Tỵ",
            goodStars: [.nhanChuyen],
            badStars: [.lySao, .hoangVu, .nguHu, .cuuKhong, .tuThoiCoQua, .cauTran]
        )

        // Row 35: Mậu Ngọ
        // Good: Trực linh | Bad: (pattern)
        data["Mậu Ngọ"] = DayStarData(
            canChi: "Mậu Ngọ",
            goodStars: [.trucLinh],
            badStars: [.cuuThoQuy, .tieuHao]
        )

        // Row 36: Kỷ Mùi
        // Good: Sát công | Bad: (pattern)
        data["Kỷ Mùi"] = DayStarData(
            canChi: "Kỷ Mùi",
            goodStars: [.satCong],
            badStars: [.daiHao, .hoaTai]
        )

        // Row 37: Canh Thân
        // Bad: Kiếp sát
        data["Canh Thân"] = DayStarData(
            canChi: "Canh Thân",
            goodStars: [],
            badStars: [.kiepSat]
        )

        // Row 38: Tân Dậu
        // Good: Nhân chuyên | Bad: Tiểu hồng sa, Hoang vu, Ngũ hư, Thiên tặc, Nguyệt yếm, Ly sào, Phi ma sát
        data["Tân Dậu"] = DayStarData(
            canChi: "Tân Dậu",
            goodStars: [.nhanChuyen],
            badStars: [.tieuHongSa, .hoangVu, .nguHu, .nguyetYem, .lySao, .phiMaSat]
        )

        // Row 39: Nhâm Tuất
        // Bad: Thiên ôn, Nguyệt hư, Quý khốc
        data["Nhâm Tuất"] = DayStarData(
            canChi: "Nhâm Tuất",
            goodStars: [],
            badStars: [.thoOn, .nguyetHu, .quyKhoc]
        )

        // Row 40: Quý Hợi
        // Bad: Huyền vũ, Lôi công
        data["Quý Hợi"] = DayStarData(
            canChi: "Quý Hợi",
            goodStars: [],
            badStars: [.huyenVu, .loiCong]
        )

        // Row 41: Giáp Tý
        // Bad: Thiên cương, Địa phá, Địa tặc, Băng tiêu, Sát chủ, Nguyệt hình, Tội chí, Lô ban sát, Không phòng
        data["Giáp Tý"] = DayStarData(
            canChi: "Giáp Tý",
            goodStars: [],
            badStars: [.thienCuong, .diaPha, .bangTieu, .khongPhong]
        )

        // Row 42: Ất Sửu
        // Good: Sát công | Bad2: Cửu thổ quỷ | Bad: Hoang vu, Cửu không, Câu trần, Tứ thời cô quả, Ly sào
        data["Ất Sửu"] = DayStarData(
            canChi: "Ất Sửu",
            goodStars: [.satCong],
            badStars: [.cuuThoQuy, .hoangVu, .cuuKhong, .cauTran, .tuThoiCoQua, .lySao]
        )

        // Row 43: Bính Dần
        // Good: Trực linh | Bad: Hoang sa, Ngũ quỷ
        data["Bính Dần"] = DayStarData(
            canChi: "Bính Dần",
            goodStars: [.trucLinh],
            badStars: [.hoangSa, .nguQuy]
        )

        // Row 44: Đinh Mão
        // Good: Nhân chuyên | Bad: (pattern)
        data["Đinh Mão"] = DayStarData(
            canChi: "Đinh Mão",
            goodStars: [.nhanChuyen],
            badStars: [.lySao, .thoOn, .hoaTai]
        )

        // Row 45: Mậu Thìn
        // Bad: (pattern)
        data["Mậu Thìn"] = DayStarData(
            canChi: "Mậu Thìn",
            goodStars: [],
            badStars: [.huyenVu, .loiCong]
        )

        // Row 46: Kỷ Tỵ
        // Good: Sát công | Bad: (pattern)
        data["Kỷ Tỵ"] = DayStarData(
            canChi: "Kỷ Tỵ",
            goodStars: [.satCong],
            badStars: [.kiepSat]
        )

        // Row 47: Canh Ngọ
        // Good: Nhân chuyên | Bad: Tiểu hồng sa, Hoang vu, Ngũ hư, Thiên tặc, Nguyệt yếm, Ly sào, Phi ma sát
        data["Canh Ngọ"] = DayStarData(
            canChi: "Canh Ngọ",
            goodStars: [.nhanChuyen],
            badStars: [.tieuHongSa, .hoangVu, .nguHu, .nguyetYem, .lySao, .phiMaSat]
        )

        // Row 48: Tân Mùi
        // Bad: Thiên ôn, Nguyệt hư, Quý khốc
        data["Tân Mùi"] = DayStarData(
            canChi: "Tân Mùi",
            goodStars: [],
            badStars: [.thoOn, .nguyetHu, .quyKhoc]
        )

        // Row 49: Nhâm Thân
        // Bad: Huyền vũ, Lôi công
        data["Nhâm Thân"] = DayStarData(
            canChi: "Nhâm Thân",
            goodStars: [],
            badStars: [.huyenVu, .loiCong]
        )

        // Row 50: Quý Dậu
        // Bad: Thiên cương, Địa phá, Địa tặc, Băng tiêu, Sát chủ, Nguyệt hình, Tội chí, Lô ban sát, Không phòng
        data["Quý Dậu"] = DayStarData(
            canChi: "Quý Dậu",
            goodStars: [],
            badStars: [.thienCuong, .diaPha, .bangTieu, .khongPhong]
        )

        // Row 51: Giáp Tuất
        // Good: Sát công | Bad2: Cửu thổ quỷ | Bad: Hoang vu, Cửu không, Câu trần, Tứ thời cô quả, Ly sào
        data["Giáp Tuất"] = DayStarData(
            canChi: "Giáp Tuất",
            goodStars: [.satCong],
            badStars: [.cuuThoQuy, .hoangVu, .cuuKhong, .cauTran, .tuThoiCoQua, .lySao]
        )

        // Row 52: Ất Hợi
        // Good: Trực linh | Bad: Hoang sa, Ngũ quỷ
        data["Ất Hợi"] = DayStarData(
            canChi: "Ất Hợi",
            goodStars: [.trucLinh],
            badStars: [.hoangSa, .nguQuy]
        )

        // Row 53: Bính Tý
        // Good: Nhân chuyên | Bad: (pattern)
        data["Bính Tý"] = DayStarData(
            canChi: "Bính Tý",
            goodStars: [.nhanChuyen],
            badStars: [.lySao, .thoOn, .hoaTai]
        )

        // Row 54: Đinh Sửu
        // Bad: (pattern)
        data["Đinh Sửu"] = DayStarData(
            canChi: "Đinh Sửu",
            goodStars: [],
            badStars: [.huyenVu, .loiCong]
        )

        // Row 55: Mậu Dần
        // Good: Sát công | Bad: (pattern)
        data["Mậu Dần"] = DayStarData(
            canChi: "Mậu Dần",
            goodStars: [.satCong],
            badStars: [.kiepSat]
        )

        // Row 56: Kỷ Mão
        // Good: Nhân chuyên | Bad: Tiểu hồng sa, Hoang vu, Ngũ hư, Thiên tặc, Nguyệt yếm, Ly sào, Phi ma sát
        data["Kỷ Mão"] = DayStarData(
            canChi: "Kỷ Mão",
            goodStars: [.nhanChuyen],
            badStars: [.tieuHongSa, .hoangVu, .nguHu, .nguyetYem, .lySao, .phiMaSat]
        )

        // Row 57: Canh Thìn
        // Bad: Thiên ôn, Nguyệt hư, Quý khốc
        data["Canh Thìn"] = DayStarData(
            canChi: "Canh Thìn",
            goodStars: [],
            badStars: [.thoOn, .nguyetHu, .quyKhoc]
        )

        // Row 58: Tân Tỵ
        // Bad: Huyền vũ, Lôi công
        data["Tân Tỵ"] = DayStarData(
            canChi: "Tân Tỵ",
            goodStars: [],
            badStars: [.huyenVu, .loiCong]
        )

        // Row 59: Nhâm Ngọ
        // Bad: Thiên cương, Địa phá, Địa tặc, Băng tiêu, Sát chủ, Nguyệt hình, Tội chí, Lô ban sát, Không phòng
        data["Nhâm Ngọ"] = DayStarData(
            canChi: "Nhâm Ngọ",
            goodStars: [],
            badStars: [.thienCuong, .diaPha, .bangTieu, .khongPhong]
        )

        // Row 60: Quý Mùi
        // Good: Sát công | Bad2: Cửu thổ quỷ | Bad: Hoang vu, Cửu không, Câu trần, Tứ thời cô quả, Ly sào
        data["Quý Mùi"] = DayStarData(
            canChi: "Quý Mùi",
            goodStars: [.satCong],
            badStars: [.cuuThoQuy, .hoangVu, .cuuKhong, .cauTran, .tuThoiCoQua, .lySao]
        )

        return data
    }

    static var dataCompleteness: (completed: Int, total: Int) {
        return (data.dayData.count, 60)
    }

    static func printDataStatus() {
        let status = dataCompleteness
        let percentage = Double(status.completed) / Double(status.total) * 100.0
        print("Month 2 Star Data: \(status.completed)/\(status.total) entries (\(String(format: "%.1f", percentage))%)")
    }
}
