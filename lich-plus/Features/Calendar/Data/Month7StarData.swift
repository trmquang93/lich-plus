//
//  Month7StarData.swift
//  lich-plus
//
//  Month 7 Star Data from Lịch Vạn Niên 2005-2009, Pages 140-145
//
//  COMPLETE DATA: All 60 Can-Chi combinations extracted from book
//  Source: Lịch Vạn Niên 2005-2009, Tháng 7 âm lịch, Pages 140-145
//

import Foundation

/// Month 7 (Tháng 7 âm lịch) star data
/// Source: Lịch Vạn Niên 2005-2009, Pages 140-145
struct Month7StarData {

    static let data = MonthStarData(month: 7, dayData: createDayData())

    private static func createDayData() -> [String: DayStarData] {
        var data: [String: DayStarData] = [:]

        // MARK: - Complete Month 7 Data (All 60 Can-Chi Combinations)
        // Extracted from book pages 140-145, columns B (Sao xấu) and C (Sao tốt)

        // Row 1: Giáp Tý
        data["Giáp Tý"] = DayStarData(canChi: "Giáp Tý", goodStars: [.thienAn], badStars: [.daiHao])

        // Row 2: Ất Sửu
        data["Ất Sửu"] = DayStarData(canChi: "Ất Sửu", goodStars: [.thienAn], badStars: [.thuTu, .nguQuy, .hoaTinh])

        // Row 3: Bính Dần
        data["Bính Dần"] = DayStarData(canChi: "Bính Dần", goodStars: [.thienAn], badStars: [.khongPhong])

        // Row 4: Đinh Mão
        data["Đinh Mão"] = DayStarData(canChi: "Đinh Mão", goodStars: [.thienAn, .satCong], badStars: [.hoangVu, .nguHu])

        // Row 5: Mậu Thìn
        data["Mậu Thìn"] = DayStarData(canChi: "Mậu Thìn", goodStars: [.thienAn, .trucLinh], badStars: [.hoaTai, .nguyetYem, .lySao])

        // Row 6: Kỷ Tỵ
        data["Kỷ Tỵ"] = DayStarData(canChi: "Kỷ Tỵ", goodStars: [], badStars: [.tieuHongSa, .kiepSat, .diaPha, .loiCong, .lySao])

        // Row 7: Canh Ngọ
        data["Canh Ngọ"] = DayStarData(canChi: "Canh Ngọ", goodStars: [], badStars: [.thienHoa, .hoangSa, .phiMaSat])

        // Row 8: Tân Mùi
        data["Tân Mùi"] = DayStarData(canChi: "Tân Mùi", goodStars: [.nhanChuyen], badStars: [.hoangVu, .nguyetHu, .tuThoiCoQua])

        // Row 9: Nhâm Thân
        data["Nhâm Thân"] = DayStarData(canChi: "Nhâm Thân", goodStars: [.thienAn], badStars: [])

        // Row 10: Quý Dậu
        data["Quý Dậu"] = DayStarData(canChi: "Quý Dậu", goodStars: [], badStars: [.huyenVu])

        // Row 11: Giáp Tuất
        data["Giáp Tuất"] = DayStarData(canChi: "Giáp Tuất", goodStars: [], badStars: [.thoOn, .quaTu, .lySao, .quyKhoc, .hoaTinh])

        // Row 12: Ất Hợi
        data["Ất Hợi"] = DayStarData(canChi: "Ất Hợi", goodStars: [], badStars: [.thienCuong, .tieuHao, .hoangVu, .nguyetHoa, .bangTieu, .cauTran, .nguHu])

        // Row 13: Bính Tý
        data["Bính Tý"] = DayStarData(canChi: "Bính Tý", goodStars: [], badStars: [.daiHao])

        // Row 14: Đinh Sửu
        data["Đinh Sửu"] = DayStarData(canChi: "Đinh Sửu", goodStars: [.trucLinh], badStars: [.thuTu, .nguQuy, .cuuThoQuy])

        // Row 15: Mậu Dần
        data["Mậu Dần"] = DayStarData(canChi: "Mậu Dần", goodStars: [.thienThuy], badStars: [.khongPhong, .lySao])

        // Row 16: Kỷ Mão
        data["Kỷ Mão"] = DayStarData(canChi: "Kỷ Mão", goodStars: [.thienThuy, .thienAn], badStars: [.hoangVu, .nguHu])

        // Row 17: Canh Thìn
        data["Canh Thìn"] = DayStarData(canChi: "Canh Thìn", goodStars: [.thienAn, .nhanChuyen], badStars: [.hoaTai, .nguyetYem])

        // Row 18: Tân Tỵ
        data["Tân Tỵ"] = DayStarData(canChi: "Tân Tỵ", goodStars: [.thienThuy, .thienAn], badStars: [.tieuHongSa, .kiepSat, .diaPha, .loiCong, .lySao])

        // Row 19: Nhâm Ngọ
        data["Nhâm Ngọ"] = DayStarData(canChi: "Nhâm Ngọ", goodStars: [.thienAn], badStars: [.thienHoa, .hoangSa, .phiMaSat])

        // Row 20: Quý Mùi
        data["Quý Mùi"] = DayStarData(canChi: "Quý Mùi", goodStars: [.thienAn], badStars: [.hoangVu, .nguyetHu, .nguHu, .tuThoiCoQua, .hoaTinh])

        // Row 21: Giáp Thân
        // NOTE: Book lists only stars outside current enum (no B/C enum mapping)
        data["Giáp Thân"] = DayStarData(canChi: "Giáp Thân", goodStars: [], badStars: [])

        // Row 22: Ất Dậu
        data["Ất Dậu"] = DayStarData(canChi: "Ất Dậu", goodStars: [.satCong], badStars: [.thoOn, .quaTu, .lySao, .quyKhoc, .huyenVu, .cuuThoQuy])

        // Row 23: Bính Tuất
        data["Bính Tuất"] = DayStarData(canChi: "Bính Tuất", goodStars: [.trucLinh], badStars: [.thoOn, .quaTu, .lySao, .quyKhoc])

        // Row 24: Đinh Hợi
        data["Đinh Hợi"] = DayStarData(canChi: "Đinh Hợi", goodStars: [], badStars: [.thienCuong, .tieuHao, .hoangVu, .nguyetHoa, .bangTieu, .cauTran, .nguHu])

        // Row 25: Mậu Tý
        data["Mậu Tý"] = DayStarData(canChi: "Mậu Tý", goodStars: [], badStars: [.daiHao, .lySao])

        // Row 26: Kỷ Sửu
        data["Kỷ Sửu"] = DayStarData(canChi: "Kỷ Sửu", goodStars: [], badStars: [.thuTu, .nguQuy, .lySao])

        // Row 27: Canh Dần
        data["Canh Dần"] = DayStarData(canChi: "Canh Dần", goodStars: [.thienThuy], badStars: [.khongPhong])

        // Row 28: Tân Mão
        data["Tân Mão"] = DayStarData(canChi: "Tân Mão", goodStars: [], badStars: [.hoangVu, .nguHu, .lySao])

        // Row 29: Nhâm Thìn
        data["Nhâm Thìn"] = DayStarData(canChi: "Nhâm Thìn", goodStars: [], badStars: [.hoaTai, .nguyetYem])

        // Row 30: Quý Tỵ
        data["Quý Tỵ"] = DayStarData(canChi: "Quý Tỵ", goodStars: [], badStars: [.tieuHongSa, .kiepSat, .diaPha, .loiCong, .lySao, .cuuThoQuy])

        // Row 31: Giáp Ngọ
        data["Giáp Ngọ"] = DayStarData(canChi: "Giáp Ngọ", goodStars: [.satCong], badStars: [.cuuThoQuy, .thienHoa, .hoangSa, .phiMaSat])

        // Row 32: Ất Mùi
        data["Ất Mùi"] = DayStarData(canChi: "Ất Mùi", goodStars: [.trucLinh], badStars: [.hoangVu, .nguyetHu, .nguHu, .tuThoiCoQua])

        // Row 33: Bính Thân
        // NOTE: Book lists only stars outside current enum (no B/C enum mapping)
        data["Bính Thân"] = DayStarData(canChi: "Bính Thân", goodStars: [], badStars: [])

        // Row 34: Đinh Dậu
        data["Đinh Dậu"] = DayStarData(canChi: "Đinh Dậu", goodStars: [], badStars: [.huyenVu])

        // Row 35: Mậu Tuất
        data["Mậu Tuất"] = DayStarData(canChi: "Mậu Tuất", goodStars: [.nhanChuyen], badStars: [.thoOn, .quaTu, .lySao, .quyKhoc])

        // Row 36: Kỷ Hợi
        data["Kỷ Hợi"] = DayStarData(canChi: "Kỷ Hợi", goodStars: [], badStars: [.thienCuong, .tieuHao, .hoangVu, .nguyetHoa, .bangTieu, .cauTran, .nguHu])

        // Row 37: Canh Tý
        data["Canh Tý"] = DayStarData(canChi: "Canh Tý", goodStars: [], badStars: [.daiHao])

        // Row 38: Tân Sửu
        data["Tân Sửu"] = DayStarData(canChi: "Tân Sửu", goodStars: [], badStars: [.thuTu, .nguQuy, .cuuThoQuy, .hoaTinh])

        // Row 39: Nhâm Dần
        data["Nhâm Dần"] = DayStarData(canChi: "Nhâm Dần", goodStars: [], badStars: [.khongPhong, .cuuThoQuy])

        // Row 40: Quý Mão
        data["Quý Mão"] = DayStarData(canChi: "Quý Mão", goodStars: [.satCong], badStars: [.hoangVu, .nguHu])

        // Row 41: Giáp Thìn
        data["Giáp Thìn"] = DayStarData(canChi: "Giáp Thìn", goodStars: [.trucLinh], badStars: [.hoaTai, .nguyetYem])

        // Row 42: Ất Tỵ
        data["Ất Tỵ"] = DayStarData(canChi: "Ất Tỵ", goodStars: [], badStars: [.tieuHongSa, .kiepSat, .diaPha, .loiCong])

        // Row 43: Bính Ngọ
        data["Bính Ngọ"] = DayStarData(canChi: "Bính Ngọ", goodStars: [], badStars: [.thienHoa, .hoangSa, .phiMaSat])

        // Row 44: Đinh Mùi
        data["Đinh Mùi"] = DayStarData(canChi: "Đinh Mùi", goodStars: [.nhanChuyen], badStars: [.hoangVu, .nguyetHu, .nguHu, .tuThoiCoQua])

        // Row 45: Mậu Thân
        data["Mậu Thân"] = DayStarData(canChi: "Mậu Thân", goodStars: [], badStars: [.lySao])

        // Row 46: Kỷ Dậu
        data["Kỷ Dậu"] = DayStarData(canChi: "Kỷ Dậu", goodStars: [], badStars: [.huyenVu, .lySao, .cuuThoQuy])

        // Row 47: Canh Tuất
        data["Canh Tuất"] = DayStarData(canChi: "Canh Tuất", goodStars: [.thienAn], badStars: [.thoOn, .quaTu, .lySao, .quyKhoc, .cuuThoQuy, .hoaTinh])

        // Row 48: Tân Hợi
        data["Tân Hợi"] = DayStarData(canChi: "Tân Hợi", goodStars: [.thienAn], badStars: [.thienCuong, .tieuHao, .hoangVu, .nguyetHoa, .bangTieu, .cauTran, .nguHu])

        // Row 49: Nhâm Tý
        data["Nhâm Tý"] = DayStarData(canChi: "Nhâm Tý", goodStars: [.satCong], badStars: [.daiHao])

        // Row 50: Quý Sửu
        data["Quý Sửu"] = DayStarData(canChi: "Quý Sửu", goodStars: [.trucLinh], badStars: [.thuTu, .nguQuy])

        // Row 51: Giáp Dần
        data["Giáp Dần"] = DayStarData(canChi: "Giáp Dần", goodStars: [], badStars: [.khongPhong])

        // Row 52: Ất Mão
        data["Ất Mão"] = DayStarData(canChi: "Ất Mão", goodStars: [], badStars: [.hoangVu, .nguHu])

        // Row 53: Bính Thìn
        data["Bính Thìn"] = DayStarData(canChi: "Bính Thìn", goodStars: [.nhanChuyen], badStars: [.hoaTai, .nguyetYem])

        // Row 54: Đinh Tỵ
        data["Đinh Tỵ"] = DayStarData(canChi: "Đinh Tỵ", goodStars: [], badStars: [.tieuHongSa, .kiepSat, .diaPha, .loiCong])

        // Row 55: Mậu Ngọ
        data["Mậu Ngọ"] = DayStarData(canChi: "Mậu Ngọ", goodStars: [.ngoHop], badStars: [.cuuThoQuy, .lySao, .thienHoa, .hoangSa, .phiMaSat])

        // Row 56: Kỷ Mùi
        data["Kỷ Mùi"] = DayStarData(canChi: "Kỷ Mùi", goodStars: [.ngoHop], badStars: [.hoangVu, .nguyetHu, .nguHu, .tuThoiCoQua, .hoaTinh])

        // Row 57: Canh Thân
        data["Canh Thân"] = DayStarData(canChi: "Canh Thân", goodStars: [.satCong, .ngoHop], badStars: [.daiHao, .nguyetYem])

        // Row 58: Tân Dậu
        data["Tân Dậu"] = DayStarData(canChi: "Tân Dậu", goodStars: [.trucLinh], badStars: [.huyenVu])

        // Row 59: Nhâm Tuất
        data["Nhâm Tuất"] = DayStarData(canChi: "Nhâm Tuất", goodStars: [], badStars: [.thoOn, .quaTu, .lySao, .quyKhoc])

        // Row 60: Quý Hợi
        data["Quý Hợi"] = DayStarData(canChi: "Quý Hợi", goodStars: [], badStars: [.thienCuong, .tieuHao, .hoangVu, .nguyetHoa, .bangTieu, .cauTran, .nguHu])

        return data
    }

    static var dataCompleteness: (completed: Int, total: Int) {
        let populated = data.dayData.values.filter(\.hasAnyStars).count
        return (populated, 60)
    }

    static func printDataStatus() {
        let status = dataCompleteness
        let percentage = Double(status.completed) / Double(status.total) * 100.0
        print("Month 7 Star Data: \(status.completed)/\(status.total) entries (\(String(format: "%.1f", percentage))%)")
        print("⚠️ WARNING: 2 row(s) have no enum-mappable stars: Giáp Thân, Bính Thân")
    }
}
