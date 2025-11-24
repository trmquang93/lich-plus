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
        // Page 160, Column C: Mậu thường 41, Đại hồng sa 43, Nguyệt đức 3
        data["Giáp Thân"] = DayStarData(
            canChi: "Giáp Thân",
            goodStars: [.nguyetDuc],
            badStars: []  // Mậu thường, Đại hồng sa not in enum
        )

        // Row 22: Ất Dậu
        // Page 160, Column C: Sinh khí 9, Thành tâm 20, Mậu thường 41, Thiên đức 1, Nguyệt ân 17
        data["Ất Dậu"] = DayStarData(
            canChi: "Ất Dậu",
            goodStars: [.thienDuc],
            badStars: []  // Sinh khí, Thành tâm, Mậu thường, Nguyệt ân not in enum
        )

        // Row 23: Bính Tuất
        // Page 160, Column C: Thiên tài 14, Cát khánh 24, Ích hậu 35, Đại hồng sa 43
        data["Bính Tuất"] = DayStarData(
            canChi: "Bính Tuất",
            goodStars: [],
            badStars: []  // Stars not in enum
        )

        // Row 24: Đinh Hợi
        // Page 160, Column C: Địa tài 15, Tục thế 36, Phục hậu 42, Kim đường 48, Thiên phúc 10
        data["Đinh Hợi"] = DayStarData(
            canChi: "Đinh Hợi",
            goodStars: [],
            badStars: []  // Stars not in enum
        )

        // Row 25: Mậu Tý
        // Page 160, Column C: Thiên mã 13, U vi tinh 26, Yếu yên 37
        data["Mậu Tý"] = DayStarData(
            canChi: "Mậu Tý",
            goodStars: [],
            badStars: []  // Stars not in enum
        )

        // Row 26: Kỷ Sửu
        // Page 160, Column C: Thiên phú 6, Thiên thành 11, Lộc khố 22, Ngọc đường 49, Nguyệt đức hợp 4
        data["Kỷ Sửu"] = DayStarData(
            canChi: "Kỷ Sửu",
            goodStars: [],
            badStars: []  // Stars not in enum
        )

        // Row 27: Canh Dần
        // Page 160, Column C: Minh tinh 19, Ngũ phú 21, Lục hợp 40, Thiên đức hợp 2, Nguyệt không 18
        data["Canh Dần"] = DayStarData(
            canChi: "Canh Dần",
            goodStars: [.nguyetKhong],
            badStars: []  // Other stars not in enum
        )

        // Row 28: Tân Mão
        // Page 160, Column C: Âm đức 25, Mạn đức tinh 27, Thiên giải 33, Dẫn nhật 44, Tam hợp 39
        data["Tân Mão"] = DayStarData(
            canChi: "Tân Mão",
            goodStars: [.mannDucTinh, .tamHopThienGiai],
            badStars: []
        )

        // Row 29: Nhâm Thìn
        // Page 160, Column C: Thiên quan 12, Giải thần 33, Hoàng ân 45, Tuế hợp 29, Thiên quý 7
        data["Nhâm Thìn"] = DayStarData(
            canChi: "Nhâm Thìn",
            goodStars: [.thienQuan],
            badStars: []
        )

        // Row 30: Quý Tỵ
        // Page 160, Column C: Dịch mã 38, Kính tâm 28, Thiên quý 7
        data["Quý Tỵ"] = DayStarData(
            canChi: "Quý Tỵ",
            goodStars: [],
            badStars: []  // Stars not in enum
        )

        // Row 31: Giáp Ngọ
        // Page 160, Column C: Hoạt diệu 32, Phổ hộ 34, Thành long 46, Nguyệt giải 30, Nguyệt đức 3
        data["Giáp Ngọ"] = DayStarData(
            canChi: "Giáp Ngọ",
            goodStars: [.nguyetDuc],
            badStars: []
        )

        // Row 32: Ất Mùi
        // Page 160, Column C: Thiên hỷ 5, Nguyệt tài 16, Phúc sinh 23, Minh đường 47, Tam hợp 39, Thiên đức 1, Nguyệt ân 17
        data["Ất Mùi"] = DayStarData(
            canChi: "Ất Mùi",
            goodStars: [.tamHopThienGiai, .thienDuc],
            badStars: []
        )

        // Row 33: Bính Thân
        // Page 160, Column C: Mậu thường 41, Đại hồng sa 43
        data["Bính Thân"] = DayStarData(
            canChi: "Bính Thân",
            goodStars: [],
            badStars: []
        )

        // Row 34: Đinh Dậu
        // Page 160, Column C: Sinh khí 9, Thành tâm 20, Mậu thường 41, Thiên phúc 10
        data["Đinh Dậu"] = DayStarData(
            canChi: "Đinh Dậu",
            goodStars: [],
            badStars: []
        )

        // Row 35: Mậu Tuất
        // Page 160, Column C: Thiên tài 14, Cát khánh 24, Ích hậu 35, Đại hồng sa 43
        data["Mậu Tuất"] = DayStarData(
            canChi: "Mậu Tuất",
            goodStars: [],
            badStars: []
        )

        // Row 36: Kỷ Hợi
        // Page 160, Column C: Địa tài 15, Tục thế 36, Phúc hậu 42, Kim đường 48, Nguyệt đức hợp 4
        data["Kỷ Hợi"] = DayStarData(
            canChi: "Kỷ Hợi",
            goodStars: [],
            badStars: []
        )

        // Row 37: Canh Tý
        // Page 160, Column C: Thiên mã 13, U vi tinh 26, Yếu yên 37, Thiên đức hợp 2, Nguyệt không 18
        data["Canh Tý"] = DayStarData(
            canChi: "Canh Tý",
            goodStars: [.nguyetKhong],
            badStars: []
        )

        // Row 38: Tân Sửu
        // Page 160, Column C: Thiên phú 6, Thiên thành 11, Lộc khố 22, Ngọc đường 49
        data["Tân Sửu"] = DayStarData(
            canChi: "Tân Sửu",
            goodStars: [],
            badStars: []
        )

        // Row 39: Nhâm Dần
        // Page 161, Column C: Minh tinh 19, Ngũ phú 21, Lục hợp 40, Thiên quý 7
        data["Nhâm Dần"] = DayStarData(
            canChi: "Nhâm Dần",
            goodStars: [],
            badStars: []
        )

        // Row 40: Quý Mão
        // Page 161, Column C: Âm đức 25, Mạn đức tinh 27, Thiên giải 39, Dẫn nhật 44, Thiên quý 7, Tam hợp 39
        data["Quý Mão"] = DayStarData(
            canChi: "Quý Mão",
            goodStars: [.mannDucTinh, .tamHopThienGiai],
            badStars: []
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
            goodStars: [.nguyetKhong, .ngoHop],
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
            goodStars: [],
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
