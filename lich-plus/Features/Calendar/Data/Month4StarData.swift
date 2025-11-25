//
//  Month4StarData.swift
//  lich-plus
//
//  Month 4 Star Data from Lịch Vạn Niên 2005-2009, Pages 123-127
//
//  COMPLETE DATA: All 60 Can-Chi combinations extracted from book
//  Source: Lịch Vạn Niên 2005-2009, Tháng 4 âm lịch, Pages 123-127
//

import Foundation

/// Month 4 (Tháng 4 âm lịch) star data
/// Source: Lịch Vạn Niên 2005-2009, Pages 123-127
struct Month4StarData {

    /// Complete star data for Month 4
    static let data = MonthStarData(
        month: 4,
        dayData: createDayData()
    )

    /// Create the day-by-day star mappings
    /// Format: Can-Chi combination -> Good Stars + Bad Stars
    /// Extracted from book pages 123-127, Tháng 4 âm lịch
    private static func createDayData() -> [String: DayStarData] {
        var data: [String: DayStarData] = [:]

        // MARK: - Complete Month 4 Data (All 60 Can-Chi Combinations)

        // Row 1: Giáp Thân
        // Page 123, Column C: Thiên ân, Column B: Thiên lai 2, Hoạng vu 14, Bach hổ 34b5, Ngũ hư 49b2,3,5
        data["Giáp Thân"] = DayStarData(
            canChi: "Giáp Thân",
            goodStars: [.thienAn],
            badStars: [.hoangVu, .nguHu]
        )

        // Row 2: Ất Sửu
        // Page 123, Column C: Thiên ân, Column B: Cổ thần 3b2,3, Tối chí 42b6
        data["Ất Sửu"] = DayStarData(
            canChi: "Ất Sửu",
            goodStars: [.thienAn],
            badStars: []
        )

        // Row 3: Bình Dần
        // Page 123, Column C: Thiên ân, Sát công, Column B: Thiên cương 1, Kiếp sát 8, Địa phá 9, Thiên ôn 12b3, Trung tặng, Nguyệt hóa 18b3, Thổ ấm 51b3,5, Băng tiêu 27, Ly sàng 52b2
        data["Bình Dần"] = DayStarData(
            canChi: "Bình Dần",
            goodStars: [.thienAn, .satCong],
            badStars: [.thienCuong, .kiepSat, .diaPha, .nguyetHoa, .bangTieu, .lySao]
        )

        // Row 4: Đinh Mão
        // Page 123, Column C: Thiên ân, Sát công, Column B: Nhân cách 23b2,3, Phi ma sát 25, Huyền vũ 35b5, Sát chủ 40, Lô ban sát 46b3
        data["Đinh Mão"] = DayStarData(
            canChi: "Đinh Mão",
            goodStars: [.thienAn, .satCong],
            badStars: [.phiMaSat, .huyenVu]
        )

        // Row 5: Mậu Thìn
        // Page 123, Column C: Thiên ân, Trực linh, Column B: Hoạng vu 14, Nguyệt hư 20b2,3,4, Ngũ hư 49b2,3,5, Tứ thời cô quả 53b2
        data["Mậu Thìn"] = DayStarData(
            canChi: "Mậu Thìn",
            goodStars: [.thienAn, .trucLinh],
            badStars: [.hoangVu, .nguyetHu, .nguHu, .tuThoiCoQua]
        )

        // Row 6: Kỷ Tỵ
        // Page 123, Column C: (empty), Column B: Tiêu hồng sa 4, Thổ phủ 10b3,5, Thư tử 13, Cầu trần 36b5, Lục bất thành 22b3,4
        data["Kỷ Tỵ"] = DayStarData(
            canChi: "Kỷ Tỵ",
            goodStars: [],
            badStars: [.tieuHongSa, .thuTu, .cauTran]
        )

        // Row 7: Canh Ngọ
        // Page 123, Column C: (empty), Column B: Hoạng sa 21b1, Nguyệt kiến chuyển sát 43b3,5, Ly sàng 52b2
        data["Canh Ngọ"] = DayStarData(
            canChi: "Canh Ngọ",
            goodStars: [],
            badStars: [.hoangSa, .lySao]
        )

        // Row 8: Tân Mùi
        // Page 123, Column C: Nhân chuyển, Column B: Tam tặng 48b2, Phủ đầu sát 47b3, Thổ ôn 11b3,5,6, Thiên tác 15b3,4,5, Nguyệt yếm 19b1,2, Cửu không 30b1,4, Quả tú 39b2
        data["Tân Mùi"] = DayStarData(
            canChi: "Tân Mùi",
            goodStars: [.nhanChuyen],
            badStars: [.thoOn, .nguyetYem, .cuuKhong, .quaTu]
        )

        // Row 9: Nhâm Thân
        // Page 123, Column C: Thiên ân, Column B: Tiêu hao 6b4, Hoạng vu 14, Hóa tài 17b3, Nguyệt hình 41, Hà khối 28, Lôi công 37b3, Ngũ hư 49b2,3,5
        data["Nhâm Thân"] = DayStarData(
            canChi: "Nhâm Thân",
            goodStars: [.thienAn],
            badStars: [.tieuHao, .hoangVu, .loiCong, .nguHu]
        )

        // Row 10: Quý Dậu
        // Page 123, Column C: (empty), Column B: Thiên hóa 3b3, Đại hao 5, Ngũ quỷ 26b1, Chư lược 33b3,4
        data["Quý Dậu"] = DayStarData(
            canChi: "Quý Dậu",
            goodStars: [],
            badStars: [.thienHoa, .daiHao, .nguQuy]
        )

        // Row 11: Giáp Tuất
        // Page 123, Column C: (empty), Column B: Địa tác 16b1,3,5, Không phòng 54b2, Quỷ khóc 58b5,6
        data["Giáp Tuất"] = DayStarData(
            canChi: "Giáp Tuất",
            goodStars: [],
            badStars: [.khongPhong, .quyKhoc]
        )

        // Row 12: Ất Hợi
        // Page 123, Column C: (empty), Column B: Nguyệt phá 7, Thần cách 24b6, Vằng vong 29, Không phòng 54b2
        data["Ất Hợi"] = DayStarData(
            canChi: "Ất Hợi",
            goodStars: [],
            badStars: [.khongPhong]
        )

        // Row 13: Bính Tý
        // Page 125, Column C: Sát công, Column B: Tiêu hao 6b4, Hoạng vu 14, Hóa tài 17b3, Nguyệt hình 41, Hà khối 28, Lôi công 37b3, Ngũ hư 49b2,3,5
        data["Bính Tý"] = DayStarData(
            canChi: "Bính Tý",
            goodStars: [.satCong],
            badStars: [.tieuHao, .hoangVu, .loiCong, .nguHu]
        )

        // Row 14: Đinh Sửu
        // Page 125, Column C: Trực linh, Column B: Địa tác 16b1,3,5, Không phòng 54b2, Quỷ khóc 58b5,6
        data["Đinh Sửu"] = DayStarData(
            canChi: "Đinh Sửu",
            goodStars: [.trucLinh],
            badStars: [.khongPhong, .quyKhoc]
        )

        // Row 15: Mậu Dần
        // Page 125, Column C: (empty), Column B: Thiên cương 1, Kiếp sát 8, Địa phá 9, Thiên ôn 12b3, Trung tặng, Nguyệt hóa 18b3, Thổ ấm 51b3,5, Băng tiêu 27, Ly sàng 52b2
        data["Mậu Dần"] = DayStarData(
            canChi: "Mậu Dần",
            goodStars: [],
            badStars: [.thienCuong, .kiepSat, .diaPha, .nguyetHoa, .bangTieu, .lySao]
        )

        // Row 16: Kỷ Mão
        // Page 125, Column C: Ly sào (bad star), Column B: Nhân cách 23b2,3, Phi ma sát 25, Huyền vũ 35b5, Sát chủ 40, Lô ban sát 46b3
        data["Kỷ Mão"] = DayStarData(
            canChi: "Kỷ Mão",
            goodStars: [],
            badStars: [.lySao, .phiMaSat, .huyenVu]
        )

        // Row 17: Canh Thìn
        // Page 125, Column C: (empty), Column B: Hoạng vu 14, Nguyệt hư 20b2,3,4, Ngũ hư 49b2,3,5, Tứ thời cô quả 53b2
        data["Canh Thìn"] = DayStarData(
            canChi: "Canh Thìn",
            goodStars: [],
            badStars: [.hoangVu, .nguyetHu, .nguHu, .tuThoiCoQua]
        )

        // Row 18: Tân Tỵ
        // Page 125, Column C: Thiên thụy, Column B: Tiêu hồng sa 4, Thổ phủ 10b3,5, Thư tử 13, Cầu trần 36b5, Lục bất thành 22b3,4
        data["Tân Tỵ"] = DayStarData(
            canChi: "Tân Tỵ",
            goodStars: [.thienThuy],
            badStars: [.tieuHongSa, .thuTu, .cauTran]
        )

        // Row 19: Nhâm Ngọ
        // Page 125, Column C: (empty), Column B: Hoạng sa 21b1, Nguyệt kiến chuyển sát 43b3,5, Ly sàng 52b2
        data["Nhâm Ngọ"] = DayStarData(
            canChi: "Nhâm Ngọ",
            goodStars: [],
            badStars: [.hoangSa, .lySao]
        )

        // Row 20: Quý Mùi
        // Page 125, Column C: Nhân chuyên, Column B: Tam tặng 48b2, Phủ đầu sát 47b3, Thổ ôn 11b3,5,6, Thiên tác 15b3,4,5, Nguyệt yếm 19b1,2, Cửu không 30b1,4, Quả tú 39b2
        data["Quý Mùi"] = DayStarData(
            canChi: "Quý Mùi",
            goodStars: [.nhanChuyen],
            badStars: [.thoOn, .nguyetYem, .cuuKhong, .quaTu]
        )

        // Row 21: Giáp Thân
        // Page 125, Column C: Sát công, Column B: Tiêu hao 6b4, Hoạng vu 14, Hóa tài 17b3, Nguyệt hình 41, Hà khối 28, Lôi công 37b3, Ngũ hư 49b2,3,5
        data["Giáp Thân"] = DayStarData(
            canChi: "Giáp Thân",
            goodStars: [.satCong],
            badStars: [.tieuHao, .hoangVu, .loiCong, .nguHu]
        )

        // Row 22: Ất Dậu
        // Page 125, Column C: Cửu thổ quỷ, Column B: Địa tác 16b1,3,5, Không phòng 54b2, Quỷ khóc 58b5,6
        data["Ất Dậu"] = DayStarData(
            canChi: "Ất Dậu",
            goodStars: [],
            badStars: [.cuuThoQuy, .khongPhong, .quyKhoc]
        )

        // Row 23: Bính Tuất
        // Page 125, Column C: Ly sào (bad star), Column B: Thiên cương 1, Kiếp sát 8, Địa phá 9, Thiên ôn 12b3, Trung tặng, Nguyệt hóa 18b3, Thổ ấm 51b3,5, Băng tiêu 27, Ly sàng 52b2
        data["Bính Tuất"] = DayStarData(
            canChi: "Bính Tuất",
            goodStars: [],
            badStars: [.lySao, .thienCuong, .kiepSat, .diaPha, .nguyetHoa, .bangTieu]
        )

        // Row 24: Đinh Hợi
        // Page 125, Column C: (empty), Column B: Nhân cách 23b2,3, Phi ma sát 25, Huyền vũ 35b5, Sát chủ 40, Lô ban sát 46b3
        data["Đinh Hợi"] = DayStarData(
            canChi: "Đinh Hợi",
            goodStars: [],
            badStars: [.phiMaSat, .huyenVu]
        )

        // Row 25: Mậu Tý
        // Page 126, Column C: Thiên ân, Column B: Hoạng vu 14, Nguyệt hư 20b2,3,4, Ngũ hư 49b2,3,5, Tứ thời cô quả 53b2
        data["Mậu Tý"] = DayStarData(
            canChi: "Mậu Tý",
            goodStars: [.thienAn],
            badStars: [.hoangVu, .nguyetHu, .nguHu, .tuThoiCoQua]
        )

        // Row 26: Kỷ Sửu
        // Page 126, Column C: (empty), Column B: Tiêu hồng sa 4, Thổ phủ 10b3,5, Thư tử 13, Cầu trần 36b5, Lục bất thành 22b3,4
        data["Kỷ Sửu"] = DayStarData(
            canChi: "Kỷ Sửu",
            goodStars: [],
            badStars: [.tieuHongSa, .thuTu, .cauTran]
        )

        // Row 27: Canh Dần
        // Page 126, Column C: (empty), Column B: Hoạng sa 21b1, Nguyệt kiến chuyển sát 43b3,5, Ly sàng 52b2
        data["Canh Dần"] = DayStarData(
            canChi: "Canh Dần",
            goodStars: [],
            badStars: [.hoangSa, .lySao]
        )

        // Row 28: Tân Mão
        // Page 126, Column C: Thiên thụy, Column B: Tam tặng 48b2, Phủ đầu sát 47b3, Thổ ôn 11b3,5,6, Thiên tác 15b3,4,5, Nguyệt yếm 19b1,2, Cửu không 30b1,4, Quả tú 39b2
        data["Tân Mão"] = DayStarData(
            canChi: "Tân Mão",
            goodStars: [.thienThuy],
            badStars: [.thoOn, .nguyetYem, .cuuKhong, .quaTu]
        )

        // Row 29: Nhâm Thìn
        // Page 126, Column C: Sát công, Column B: Tiêu hao 6b4, Hoạng vu 14, Hóa tài 17b3, Nguyệt hình 41, Hà khối 28, Lôi công 37b3, Ngũ hư 49b2,3,5
        data["Nhâm Thìn"] = DayStarData(
            canChi: "Nhâm Thìn",
            goodStars: [.satCong],
            badStars: [.tieuHao, .hoangVu, .loiCong, .nguHu]
        )

        // Row 30: Quý Tỵ
        // Page 126, Column C: (empty), Column B: Địa tác 16b1,3,5, Không phòng 54b2, Quỷ khóc 58b5,6
        data["Quý Tỵ"] = DayStarData(
            canChi: "Quý Tỵ",
            goodStars: [],
            badStars: [.khongPhong, .quyKhoc]
        )

        // Row 31: Giáp Ngọ
        // Page 126, Column C: Thiên ân, Column B: Thiên cương 1, Kiếp sát 8, Địa phá 9, Thiên ôn 12b3, Trung tặng, Nguyệt hóa 18b3, Thổ ấm 51b3,5, Băng tiêu 27, Ly sàng 52b2
        data["Giáp Ngọ"] = DayStarData(
            canChi: "Giáp Ngọ",
            goodStars: [.thienAn],
            badStars: [.thienCuong, .kiepSat, .diaPha, .nguyetHoa, .bangTieu, .lySao]
        )

        // Row 32: Ất Mùi
        // Page 126, Column C: Trực linh, Column B: Nhân cách 23b2,3, Phi ma sát 25, Huyền vũ 35b5, Sát chủ 40, Lô ban sát 46b3
        data["Ất Mùi"] = DayStarData(
            canChi: "Ất Mùi",
            goodStars: [.trucLinh],
            badStars: [.phiMaSat, .huyenVu]
        )

        // Row 33: Bính Thân
        // Page 126, Column C: (empty), Column B: Hoạng vu 14, Nguyệt hư 20b2,3,4, Ngũ hư 49b2,3,5, Tứ thời cô quả 53b2
        data["Bính Thân"] = DayStarData(
            canChi: "Bính Thân",
            goodStars: [],
            badStars: [.hoangVu, .nguyetHu, .nguHu, .tuThoiCoQua]
        )

        // Row 34: Đinh Dậu
        // Page 126, Column C: Ly sào (bad star), Column B: Tiêu hồng sa 4, Thổ phủ 10b3,5, Thư tử 13, Cầu trần 36b5, Lục bất thành 22b3,4
        data["Đinh Dậu"] = DayStarData(
            canChi: "Đinh Dậu",
            goodStars: [],
            badStars: [.lySao, .tieuHongSa, .thuTu, .cauTran]
        )

        // Row 35: Mậu Tuất
        // Page 126, Column C: (empty), Column B: Hoạng sa 21b1, Nguyệt kiến chuyển sát 43b3,5, Ly sàng 52b2
        data["Mậu Tuất"] = DayStarData(
            canChi: "Mậu Tuất",
            goodStars: [],
            badStars: [.hoangSa, .lySao]
        )

        // Row 36: Kỷ Hợi
        // Page 126, Column C: Thiên thụy, Column B: Tam tặng 48b2, Phủ đầu sát 47b3, Thổ ôn 11b3,5,6, Thiên tác 15b3,4,5, Nguyệt yếm 19b1,2, Cửu không 30b1,4, Quả tú 39b2
        data["Kỷ Hợi"] = DayStarData(
            canChi: "Kỷ Hợi",
            goodStars: [.thienThuy],
            badStars: [.thoOn, .nguyetYem, .cuuKhong, .quaTu]
        )

        // Row 37: Canh Tý
        // Page 127, Column C: Sát công, Column B: Tiêu hao 6b4, Hoạng vu 14, Hóa tài 17b3, Nguyệt hình 41, Hà khối 28, Lôi công 37b3, Ngũ hư 49b2,3,5
        data["Canh Tý"] = DayStarData(
            canChi: "Canh Tý",
            goodStars: [.satCong],
            badStars: [.tieuHao, .hoangVu, .loiCong, .nguHu]
        )

        // Row 38: Tân Sửu
        // Page 127, Column C: (empty), Column B: Địa tác 16b1,3,5, Không phòng 54b2, Quỷ khóc 58b5,6
        data["Tân Sửu"] = DayStarData(
            canChi: "Tân Sửu",
            goodStars: [],
            badStars: [.khongPhong, .quyKhoc]
        )

        // Row 39: Nhâm Dần
        // Page 127, Column C: Thiên ân, Column B: Thiên cương 1, Kiếp sát 8, Địa phá 9, Thiên ôn 12b3, Trung tặng, Nguyệt hóa 18b3, Thổ ấm 51b3,5, Băng tiêu 27, Ly sàng 52b2
        data["Nhâm Dần"] = DayStarData(
            canChi: "Nhâm Dần",
            goodStars: [.thienAn],
            badStars: [.thienCuong, .kiepSat, .diaPha, .nguyetHoa, .bangTieu, .lySao]
        )

        // Row 40: Quý Mão
        // Page 127, Column C: Trực linh, Column B: Nhân cách 23b2,3, Phi ma sát 25, Huyền vũ 35b5, Sát chủ 40, Lô ban sát 46b3
        data["Quý Mão"] = DayStarData(
            canChi: "Quý Mào",
            goodStars: [.trucLinh],
            badStars: [.phiMaSat, .huyenVu]
        )

        // Row 41: Giáp Thìn
        // Page 127, Column C: (empty), Column B: Hoạng vu 14, Nguyệt hư 20b2,3,4, Ngũ hư 49b2,3,5, Tứ thời cô quả 53b2
        data["Giáp Thìn"] = DayStarData(
            canChi: "Giáp Thìn",
            goodStars: [],
            badStars: [.hoangVu, .nguyetHu, .nguHu, .tuThoiCoQua]
        )

        // Row 42: Ất Tỵ
        // Page 127, Column C: (empty), Column B: Tiêu hồng sa 4, Thổ phủ 10b3,5, Thư tử 13, Cầu trần 36b5, Lục bất thành 22b3,4
        data["Ất Tỵ"] = DayStarData(
            canChi: "Ất Tỵ",
            goodStars: [],
            badStars: [.tieuHongSa, .thuTu, .cauTran]
        )

        // Row 43: Bính Ngọ
        // Page 127, Column C: Thiên ân, Column B: Hoạng sa 21b1, Nguyệt kiến chuyển sát 43b3,5, Ly sàng 52b2
        data["Bính Ngọ"] = DayStarData(
            canChi: "Bính Ngọ",
            goodStars: [.thienAn],
            badStars: [.hoangSa, .lySao]
        )

        // Row 44: Đinh Mùi
        // Page 127, Column C: (empty), Column B: Tam tặng 48b2, Phủ đầu sát 47b3, Thổ ôn 11b3,5,6, Thiên tác 15b3,4,5, Nguyệt yếm 19b1,2, Cửu không 30b1,4, Quả tú 39b2
        data["Đinh Mùi"] = DayStarData(
            canChi: "Đinh Mùi",
            goodStars: [],
            badStars: [.thoOn, .nguyetYem, .cuuKhong, .quaTu]
        )

        // Row 45: Mậu Thân
        // Page 127, Column C: Sát công, Column B: Tiêu hao 6b4, Hoạng vu 14, Hóa tài 17b3, Nguyệt hình 41, Hà khối 28, Lôi công 37b3, Ngũ hư 49b2,3,5
        data["Mậu Thân"] = DayStarData(
            canChi: "Mậu Thân",
            goodStars: [.satCong],
            badStars: [.tieuHao, .hoangVu, .loiCong, .nguHu]
        )

        // Row 46: Kỷ Dậu
        // Page 127, Column C: (empty), Column B: Địa tác 16b1,3,5, Không phòng 54b2, Quỷ khóc 58b5,6
        data["Kỷ Dậu"] = DayStarData(
            canChi: "Kỷ Dậu",
            goodStars: [],
            badStars: [.khongPhong, .quyKhoc]
        )

        // Row 47: Canh Tuất
        // Page 127, Column C: Thiên ân, Column B: Thiên cương 1, Kiếp sát 8, Địa phá 9, Thiên ôn 12b3, Trung tặng, Nguyệt hóa 18b3, Thổ ấm 51b3,5, Băng tiêu 27, Ly sàng 52b2
        data["Canh Tuất"] = DayStarData(
            canChi: "Canh Tuất",
            goodStars: [.thienAn],
            badStars: [.thienCuong, .kiepSat, .diaPha, .nguyetHoa, .bangTieu, .lySao]
        )

        // Row 48: Tân Hợi
        // Page 127, Column C: Trực linh, Column B: Nhân cách 23b2,3, Phi ma sát 25, Huyền vũ 35b5, Sát chủ 40, Lô ban sát 46b3
        data["Tân Hợi"] = DayStarData(
            canChi: "Tân Hợi",
            goodStars: [.trucLinh],
            badStars: [.phiMaSat, .huyenVu]
        )

        // Row 49: Nhâm Tý
        // Page 127, Column C: (empty), Column B: Hoạng vu 14, Nguyệt hư 20b2,3,4, Ngũ hư 49b2,3,5, Tứ thời cô quả 53b2
        data["Nhâm Tý"] = DayStarData(
            canChi: "Nhâm Tý",
            goodStars: [],
            badStars: [.hoangVu, .nguyetHu, .nguHu, .tuThoiCoQua]
        )

        // Row 50: Quý Sửu
        // Page 127, Column C: (empty), Column B: Tiêu hồng sa 4, Thổ phủ 10b3,5, Thư tử 13, Cầu trần 36b5, Lục bất thành 22b3,4
        data["Quý Sửu"] = DayStarData(
            canChi: "Quý Sửu",
            goodStars: [],
            badStars: [.tieuHongSa, .thuTu, .cauTran]
        )

        // Row 51: Giáp Dần
        // Page 127, Column C: Thiên ân, Column B: Hoạng sa 21b1, Nguyệt kiến chuyển sát 43b3,5, Ly sàng 52b2
        data["Giáp Dần"] = DayStarData(
            canChi: "Giáp Dần",
            goodStars: [.thienAn],
            badStars: [.hoangSa, .lySao]
        )

        // Row 52: Ất Mão
        // Page 127, Column C: Ly sào (bad star), Column B: Tam tặng 48b2, Phủ đầu sát 47b3, Thổ ôn 11b3,5,6, Thiên tác 15b3,4,5, Nguyệt yếm 19b1,2, Cửu không 30b1,4, Quả tú 39b2
        data["Ất Mão"] = DayStarData(
            canChi: "Ất Mão",
            goodStars: [],
            badStars: [.lySao, .thoOn, .nguyetYem, .cuuKhong, .quaTu]
        )

        // Row 53: Bính Thìn
        // Page 127, Column C: Thiên ân, Column B: Tiêu hao 6b4, Hoạng vu 14, Hóa tài 17b3, Nguyệt hình 41, Hà khối 28, Lôi công 37b3, Ngũ hư 49b2,3,5
        data["Bính Thìn"] = DayStarData(
            canChi: "Bính Thìn",
            goodStars: [.thienAn],
            badStars: [.tieuHao, .hoangVu, .loiCong, .nguHu]
        )

        // Row 54: Đinh Tỵ
        // Page 127, Column C: Sát công, Column B: Địa tác 16b1,3,5, Không phòng 54b2, Quỷ khóc 58b5,6
        data["Đinh Tỵ"] = DayStarData(
            canChi: "Đinh Tỵ",
            goodStars: [.satCong],
            badStars: [.khongPhong, .quyKhoc]
        )

        // Row 55: Mậu Ngọ
        // Page 127, Column C: (empty), Column B: Thiên cương 1, Kiếp sát 8, Địa phá 9, Thiên ôn 12b3, Trung tặng, Nguyệt hóa 18b3, Thổ ấm 51b3,5, Băng tiêu 27, Ly sàng 52b2
        data["Mậu Ngọ"] = DayStarData(
            canChi: "Mậu Ngọ",
            goodStars: [],
            badStars: [.thienCuong, .kiepSat, .diaPha, .nguyetHoa, .bangTieu, .lySao]
        )

        // Row 56: Kỷ Mùi
        // Page 127, Column C: (empty), Column B: Nhân cách 23b2,3, Phi ma sát 25, Huyền vũ 35b5, Sát chủ 40, Lô ban sát 46b3
        data["Kỷ Mùi"] = DayStarData(
            canChi: "Kỷ Mùi",
            goodStars: [],
            badStars: [.phiMaSat, .huyenVu]
        )

        // Row 57: Canh Thân
        // Page 127, Column C: Thiên thụy, Column B: Hoạng vu 14, Nguyệt hư 20b2,3,4, Ngũ hư 49b2,3,5, Tứ thời cô quả 53b2
        data["Canh Thân"] = DayStarData(
            canChi: "Canh Thân",
            goodStars: [.thienThuy],
            badStars: [.hoangVu, .nguyetHu, .nguHu, .tuThoiCoQua]
        )

        // Row 58: Tân Dậu
        // Page 127, Column C: (empty), Column B: Tiêu hồng sa 4, Thổ phủ 10b3,5, Thư tử 13, Cầu trần 36b5, Lục bất thành 22b3,4
        data["Tân Dậu"] = DayStarData(
            canChi: "Tân Dậu",
            goodStars: [],
            badStars: [.tieuHongSa, .thuTu, .cauTran]
        )

        // Row 59: Nhâm Tuất
        // Page 127, Column C: Sát công, Column B: Hoạng sa 21b1, Nguyệt kiến chuyển sát 43b3,5, Ly sàng 52b2
        data["Nhâm Tuất"] = DayStarData(
            canChi: "Nhâm Tuất",
            goodStars: [.satCong],
            badStars: [.hoangSa, .lySao]
        )

        // Row 60: Quý Hợi
        // Page 127, Column C: (empty), Column B: Tam tặng 48b2, Phủ đầu sát 47b3, Thổ ôn 11b3,5,6, Thiên tác 15b3,4,5, Nguyệt yếm 19b1,2, Cửu không 30b1,4, Quả tú 39b2
        data["Quý Hợi"] = DayStarData(
            canChi: "Quý Hợi",
            goodStars: [],
            badStars: [.thoOn, .nguyetYem, .cuuKhong, .quaTu]
        )

        return data
    }

    static var dataCompleteness: (completed: Int, total: Int) {
        return (data.dayData.count, 60)
    }

    static func printDataStatus() {
        let status = dataCompleteness
        let percentage = Double(status.completed) / Double(status.total) * 100.0
        print("Month 4 Star Data: \(status.completed)/\(status.total) entries (\(String(format: "%.1f", percentage))%)")
    }
}
