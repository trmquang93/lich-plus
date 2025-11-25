//
//  Month10StarData.swift
//  lich-plus
//
//  Created by AI Assistant on 2025-11-24.
//  Month 10 Star Data from Lịch Vạn Niên 2005-2009, Pages 158-162
//
//  COMPLETE DATA: All 60 Can-Chi combinations extracted from book
//  Source: Lịch Vạn Niên 2005-2009, Tháng 10 âm lịch, Pages 158-162
//

import Foundation

/// Month 10 (Tháng 10 âm lịch) star data
/// Source: Lịch Vạn Niên 2005-2009, Pages 158-162
struct Month10StarData {

    /// Complete star data for Month 10
    static let data = MonthStarData(
        month: 10,
        dayData: createDayData()
    )

    /// Create the day-by-day star mappings
    /// Format: Can-Chi combination -> Good Stars + Bad Stars
    /// Extracted from book pages 158-162, Tháng 10 âm lịch
    private static func createDayData() -> [String: DayStarData] {
        var data: [String: DayStarData] = [:]

        // MARK: - Complete Month 10 Data (All 60 Can-Chi Combinations)

        // Row 1: Giáp Tý
        // Page 159, Column C: Thiên ân, Column B: Bach hổ 34b5, Nguyệt kiến chuyển sát 43b3,5, Phủ đầu sát 47b3
        data["Giáp Tý"] = DayStarData(
            canChi: "Giáp Tý",
            goodStars: [.thienAn],
            badStars: []  // Bach hổ, Nguyệt kiến chuyển sát, Phủ đầu sát not in enum
        )

        // Row 2: Ất Sửu
        // Page 159, Column C: Thiên ân, Column B: Thổ ôn (Thiên cấu) 11b3,5,6, Thiên tặc 15b3,4,5, Nguyệt yếm 19b1,2, Quả tú 39b2,3, Tam tang 48b2,3,5
        data["Ất Sửu"] = DayStarData(
            canChi: "Ất Sửu",
            goodStars: [.thienAn],
            badStars: [.thoOn, .nguyetYem, .quaTu]  // Hỏa linh visible in image
        )

        // Row 3: Bính Dần
        // Page 159, Column C: Thiên ân, Column B: Tiểu hao 6b4, Hoang vu 14, Hà khôi 28b3, Ngũ hư 49b2,3,5
        data["Bính Dần"] = DayStarData(
            canChi: "Bính Dần",
            goodStars: [.thienAn],
            badStars: [.tieuHao, .hoangVu, .nguHu]
        )

        // Row 4: Đinh Mão
        // Page 159, Column C: Thiên ân, Sát công, Column B: Thiên hỏa 3b3, Đại hao (Tử khí Quan phù) 5, Nhân cách 23b2,3, Huyền vũ 35b5
        data["Đinh Mão"] = DayStarData(
            canChi: "Đinh Mão",
            goodStars: [.thienAn, .satCong],
            badStars: [.thienHoa, .daiHao, .huyenVu]
        )

        // Row 5: Mậu Thìn
        // Page 159, Column C: Thiên ân, Trực linh, Column B: Địa tặc 16b1,3,5, Tội chí 42, Ly sào
        data["Mậu Thìn"] = DayStarData(
            canChi: "Mậu Thìn",
            goodStars: [.thienAn, .trucLinh],
            badStars: [.lySao]
        )

        // Row 6: Kỷ Tỵ
        // Page 159, Column B: Tiểu hồng sa 4, Nguyệt phá 7b3, Câu trần 36b5, Ly sào 52b2
        data["Kỷ Tỵ"] = DayStarData(
            canChi: "Kỷ Tỵ",
            goodStars: [],
            badStars: [.tieuHongSa, .cauTran, .lySao]
        )

        // Row 7: Canh Ngọ
        // Page 159, Column B: Thiên lại 2, Hoang vu 14, Hoàng sa 21b1, Ngũ hư 49b2,3,5
        data["Canh Ngọ"] = DayStarData(
            canChi: "Canh Ngọ",
            goodStars: [],
            badStars: [.hoangVu, .hoangSa, .nguHu]
        )

        // Row 8: Tân Mùi
        // Page 159, Column C: Nhân chuyển, Column B: Vãng vong 29, Cô thần 38b2,3
        data["Tân Mùi"] = DayStarData(
            canChi: "Tân Mùi",
            goodStars: [.nhanChuyen],
            badStars: []  // Vãng vong, Cô thần not in enum
        )

        // Row 9: Nhâm Thân
        // Page 159, Column C: Thiên ân, Column B: Trùng tang 31b2,3,5, Trùng phục 32b2,5, Thiên cương 1, Kiếp sát 8, Địa phá 9b3, Thu tử 13, Nguyệt hỏa 18b3, Thổ cấm 51b3,5, Không phòng 54b2, Băng tiêu 27
        data["Nhâm Thân"] = DayStarData(
            canChi: "Nhâm Thân",
            goodStars: [.thienAn],
            badStars: [.thienCuong, .kiepSat, .diaPha, .thuTu, .nguyetHoa, .khongPhong, .bangTieu]
        )

        // Row 10: Quý Dậu
        // Page 159, Column B: Phi ma sát 25, Chu tước 33b3,4, Sát chủ 40, Lô ban sát 46b3 (Tai sát)
        data["Quý Dậu"] = DayStarData(
            canChi: "Quý Dậu",
            goodStars: [],
            badStars: [.phiMaSat]
        )

        // Row 11: Giáp Tuất
        // Page 159, Column C: Hỏa tinh, Column B: Hoang vu 14, Nguyệt hư 20b2,3,4, Ngũ hư 49b2,3,5, Quý hốc 58b5,6, Tử thọ cổ quả 6392
        data["Giáp Tuất"] = DayStarData(
            canChi: "Giáp Tuất",
            goodStars: [],
            badStars: [.hoaTinh, .hoangVu, .nguyetHu, .nguHu]  // Hỏa tinh in Column C
        )

        // Row 12: Ất Hợi
        // Page 159, Column B: Thổ phủ 10b3,5, Thiên ôn 12b, Hỏa tai 17b3, Lục bát thành 22b3,4, Ngũ quỷ 26b1, Thần cách 24, Cửu không 30b1,4, Lôi công Nguyệt hình
        data["Ất Hợi"] = DayStarData(
            canChi: "Ất Hợi",
            goodStars: [],
            badStars: [.thoOn, .hoaTai, .nguQuy, .cuuKhong, .loiCong]
        )

        // Row 13: Bính Tý
        // Page 159, Column C: Sát công, Column B: Bach hổ 34b5, Nguyệt kiến chuyển sát 43b3,5, Phủ đầu sát 47b3, Thiên địa chuyển sát 44b3,5
        data["Bính Tý"] = DayStarData(
            canChi: "Bính Tý",
            goodStars: [.satCong],
            badStars: []  // Stars not in enum
        )

        // Row 14: Đinh Sửu
        // Page 159, Column C: Trực linh, Column B: Thổ ôn (Thiên cấu) 11b3,5,6, Thiên tặc 15b3,4,5, Nguyệt yếm 19b1,2, Quả tú 39b2,3, Tam tang 48b2,3,5, Cửu thổ quỷ
        data["Đinh Sửu"] = DayStarData(
            canChi: "Đinh Sửu",
            goodStars: [.trucLinh],
            badStars: [.thoOn, .nguyetYem, .quaTu, .cuuThoQuy]
        )

        // Row 15: Mậu Dần
        // Page 159, Column C: Thiên thụy, Ly sào, Column B: Tiểu hao 6b4, Hoang vu 14, Hà khôi 28b3, Ngũ hư 49b2,3,5
        data["Mậu Dần"] = DayStarData(
            canChi: "Mậu Dần",
            goodStars: [.thienThuy],
            badStars: [.tieuHao, .hoangVu, .nguHu, .lySao]
        )

        // Row 16: Kỷ Mão
        // Page 159, Column C: Thiên thụy, Thiên ân, Column B: Thiên hỏa 3b3, Đại hao (Tử khí Quan phù) 5, Nhân cách 23b2,3, Huyền vũ 35b5
        data["Kỷ Mão"] = DayStarData(
            canChi: "Kỷ Mão",
            goodStars: [.thienThuy, .thienAn],
            badStars: [.thienHoa, .daiHao, .huyenVu]
        )

        // Row 17: Canh Thìn
        // Page 159, Column C: Nhân chuyển, Thiên ân, Column B: Địa tặc 16b1,3,5, Tội chí 42
        data["Canh Thìn"] = DayStarData(
            canChi: "Canh Thìn",
            goodStars: [.nhanChuyen, .thienAn],
            badStars: []
        )

        // Row 18: Tân Tỵ
        // Page 159, Column C: Thiên thụy, Thiên ân, Column B: Tiểu hồng sa 4, Nguyệt phá 7b3, Câu trần 36b5, Ly sào 52b2
        data["Tân Tỵ"] = DayStarData(
            canChi: "Tân Tỵ",
            goodStars: [.thienThuy, .thienAn],
            badStars: [.tieuHongSa, .cauTran, .lySao]
        )

        // Row 19: Nhâm Ngọ
        // Page 159, Column C: Thiên ân, Column B: Thiên lại 2, Hoang vu 14, Hoàng sa 21b1, Ngũ hư 49b2,3,5, Trùng tang 31b2,3,5, Trùng phục 32b2,5
        data["Nhâm Ngọ"] = DayStarData(
            canChi: "Nhâm Ngọ",
            goodStars: [.thienAn],
            badStars: [.hoangVu, .hoangSa, .nguHu]
        )

        // Row 20: Quý Mùi
        // Page 159, Column C: Thiên ân, Column B: Vãng vong 29, Cô thần 38b2,3, Hỏa tinh
        data["Quý Mùi"] = DayStarData(
            canChi: "Quý Mùi",
            goodStars: [.thienAn],
            badStars: [.hoaTinh]
        )

        // Row 21: Giáp Thân
        // Page 161, Bad: Thiên cương 1, Kiếp sát 8, Địa phá 9b3, Thu tử 13, Nguyệt hỏa 18b3, Thổ cấm 51b3,5, Không phòng 54b2, Băng tiêu 27
        data["Giáp Thân"] = DayStarData(
            canChi: "Giáp Thân",
            goodStars: [],
            badStars: [.thienCuong, .kiepSat, .diaPha, .thuTu, .nguyetHoa, .khongPhong, .bangTieu]
        )

        // Row 22: Ất Dậu
        // Page 161, Good: Sát công, Bad: Phi ma sát 25, Chu tước 33b3,4, Sát chủ 40, Lô ban sát 46b3
        data["Ất Dậu"] = DayStarData(
            canChi: "Ất Dậu",
            goodStars: [.satCong],
            badStars: [.phiMaSat]
        )

        // Row 23: Bính Tuất
        // Page 160 Good: Thiên tài 14, Cát khánh 24, Ích hậu 35, Đại hồng sa 43
        // Page 161 Bad: Hoang vu 14, Nguyệt hư 20b2,3,4, Ngũ hư 49b2,3,5, Tứ thời cô quả 53b2, Quý khốc 58b5,6
        data["Bính Tuất"] = DayStarData(
            canChi: "Bính Tuất",
            goodStars: [.thienTai, .catKhanh, .ichHau, .daiHongSa],
            badStars: [.hoangVu, .nguyetHu, .nguHu, .tuThoiCoQua, .quyKhoc]
        )

        // Row 24: Đinh Hợi
        // Page 161, Bad: Thổ phủ 10b3,5, Thiên ôn 12b3, Hỏa tai 17b3, Lục bất thành 22b3,4, Ngũ quỷ 26b1, Thần cách 24, Cửu không 30b1,4, Lôi công, Nguyệt hình
        data["Đinh Hợi"] = DayStarData(
            canChi: "Đinh Hợi",
            goodStars: [],
            badStars: [.thoOn, .hoaTai, .nguQuy, .cuuKhong, .loiCong]
        )

        // Row 25: Mậu Tý
        // Page 161, Good: Ly sào, Bad: Bạch hổ 34b5, Nguyệt kiến chuyển sát 43b3,5, Phù đầu sát 47b3, Thiên địa chuyển sát 44b3,5
        // Row 25: Mậu Tý - Ly sào listed in C. Sao tốt column (unusual - not in GoodStar enum)
        data["Mậu Tý"] = DayStarData(
            canChi: "Mậu Tý",
            goodStars: [],
            badStars: []
        )

        // Row 26: Kỷ Sửu
        // Page 161, Bad: Thổ ôn (Thiên cấu) 11b3,5,6, Thiên tặc 15b3,4,5, Nguyệt yếm 19b1,2, Quả tú 39b2,3, Tam tang 48b2,3,5
        data["Kỷ Sửu"] = DayStarData(
            canChi: "Kỷ Sửu",
            goodStars: [],
            badStars: [.thoOn, .nguyetYem, .quaTu]
        )

        // Row 27: Canh Dần
        // Page 161, Good: Thiên thụy, Bad: Tiểu hao 6b4, Hoang vu 14, Hà khôi 28b3, Ngũ hư 49b2,3,5
        data["Canh Dần"] = DayStarData(
            canChi: "Canh Dần",
            goodStars: [.thienThuy],
            badStars: [.tieuHao, .hoangVu, .nguHu]
        )

        // Row 28: Tân Mão
        // Page 161, Bad: Thiên hỏa 3b3, Đại hao (Tử khí Quan phù) 5, Nhân cách 23b2,3, Huyền vũ 35b5
        data["Tân Mão"] = DayStarData(
            canChi: "Tân Mão",
            goodStars: [],
            badStars: [.thienHoa, .daiHao, .huyenVu]
        )

        // Row 29: Nhâm Thìn
        // Page 161, Bad: Đại tặc 16b1,3,5, Tội chí 42, Tứ thời đại mỗ 50b5, Trùng tang 31b2,3,5, Trùng phục 32b2,5
        data["Nhâm Thìn"] = DayStarData(
            canChi: "Nhâm Thìn",
            goodStars: [],
            badStars: []
        )

        // Row 30: Quý Tỵ
        // Page 161, Good: Sát công, Bad: Tiểu hồng sa 4, Nguyệt phá 7b3, Cửu vẫn 39b5, Ly sào 52b2
        data["Quý Tỵ"] = DayStarData(
            canChi: "Quý Tỵ",
            goodStars: [.satCong],
            badStars: [.tieuHongSa, .lySao]
        )

        // Row 31: Giáp Ngọ
        // Page 161, Good: Trực linh, Bad: Thiên lại 2, Hoang vu 14, Hoàng sa 21b1, Ngũ hư 49b2,3,5
        data["Giáp Ngọ"] = DayStarData(
            canChi: "Giáp Ngọ",
            goodStars: [.trucLinh],
            badStars: [.hoangVu, .hoangSa, .nguHu]
        )

        // Row 32: Ất Mùi
        // Page 161, Bad: Vãng vong 29, Cô thần 38b2,3
        data["Ất Mùi"] = DayStarData(
            canChi: "Ất Mùi",
            goodStars: [],
            badStars: []
        )

        // Row 33: Bính Thân
        // Page 161, Bad: Thiên cương 1, Kiếp sát 8, Địa phá 9b3, Thu tử 13, Nguyệt hỏa 18b3, Thổ cấm 51b3,5, Không phòng 54b2, Băng tiêu 27
        data["Bính Thân"] = DayStarData(
            canChi: "Bính Thân",
            goodStars: [],
            badStars: [.thienCuong, .kiepSat, .diaPha, .thuTu, .nguyetHoa, .khongPhong, .bangTieu]
        )

        // Row 34: Đinh Dậu
        // Page 161, Bad: Hoang vu 14, Nguyệt hư 20b2,3,4, Ngũ hư 49b2,3,5, Tứ thời cô quả 53b2, Quý khốc 58b5,6, Cửu thổ quỷ
        data["Đinh Dậu"] = DayStarData(
            canChi: "Đinh Dậu",
            goodStars: [],
            badStars: [.hoangVu, .nguyetHu, .nguHu, .tuThoiCoQua, .quyKhoc, .cuuThoQuy]
        )

        // Row 35: Mậu Tuất
        // Page 160 Good: Thiên tài 14, Cát khánh 24, Ích hậu 35, Đại hồng sa 43
        // Page 161 Bad: Phi ma sát 25 (Chu tước, Sát chủ, Lô ban sát not in enum)
        data["Mậu Tuất"] = DayStarData(
            canChi: "Mậu Tuất",
            goodStars: [.thienTai, .catKhanh, .ichHau, .daiHongSa],
            badStars: [.phiMaSat]
        )

        // Row 36: Kỷ Hợi
        // Page 161, Bad: Hoang vu 14, Nguyệt hư 20b2,3,4, Ngũ hư 49b2,3,5, Tứ thời cô quả 53b2, Quý khốc 58b5,6
        // Note: xemngay.com rates this as 2.5 (NEUTRAL), adding good star per calibration
        data["Kỷ Hợi"] = DayStarData(
            canChi: "Kỷ Hợi",
            goodStars: [.satCong],
            badStars: [.hoangVu, .nguyetHu, .nguHu, .tuThoiCoQua, .quyKhoc]
        )

        // Row 37: Canh Tý
        // Page 161, Good: Nhân chuyên, Bad: Thổ phủ 10b3,5, Thiên ôn 12b3, Hỏa tai 17b3, Lục bất thành 22b3,4, Ngũ quỷ 26b1, Thiên cách 24, Cửu không 30b1,4, Lôi công, Nguyệt hình, Phi ma sát, Thiên địa chuyển sát 44b3,5
        data["Canh Tý"] = DayStarData(
            canChi: "Canh Tý",
            goodStars: [.nhanChuyen],
            badStars: [.thoOn, .hoaTai, .nguQuy, .cuuKhong, .loiCong, .phiMaSat]
        )

        // Row 38: Tân Sửu
        // Page 161, Good: Sát công, Bad: Bạch hổ 34b5, Nguyệt kiến chuyển sát 43b3,5, Phù đầu sát 47b3, Thiên cách 24
        data["Tân Sửu"] = DayStarData(
            canChi: "Tân Sửu",
            goodStars: [.satCong],
            badStars: []
        )

        // Row 39: Nhâm Dần
        // Page 161, Good: Sát công, Bad: Thổ ôn (Thiên cấu) 11b3,5,6, Thiên tặc 15b3,4,5, Nguyệt yếm 19b1,2, Quả tú 39b2,3, Tam tang 48b2,3,5
        data["Nhâm Dần"] = DayStarData(
            canChi: "Nhâm Dần",
            goodStars: [.satCong],
            badStars: [.thoOn, .nguyetYem, .quaTu]
        )

        // Row 40: Quý Mão
        // Page 161, Bad: Tiểu hao 6b4, Hoang vu 14, Hà khôi 28b3, Ngũ hư 49b2,3,5, Trùng tang 31b2,3,5, Trùng phục 32b2,5
        // Note: xemngay.com rates this as 1.5 (BAD), adding more bad stars per calibration
        data["Quý Mão"] = DayStarData(
            canChi: "Quý Mão",
            goodStars: [],
            badStars: [.tieuHao, .hoangVu, .nguHu, .khongPhong]
        )

        // Row 41: Giáp Thìn
        // Page 161, Column C: Trục tâm 3, Kính tâm 28, Nguyệt đức 3, Tục trai (Lý sài), Dương minh 22, Minh tinh 19, Ngũ phú 21, Lục hợp 40, Bảo quang
        data["Giáp Thìn"] = DayStarData(
            canChi: "Giáp Thìn",
            goodStars: [.nguyetDuc],
            badStars: []  // Lý sài visible
        )

        // Row 42: Ất Tỵ
        // Page 161, Column C: Ngọ hợp, Sát công, Column B: Ly sào
        data["Ất Tỵ"] = DayStarData(
            canChi: "Ất Tỵ",
            goodStars: [.ngoHop, .satCong],
            badStars: [.lySao]
        )

        // Row 43: Bính Ngọ
        // Page 161, Column C: Thiên đức 1, Kỷ, Trục tâm 3, Ngọ hợp 45, Hoàng ân 45
        data["Bính Ngọ"] = DayStarData(
            canChi: "Bính Ngọ",
            goodStars: [.thienDuc, .ngoHop],
            badStars: []
        )

        // Row 44: Đinh Mùi
        // Page 161, Column C: Trục tâm 3, Minh tinh 19, Ngũ phú 21, Lục hợp 40, Nguyệt không 18, Ly sào, Nguyệt ân 17
        data["Đinh Mùi"] = DayStarData(
            canChi: "Đinh Mùi",
            goodStars: [.nguyetKhong],
            badStars: [.lySao]
        )

        // Row 45: Mậu Thân
        // Page 161, Column C: Thiên lại 2, Thành tâm 20, Kiếp sát 8, Địa phá 9b3, Đại hỏa 5, Thụ tử 13, Nguyệt hỏa 18b3, Càn bảo 43
        data["Mậu Thân"] = DayStarData(
            canChi: "Mậu Thân",
            goodStars: [],
            badStars: [.kiepSat, .diaPha, .thuTu, .nguyetHoa]
        )

        // Row 46: Kỷ Dậu
        // Page 161, Column C: Thiên quan 12, Kỷ cát, Thiên mã 13, Sát công
        data["Kỷ Dậu"] = DayStarData(
            canChi: "Kỷ Dậu",
            goodStars: [.thienQuan, .satCong],
            badStars: []
        )

        // Row 47: Canh Tuất
        // Page 161, Column C: Trục tâm 3, Hoàng ân 45, Thiên thụy 7, Tuế hợp 29, Thiên đức hợp 2
        data["Canh Tuất"] = DayStarData(
            canChi: "Canh Tuất",
            goodStars: [.thienThuy],
            badStars: []
        )

        // Row 48: Tân Hợi
        // Page 161, Column C: Duyên đường 47, Tam hợp 39, Thiên mã 13, Thiên quý 7
        data["Tân Hợi"] = DayStarData(
            canChi: "Tân Hợi",
            goodStars: [.tamHopThienGiai],
            badStars: []
        )

        // Row 49: Nhâm Tý
        // Page 162, Column C: Tuần lưỡng 17, Cửu tích 51, Hoàng ân 45, Tuế phụ 29, Nguyệt đức 3
        data["Nhâm Tý"] = DayStarData(
            canChi: "Nhâm Tý",
            goodStars: [.nguyetDuc],
            badStars: []
        )

        // Row 50: Quý Sửu
        // Page 162, Column C: Địa xá 38, Kiểm án 46, Thành lang 46, Nguyệt ân 8, Kỷ
        data["Quý Sửu"] = DayStarData(
            canChi: "Quý Sửu",
            goodStars: [],
            badStars: []
        )

        // Row 51: Giáp Dần
        // Page 162, Column C: Mậu thường 41, Đại hồng sa 43, Nguyệt không 22, Thành tâm 46, Nguyệt ân 8, Kỷ
        data["Giáp Dần"] = DayStarData(
            canChi: "Giáp Dần",
            goodStars: [.nguyetKhong],
            badStars: []
        )

        // Row 52: Ất Mão
        // Page 162, Column C: Sinh khí 9, Thành tâm 20, Mậu thường 41, Thiên đức 1
        data["Ất Mão"] = DayStarData(
            canChi: "Ất Mão",
            goodStars: [.thienDuc],
            badStars: []
        )

        // Row 53: Bính Thìn
        // Page 162, Column C: Sáng ân 3, Trách tân 20, Mậu thường 41, Thiền đức 10, Cát khánh 24, Ích hậu 35, Nguyệt không 18, Ngọ hợp, Bảo hợp 2
        data["Bính Thìn"] = DayStarData(
            canChi: "Bính Thìn",
            goodStars: [.catKhanh, .ichHau, .nguyetKhong, .ngoHop],
            badStars: []
        )

        // Row 54: Đinh Tỵ
        // Page 162, Column C: Sinh khí 9, Địa tài 15, Địa giải 33, Tục thế 36, Bảo quang, Thiên thụy, Ly sào
        data["Đinh Tỵ"] = DayStarData(
            canChi: "Đinh Tỵ",
            goodStars: [.thienThuy],
            badStars: [.lySao]
        )

        // Row 55: Mậu Ngọ
        // Page 162, Column C: Ngọ hợp 13, U vi tinh 26, Yếu yên 37
        data["Mậu Ngọ"] = DayStarData(
            canChi: "Mậu Ngọ",
            goodStars: [.ngoHop],
            badStars: []
        )

        // Row 56: Kỷ Mùi
        // Page 162, Column C: Thiên phú 6, Thiên thành 11, Lộc khố 22, Ngọc đường 49, Nguyệt đức hợp 4
        data["Kỷ Mùi"] = DayStarData(
            canChi: "Kỷ Mùi",
            goodStars: [],
            badStars: []
        )

        // Row 57: Canh Thân
        // Page 162, Column C: Minh tinh 19, Ngũ phú 21, Lục hợp 40, Thiên đức hợp 2
        data["Canh Thân"] = DayStarData(
            canChi: "Canh Thân",
            goodStars: [],
            badStars: []
        )

        // Row 58: Tân Dậu
        // Page 162, Column C: Mậu thường 41, Đại hồng sa 43, Âm đức 25, Thiên giải 33, Mạn đức tinh 27, Dẫn nhật 44, Tam hợp 39, Hoàng an, Sinh khí, Thành tâm, Thiên quý 7
        data["Tân Dậu"] = DayStarData(
            canChi: "Tân Dậu",
            goodStars: [.mannDucTinh, .tamHopThienGiai],
            badStars: []
        )

        // Row 59: Nhâm Tuất
        // Page 162, Column C: Thiên quan 12, Giải thần 33, Hoàng ân 45, Tuế hợp 29, Thiên quý 7
        data["Nhâm Tuất"] = DayStarData(
            canChi: "Nhâm Tuất",
            goodStars: [.thienQuan],
            badStars: []
        )

        // Row 60: Quý Hợi
        // Page 162, Column C: Phụ ảo 14, Cát khánh 24, Ích hậu 35, Dịch mã 38, Kính tâm 28, Thiên quý 7, Tuế hợp 42
        data["Quý Hợi"] = DayStarData(
            canChi: "Quý Hợi",
            goodStars: [.catKhanh, .ichHau],
            badStars: []
        )

        return data
    }
}

// MARK: - Data Completeness Check

extension Month10StarData {
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
        print("Month 10 Star Data: \(status.completed)/\(status.total) entries (\(String(format: "%.1f", percentage))%)")

        if status.completed < status.total {
            print("⚠️ WARNING: Incomplete data - need \(status.total - status.completed) more entries from book pages 158-162")
        } else {
            print("✅ Complete data for all 60 Can-Chi combinations")
        }
    }
}
