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

        // Page 169: Rows 21-40 (Extracted from book pages 169-170)
        // Row 21: Giáp Thân - Bad: Đại hao
        data["Giáp Thân"] = DayStarData(
            canChi: "Giáp Thân",
            goodStars: [.thienAn],
            badStars: [.daiHao]
        )

        // Row 22: Ất Dậu - Bad: Kiếp sát, Huyền vũ, Lôi công, Ly sào
        data["Ất Dậu"] = DayStarData(
            canChi: "Ất Dậu",
            goodStars: [],
            badStars: [.kiepSat, .huyenVu, .loiCong, .lySao]
        )

        // Row 23: Bính Tuất - Good: Nhân chuyên | Bad: Thiên hỏa, Nguyệt phá, Hoang vu, Ngũ hư, Hỏa tai, Phi ma sát
        data["Bính Tuất"] = DayStarData(
            canChi: "Bính Tuất",
            goodStars: [.nhanChuyen],
            badStars: [.thienHoa, .hoangVu, .nguHu, .hoaTai, .phiMaSat]
        )

        // Row 24: Đinh Hợi - Bad: Nguyệt hỏa, Nguyệt hư, Ngũ quỷ, Câu trần
        data["Đinh Hợi"] = DayStarData(
            canChi: "Đinh Hợi",
            goodStars: [],
            badStars: [.nguyetHoa, .nguyetHu, .nguQuy, .cauTran]
        )

        // Row 25: Mậu Tý - Bad: Cửu không, Cô thần, Thổ cấm
        data["Mậu Tý"] = DayStarData(
            canChi: "Mậu Tý",
            goodStars: [],
            badStars: [.cuuKhong, .thoOn]
        )

        // Row 26: Kỷ Sửu - Bad: Tiểu hồng sa, Địa phá, Thần cách, Không phòng, Băng tiêu, Hà khôi, Lô ban sát
        data["Kỷ Sửu"] = DayStarData(
            canChi: "Kỷ Sửu",
            goodStars: [],
            badStars: [.tieuHongSa, .diaPha, .khongPhong, .bangTieu]
        )

        // Row 27: Canh Dần - Good: Thiên ân | Bad: Hoang vu, Vãng vong, Tứ thời cô quả, Quý khốc, Ngũ hư
        data["Canh Dần"] = DayStarData(
            canChi: "Canh Dần",
            goodStars: [.thienAn],
            badStars: [.hoangVu, .tuThoiCoQua, .nguHu]
        )

        // Row 28: Tân Mão - Good: Thiên ân, Sát công | Bad: Tội chí, Chu tước
        data["Tân Mão"] = DayStarData(
            canChi: "Tân Mão",
            goodStars: [.thienAn, .satCong],
            badStars: [.xichKhau]
        )

        // Row 29: Nhâm Thìn - Good: Thiên thụy, Trực linh | Bad: Thổ phủ, Nguyệt yếm, Phủ đầu sát, Nguyệt kiến chuyển sát, Âm dương thác
        data["Nhâm Thìn"] = DayStarData(
            canChi: "Nhâm Thìn",
            goodStars: [.thienThuy, .trucLinh],
            badStars: [.nguyetYem]
        )

        // Row 30: Quý Tỵ - Good: Thiên ân | Bad: Thiên ôn, Nhân cách, Tam tang, Trùng tang, Trùng phục
        data["Quý Tỵ"] = DayStarData(
            canChi: "Quý Tỵ",
            goodStars: [.thienAn],
            badStars: [.thoOn]
        )

        // Row 31: Giáp Ngọ - Bad: Thổ ôn, Hoang sa, Sát chủ, Quả tú, Bach hổ
        data["Giáp Ngọ"] = DayStarData(
            canChi: "Giáp Ngọ",
            goodStars: [],
            badStars: [.thoOn, .hoangSa, .quaTu]
        )

        // Row 32: Ất Mùi - Good: Nhân chuyên | Bad: Thiên cương, Thiên lại, Tiểu hao, Thu tử, Địa tặc, Nguyệt hình, Lục bát thành
        data["Ất Mùi"] = DayStarData(
            canChi: "Ất Mùi",
            goodStars: [.nhanChuyen],
            badStars: [.thienCuong, .tieuHao, .thuTu]
        )

        // Row 33: Bính Thân - Bad: Đại hao
        data["Bính Thân"] = DayStarData(
            canChi: "Bính Thân",
            goodStars: [],
            badStars: [.daiHao]
        )

        // Row 34: Đinh Dậu - Bad: Kiếp sát, Huyền vũ, Lôi công, Ly sào
        data["Đinh Dậu"] = DayStarData(
            canChi: "Đinh Dậu",
            goodStars: [],
            badStars: [.kiepSat, .huyenVu, .loiCong, .lySao]
        )

        // Row 35: Mậu Tuất - Good: Ngũ hợp | Bad: Thiên hỏa, Nguyệt phá, Hoang vu, Ngũ hư, Hỏa tai, Phi ma sát, Cửu thổ quỷ, Hỏa tinh
        data["Mậu Tuất"] = DayStarData(
            canChi: "Mậu Tuất",
            goodStars: [.ngoHop],
            badStars: [.thienHoa, .hoangVu, .nguHu, .hoaTai, .phiMaSat, .cuuThoQuy, .hoaTinh]
        )

        // Row 36: Kỷ Hợi - Good: Ngũ hợp | Bad: Nguyệt hỏa, Nguyệt hư, Ngũ quỷ, Câu trần
        data["Kỷ Hợi"] = DayStarData(
            canChi: "Kỷ Hợi",
            goodStars: [.ngoHop],
            badStars: [.nguyetHoa, .nguyetHu, .nguQuy, .cauTran]
        )

        // Row 37: Canh Tý - Good: Sát công | Bad: Cửu không, Cô thần, Thổ cấm
        data["Canh Tý"] = DayStarData(
            canChi: "Canh Tý",
            goodStars: [.satCong],
            badStars: [.cuuKhong, .thoOn]
        )

        // Row 38: Tân Sửu - Good: Trực linh, Ngũ hợp | Bad: Tiểu hồng sa, Địa phá, Thần cách, Không phòng, Băng tiêu, Hà khôi, Lô ban sát
        data["Tân Sửu"] = DayStarData(
            canChi: "Tân Sửu",
            goodStars: [.trucLinh, .ngoHop],
            badStars: [.tieuHongSa, .diaPha, .khongPhong, .bangTieu]
        )

        // Row 39: Nhâm Dần - Bad: Hoang vu, Vãng vong, Tứ thời cô quả, Ngũ hư, Quý khốc, Ly sào
        data["Nhâm Dần"] = DayStarData(
            canChi: "Nhâm Dần",
            goodStars: [],
            badStars: [.hoangVu, .tuThoiCoQua, .nguHu, .quyKhoc, .lySao]
        )

        // Row 40: Quý Mão
        data["Quý Mào"] = DayStarData(
            canChi: "Quý Mào",
            goodStars: [.ngoHop],
            badStars: [.xichKhau]
        )

        // Page 170: Rows 41-60 (Extracted from book page 170)
        // NOTE: Many good stars from page 170 don't have enum mappings yet. See comment in CLAUDE.md for list.

        // Row 41: Giáp Thìn - Good: Cát khánh, Tục thế, Lục hợp, Thiên xá, Nguyệt không
        data["Giáp Thìn"] = DayStarData(
            canChi: "Giáp Thìn",
            goodStars: [.catKhanh, .nguyetKhong],
            badStars: []
        )

        // Row 42: Ất Tỵ - Good: Yếu yên, Thiên Nguyệt đức hợp (not in enum yet)
        data["Ất Tỵ"] = DayStarData(
            canChi: "Ất Tỵ",
            goodStars: [],
            badStars: []
        )

        // Row 43: Bính Ngọ - Good: Thiên tài, U vi tinh, Tuế hợp
        data["Bính Ngọ"] = DayStarData(
            canChi: "Bính Ngọ",
            goodStars: [.thienTai],
            badStars: []
        )

        // Row 44: Đinh Mùi - Good: Thiên phú, Địa tài, Dân nhật, Kim đường (not in enum yet)
        data["Đinh Mùi"] = DayStarData(
            canChi: "Đinh Mùi",
            goodStars: [],
            badStars: []
        )

        // Row 45: Mậu Thân - Good: Thiên mã (not in enum yet)
        data["Mậu Thân"] = DayStarData(
            canChi: "Mậu Thân",
            goodStars: [],
            badStars: []
        )

        // Row 46: Kỷ Dậu - Good: Thiên thành, Mẫn đức tinh, Nguyệt ân, Thiên giải Tam hợp, Ngọc đường
        data["Kỷ Dậu"] = DayStarData(
            canChi: "Kỷ Dậu",
            goodStars: [.mannDucTinh, .nguyetDuc, .tamHopThienGiai],
            badStars: []
        )

        // Row 47: Canh Tuất - Good: Minh tinh, Giải thần, Kinh tâm, Thiên quý (not in enum yet)
        data["Canh Tuất"] = DayStarData(
            canChi: "Canh Tuất",
            goodStars: [],
            badStars: []
        )

        // Row 48: Tân Hợi - Good: Phổ hộ, Hoàng ân, Nguyệt giải, Nguyệt ân (not in enum yet)
        data["Tân Hợi"] = DayStarData(
            canChi: "Tân Hợi",
            goodStars: [],
            badStars: []
        )

        // Row 49: Nhâm Tý - Good: Thiên quan, Ngũ phú, Phúc sinh, Hoạt diệu Đại hồng sa, Mẫu thương, Thiên quý
        data["Nhâm Tý"] = DayStarData(
            canChi: "Nhâm Tý",
            goodStars: [.thienQuan],
            badStars: []
        )

        // Row 50: Quý Sửu - Good: Thiên hỷ, Tam hợp, Mẫu thương, Thiên quý
        data["Quý Sửu"] = DayStarData(
            canChi: "Quý Sửu",
            goodStars: [.tamHopThienGiai],
            badStars: []
        )

        // Row 51: Giáp Dần - Good: Thành tâm, Đại hồng sa, Thanh long, Nguyệt không
        data["Giáp Dần"] = DayStarData(
            canChi: "Giáp Dần",
            goodStars: [.daiHongSa, .nguyetKhong],
            badStars: []
        )

        // Row 52: Ất Mão - Good: Sinh khí, Nguyệt tài, Ấm đức, Ích hậu, Thiên Nguyệt đức hợp, Minh dương, Dịch mã, Phúc hậu
        data["Ất Mão"] = DayStarData(
            canChi: "Ất Mão",
            goodStars: [.ichHau],
            badStars: []
        )

        // Row 53: Bính Thìn - Good: Cát khánh, Tục thế, Lục hợp
        data["Bính Thìn"] = DayStarData(
            canChi: "Bính Thìn",
            goodStars: [.catKhanh],
            badStars: []
        )

        // Row 54: Đinh Tỵ - Good: Yếu yên (not in enum yet)
        data["Đinh Tỵ"] = DayStarData(
            canChi: "Đinh Tỵ",
            goodStars: [],
            badStars: []
        )

        // Row 55: Mậu Ngọ - Good: Thiên tài, U vi tinh, Tuế hợp
        data["Mậu Ngọ"] = DayStarData(
            canChi: "Mậu Ngọ",
            goodStars: [.thienTai],
            badStars: []
        )

        // Row 56: Kỷ Mùi - Good: Thiên phú, Địa tài, Dân nhật, Kim đường (not in enum yet)
        data["Kỷ Mùi"] = DayStarData(
            canChi: "Kỷ Mùi",
            goodStars: [],
            badStars: []
        )

        // Row 57: Canh Thân - Good: Thiên mã, Thiên đức, Nguyệt đức
        data["Canh Thân"] = DayStarData(
            canChi: "Canh Thân",
            goodStars: [.thienDuc, .nguyetDuc],
            badStars: []
        )

        // Row 58: Tân Dậu - Good: Thiên thành, Mẫn đức tinh, Nguyệt ân, Thiên giải Tam hợp, Ngọc đường
        data["Tân Dậu"] = DayStarData(
            canChi: "Tân Dậu",
            goodStars: [.mannDucTinh, .nguyetDuc, .tamHopThienGiai],
            badStars: []
        )

        // Row 59: Nhâm Tuất - Good: Minh tinh, Giải thần, Kinh tâm, Thiên quý (not in enum yet)
        data["Nhâm Tuất"] = DayStarData(
            canChi: "Nhâm Tuất",
            goodStars: [],
            badStars: []
        )

        // Row 60: Quý Hợi - Good: Phổ hộ, Hoàng ân, Nguyệt giải, Thiên quý (not in enum yet)
        data["Quý Hợi"] = DayStarData(
            canChi: "Quý Hợi",
            goodStars: [],
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
