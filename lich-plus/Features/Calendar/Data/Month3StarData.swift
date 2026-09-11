//
//  Month3StarData.swift
//  lich-plus
//
//  Month 3 Star Data from Lịch Vạn Niên 2005-2009, Pages 116-121
//
//  COMPLETE DATA: All 60 Can-Chi combinations extracted from book
//  Source: Lịch Vạn Niên 2005-2009, Tháng 3 âm lịch, Pages 116-121
//

import Foundation

/// Month 3 (Tháng 3 âm lịch) star data
/// Source: Lịch Vạn Niên 2005-2009, Pages 116-121
struct Month3StarData {

    static let data = MonthStarData(month: 3, dayData: createDayData())

    private static func createDayData() -> [String: DayStarData] {
        var data: [String: DayStarData] = [:]

        // MARK: - Complete Month 3 Data (All 60 Can-Chi Combinations)
        // Extracted from book pages 116-121, columns B (Sao xấu) and C (Sao tốt)

        // Row 1: Giáp Tý
        data["Giáp Tý"] = DayStarData(canChi: "Giáp Tý", goodStars: [.thienAn], badStars: [.hoangSa, .khongPhong])

        // Row 2: Ất Sửu
        data["Ất Sửu"] = DayStarData(canChi: "Ất Sửu", goodStars: [.thienAn, .satCong], badStars: [.tuThoiCoQua, .tieuHongSa, .diaPha, .hoangVu, .huyenVu, .bangTieu, .nguHu])

        // Row 3: Bính Dần
        data["Bính Dần"] = DayStarData(canChi: "Bính Dần", goodStars: [.thienAn, .trucLinh], badStars: [.hoaTai])

        // Row 4: Đinh Mão
        data["Đinh Mão"] = DayStarData(canChi: "Đinh Mão", goodStars: [], badStars: [.nguyetHoa, .cauTran])

        // Row 5: Mậu Thìn
        data["Mậu Thìn"] = DayStarData(canChi: "Mậu Thìn", goodStars: [], badStars: [.khongPhong, .nguHu, .lySao])

        // Row 6: Kỷ Tỵ
        data["Kỷ Tỵ"] = DayStarData(canChi: "Kỷ Tỵ", goodStars: [.nhanChuyen], badStars: [.kiepSat, .hoangVu, .loiCong, .khongPhong, .lySao])

        // Row 7: Canh Ngọ
        data["Canh Ngọ"] = DayStarData(canChi: "Canh Ngọ", goodStars: [], badStars: [.thienHoa, .thoOn, .phiMaSat, .quaTu])

        // Row 8: Tân Mùi
        data["Tân Mùi"] = DayStarData(canChi: "Tân Mùi", goodStars: [], badStars: [.thienCuong, .tieuHao, .nguyetHu])

        // Row 9: Nhâm Thân
        data["Nhâm Thân"] = DayStarData(canChi: "Nhâm Thân", goodStars: [], badStars: [.daiHao, .nguyetYem, .hoaTinh])

        // Row 10: Quý Dậu
        data["Quý Dậu"] = DayStarData(canChi: "Quý Dậu", goodStars: [], badStars: [.hoangVu, .lySao])

        // Row 11: Giáp Tuất
        data["Giáp Tuất"] = DayStarData(canChi: "Giáp Tuất", goodStars: [.satCong], badStars: [.cuuKhong, .quyKhoc])

        // Row 12: Ất Hợi
        data["Ất Hợi"] = DayStarData(canChi: "Ất Hợi", goodStars: [.trucLinh], badStars: [.thuTu])

        // Row 13: Bính Tý
        data["Bính Tý"] = DayStarData(canChi: "Bính Tý", goodStars: [], badStars: [.hoangSa, .khongPhong])

        // Row 14: Đinh Sửu
        data["Đinh Sửu"] = DayStarData(canChi: "Đinh Sửu", goodStars: [], badStars: [.tuThoiCoQua, .tieuHongSa, .diaPha, .hoangVu, .huyenVu, .bangTieu, .nguHu, .cuuThoQuy])

        // Row 15: Mậu Dần
        data["Mậu Dần"] = DayStarData(canChi: "Mậu Dần", goodStars: [.thienThuy, .nhanChuyen], badStars: [.hoaTai, .lySao])

        // Row 16: Kỷ Mão
        data["Kỷ Mão"] = DayStarData(canChi: "Kỷ Mão", goodStars: [.thienThuy, .thienAn], badStars: [.nguyetHoa, .cauTran])

        // Row 17: Canh Thìn
        data["Canh Thìn"] = DayStarData(canChi: "Canh Thìn", goodStars: [.thienAn], badStars: [.khongPhong, .nguHu])

        // Row 18: Tân Tỵ
        data["Tân Tỵ"] = DayStarData(canChi: "Tân Tỵ", goodStars: [.thienThuy, .thienAn], badStars: [.kiepSat, .hoangVu, .loiCong, .nguHu, .khongPhong, .hoaTinh, .lySao])

        // Row 19: Nhâm Ngọ
        data["Nhâm Ngọ"] = DayStarData(canChi: "Nhâm Ngọ", goodStars: [.thienAn], badStars: [.thienHoa, .thoOn, .phiMaSat, .quaTu])

        // Row 20: Quý Mùi
        data["Quý Mùi"] = DayStarData(canChi: "Quý Mùi", goodStars: [.thienAn, .satCong], badStars: [.thienCuong, .tieuHao, .nguyetHu])

        // Row 21: Giáp Thân
        data["Giáp Thân"] = DayStarData(canChi: "Giáp Thân", goodStars: [.trucLinh], badStars: [.daiHao, .nguyetYem])

        // Row 22: Ất Dậu
        data["Ất Dậu"] = DayStarData(canChi: "Ất Dậu", goodStars: [], badStars: [.cuuThoQuy, .hoangVu, .nguHu, .lySao])

        // Row 23: Bính Tuất
        data["Bính Tuất"] = DayStarData(canChi: "Bính Tuất", goodStars: [], badStars: [.cuuKhong, .quyKhoc])

        // Row 24: Đinh Hợi
        data["Đinh Hợi"] = DayStarData(canChi: "Đinh Hợi", goodStars: [.nhanChuyen], badStars: [.thuTu])

        // Row 25: Mậu Tý
        data["Mậu Tý"] = DayStarData(canChi: "Mậu Tý", goodStars: [], badStars: [.lySao, .hoangSa, .khongPhong])

        // Row 26: Kỷ Sửu
        data["Kỷ Sửu"] = DayStarData(canChi: "Kỷ Sửu", goodStars: [.thienThuy], badStars: [.tuThoiCoQua, .tieuHongSa, .diaPha, .hoangVu, .huyenVu, .bangTieu, .nguHu, .lySao])

        // Row 27: Canh Dần
        data["Canh Dần"] = DayStarData(canChi: "Canh Dần", goodStars: [.thienThuy], badStars: [.hoaTinh, .hoaTai])

        // Row 28: Tân Mão
        data["Tân Mão"] = DayStarData(canChi: "Tân Mão", goodStars: [], badStars: [.nguyetHoa, .cauTran, .lySao])

        // Row 29: Nhâm Thìn
        data["Nhâm Thìn"] = DayStarData(canChi: "Nhâm Thìn", goodStars: [.satCong], badStars: [.nguQuy, .khongPhong])

        // Row 30: Quý Tỵ
        data["Quý Tỵ"] = DayStarData(canChi: "Quý Tỵ", goodStars: [.trucLinh], badStars: [.cuuThoQuy, .lySao, .kiepSat, .hoangVu, .loiCong, .nguHu, .khongPhong])

        // Row 31: Giáp Ngọ
        data["Giáp Ngọ"] = DayStarData(canChi: "Giáp Ngọ", goodStars: [], badStars: [.cuuThoQuy, .thienHoa, .thoOn, .phiMaSat, .quaTu])

        // Row 32: Ất Mùi
        data["Ất Mùi"] = DayStarData(canChi: "Ất Mùi", goodStars: [.nhanChuyen], badStars: [.thienCuong, .tieuHao, .nguyetHu])

        // Row 33: Bính Thân
        data["Bính Thân"] = DayStarData(canChi: "Bính Thân", goodStars: [.nhanChuyen], badStars: [.daiHao, .nguyetYem])

        // Row 34: Đinh Dậu
        data["Đinh Dậu"] = DayStarData(canChi: "Đinh Dậu", goodStars: [], badStars: [.hoangVu, .nguHu, .lySao])

        // Row 35: Mậu Tuất
        data["Mậu Tuất"] = DayStarData(canChi: "Mậu Tuất", goodStars: [], badStars: [.cuuKhong, .quyKhoc, .lySao])

        // Row 36: Kỷ Hợi
        data["Kỷ Hợi"] = DayStarData(canChi: "Kỷ Hợi", goodStars: [], badStars: [.hoaTinh, .thuTu])

        // Row 37: Canh Tý
        data["Canh Tý"] = DayStarData(canChi: "Canh Tý", goodStars: [.satCong], badStars: [.hoangSa, .khongPhong])

        // Row 38: Tân Sửu
        data["Tân Sửu"] = DayStarData(canChi: "Tân Sửu", goodStars: [.satCong], badStars: [.tuThoiCoQua, .tieuHongSa, .diaPha, .hoangVu, .nguHu, .huyenVu, .bangTieu, .cuuThoQuy, .lySao])

        // Row 39: Nhâm Dần
        data["Nhâm Dần"] = DayStarData(canChi: "Nhâm Dần", goodStars: [.trucLinh], badStars: [.hoaTai, .cuuThoQuy])

        // Row 40: Quý Mão
        data["Quý Mão"] = DayStarData(canChi: "Quý Mão", goodStars: [], badStars: [.nguyetHoa, .cauTran])

        // Row 41: Giáp Thìn
        data["Giáp Thìn"] = DayStarData(canChi: "Giáp Thìn", goodStars: [.satCong], badStars: [.khongPhong, .nguQuy])

        // Row 42: Ất Tỵ
        data["Ất Tỵ"] = DayStarData(canChi: "Ất Tỵ", goodStars: [.nhanChuyen], badStars: [.kiepSat, .hoangVu, .loiCong, .nguHu, .khongPhong])

        // Row 43: Bính Ngọ
        data["Bính Ngọ"] = DayStarData(canChi: "Bính Ngọ", goodStars: [], badStars: [.thienHoa, .thoOn, .phiMaSat, .quaTu])

        // Row 44: Đinh Mùi
        data["Đinh Mùi"] = DayStarData(canChi: "Đinh Mùi", goodStars: [], badStars: [.thienCuong, .tieuHao, .nguyetHu])

        // Row 45: Mậu Thân
        data["Mậu Thân"] = DayStarData(canChi: "Mậu Thân", goodStars: [], badStars: [.daiHao, .nguyetYem, .hoaTinh, .lySao])

        // Row 46: Kỷ Dậu
        data["Kỷ Dậu"] = DayStarData(canChi: "Kỷ Dậu", goodStars: [], badStars: [.hoangVu, .nguHu, .lySao, .cuuThoQuy])

        // Row 47: Canh Tuất
        data["Canh Tuất"] = DayStarData(canChi: "Canh Tuất", goodStars: [.thienAn, .satCong], badStars: [.cuuKhong, .quyKhoc, .cuuThoQuy])

        // Row 48: Tân Hợi
        data["Tân Hợi"] = DayStarData(canChi: "Tân Hợi", goodStars: [.thienAn, .trucLinh], badStars: [.thuTu])

        // Row 49: Nhâm Tý
        data["Nhâm Tý"] = DayStarData(canChi: "Nhâm Tý", goodStars: [.thienThuy], badStars: [.hoangSa, .khongPhong])

        // Row 50: Quý Sửu
        data["Quý Sửu"] = DayStarData(canChi: "Quý Sửu", goodStars: [.thienAn], badStars: [.tuThoiCoQua, .tieuHongSa, .diaPha, .hoangVu, .nguHu, .huyenVu, .bangTieu])

        // Row 51: Giáp Dần
        data["Giáp Dần"] = DayStarData(canChi: "Giáp Dần", goodStars: [.nhanChuyen], badStars: [.hoaTai])

        // Row 52: Ất Mão
        data["Ất Mão"] = DayStarData(canChi: "Ất Mão", goodStars: [], badStars: [.nguyetHoa, .cauTran])

        // Row 53: Bính Thìn
        data["Bính Thìn"] = DayStarData(canChi: "Bính Thìn", goodStars: [], badStars: [.thoOn, .nguQuy, .khongPhong])

        // Row 54: Đinh Tỵ
        data["Đinh Tỵ"] = DayStarData(canChi: "Đinh Tỵ", goodStars: [], badStars: [.kiepSat, .hoangVu, .loiCong, .nguHu, .khongPhong, .hoaTinh])

        // Row 55: Mậu Ngọ
        data["Mậu Ngọ"] = DayStarData(canChi: "Mậu Ngọ", goodStars: [.ngoHop], badStars: [.thienHoa, .thoOn, .phiMaSat, .quaTu])

        // Row 56: Kỷ Mùi
        data["Kỷ Mùi"] = DayStarData(canChi: "Kỷ Mùi", goodStars: [.ngoHop, .satCong], badStars: [.thienCuong, .tieuHao, .nguyetHu])

        // Row 57: Canh Thân
        data["Canh Thân"] = DayStarData(canChi: "Canh Thân", goodStars: [.trucLinh], badStars: [.daiHao, .nguyetYem])

        // Row 58: Tân Dậu
        data["Tân Dậu"] = DayStarData(canChi: "Tân Dậu", goodStars: [.ngoHop], badStars: [.hoangVu, .nguHu, .lySao])

        // Row 59: Nhâm Tuất
        data["Nhâm Tuất"] = DayStarData(canChi: "Nhâm Tuất", goodStars: [], badStars: [.cuuKhong, .quyKhoc, .lySao])

        // Row 60: Quý Hợi
        data["Quý Hợi"] = DayStarData(canChi: "Quý Hợi", goodStars: [.ngoHop, .nhanChuyen], badStars: [.thuTu, .hoaTinh])

        return data
    }

    static var dataCompleteness: (completed: Int, total: Int) {
        let populated = data.dayData.values.filter(\.hasAnyStars).count
        return (populated, 60)
    }

    static func printDataStatus() {
        let status = dataCompleteness
        let percentage = Double(status.completed) / Double(status.total) * 100.0
        print("Month 3 Star Data: \(status.completed)/\(status.total) entries (\(String(format: \"%.1f\", percentage))%)")
    }
}
