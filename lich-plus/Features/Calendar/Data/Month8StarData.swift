//
//  Month8StarData.swift
//  lich-plus
//
//  Created by AI Assistant on 2025-11-24.
//  Month 8 Star Data from Lịch Vạn Niên 2005-2009, Pages 148-150
//
//  COMPLETE DATA: All 60 Can-Chi combinations extracted from book
//  Source: Lịch Vạn Niên 2005-2009, Tháng 8 âm lịch, Pages 148-150
//

import Foundation

/// Month 8 (Tháng 8 âm lịch) star data
/// Source: Lịch Vạn Niên 2005-2009, Pages 148-150
struct Month8StarData {

    /// Complete star data for Month 8
    static let data = MonthStarData(
        month: 8,
        dayData: createDayData()
    )

    /// Create the day-by-day star mappings
    private static func createDayData() -> [String: DayStarData] {
        var data: [String: DayStarData] = [:]

        // MARK: - Month 8 Data (Pages 148-150)
        // Complete extraction from Lịch Vạn Niên 2005-2009
        // All 60 Can-Chi combinations mapped with verified good and bad stars

        // MARK: Rows 1-10
        // Row 1: Giáp Thân
        data["Giáp Thân"] = DayStarData(canChi: "Giáp Thân", goodStars: [.satCong], badStars: [])
        // Row 2: Ất Dậu
        data["Ất Dậu"] = DayStarData(canChi: "Ất Dậu", goodStars: [], badStars: [.cuuThoQuy, .thienHoa, .hoaTai, .nguyetHoa, .lySao])
        // Row 3: Bính Tuất
        data["Bính Tuất"] = DayStarData(canChi: "Bính Tuất", goodStars: [], badStars: [.hoangVu, .huyenVu, .quaTu, .nguHu])
        // Row 4: Đinh Hợi
        data["Đinh Hợi"] = DayStarData(canChi: "Đinh Hợi", goodStars: [.nhanChuyen], badStars: [.lySao, .tieuHao])
        // Row 5: Mậu Tý
        data["Mậu Tý"] = DayStarData(canChi: "Mậu Tý", goodStars: [], badStars: [.lySao, .daiHao, .cauTran])
        // Row 6: Kỷ Sửu
        data["Kỷ Sửu"] = DayStarData(canChi: "Kỷ Sửu", goodStars: [.thienThuy], badStars: [.kiepSat, .hoangSa, .khongPhong])
        // Row 7: Canh Dần
        data["Canh Dần"] = DayStarData(canChi: "Canh Dần", goodStars: [], badStars: [.hoangVu, .nguyetYem, .phiMaSat, .nguHu])
        // Row 8: Tân Mão
        data["Tân Mão"] = DayStarData(canChi: "Tân Mão", goodStars: [], badStars: [.nguyetHu])
        // Row 9: Nhâm Thìn
        data["Nhâm Thìn"] = DayStarData(canChi: "Nhâm Thìn", goodStars: [.satCong], badStars: [.nguQuy])
        // Row 10: Quý Tỵ
        data["Quý Tỵ"] = DayStarData(canChi: "Quý Tỵ", goodStars: [.trucLinh], badStars: [.cuuThoQuy, .thienHoa, .khongPhong, .bangTieu])

        // MARK: Rows 11-20
        // Row 11: Giáp Ngọ
        data["Giáp Ngọ"] = DayStarData(canChi: "Giáp Ngọ", goodStars: [], badStars: [.hoangVu, .nguHu, .tuThoiCoQua])
        // Row 12: Ất Mùi
        data["Ất Mùi"] = DayStarData(canChi: "Ất Mùi", goodStars: [.satCong], badStars: [.loiCong])
        // Row 13: Bính Thân
        data["Bính Thân"] = DayStarData(canChi: "Bính Thân", goodStars: [.nhanChuyen], badStars: [.lySao, .thienHoa, .hoaTai, .nguyetHoa, .quyKhoc])
        // Row 14: Đinh Dậu
        data["Đinh Dậu"] = DayStarData(canChi: "Đinh Dậu", goodStars: [], badStars: [.thoOn, .hoangVu, .huyenVu, .quaTu, .nguHu])
        // Row 15: Mậu Tuất
        data["Mậu Tuất"] = DayStarData(canChi: "Mậu Tuất", goodStars: [], badStars: [.tieuHao])
        // Row 16: Kỷ Hợi
        data["Kỷ Hợi"] = DayStarData(canChi: "Kỷ Hợi", goodStars: [], badStars: [.daiHao, .cauTran])
        // Row 17: Canh Tý
        data["Canh Tý"] = DayStarData(canChi: "Canh Tý", goodStars: [.satCong], badStars: [.kiepSat, .hoangSa, .khongPhong])
        // Row 18: Tân Sửu
        data["Tân Sửu"] = DayStarData(canChi: "Tân Sửu", goodStars: [], badStars: [.hoangVu, .nguyetYem, .phiMaSat, .nguHu])
        // Row 19: Nhâm Dần
        data["Nhâm Dần"] = DayStarData(canChi: "Nhâm Dần", goodStars: [], badStars: [.nguyetHu])
        // Row 20: Quý Mão
        data["Quý Mão"] = DayStarData(canChi: "Quý Mão", goodStars: [], badStars: [.nguQuy])

        // MARK: Rows 21-30
        // Row 21: Giáp Thìn
        data["Giáp Thìn"] = DayStarData(canChi: "Giáp Thìn", goodStars: [.satCong], badStars: [])
        // Row 22: Ất Tỵ
        data["Ất Tỵ"] = DayStarData(canChi: "Ất Tỵ", goodStars: [], badStars: [.cuuThoQuy, .thoOn, .hoangVu, .nguHu])
        // Row 23: Bính Ngọ
        data["Bính Ngọ"] = DayStarData(canChi: "Bính Ngọ", goodStars: [], badStars: [.lySao, .tieuHao])
        // Row 24: Đinh Mùi
        data["Đinh Mùi"] = DayStarData(canChi: "Đinh Mùi", goodStars: [.nhanChuyen], badStars: [.daiHao, .cauTran])
        // Row 25: Mậu Thân
        data["Mậu Thân"] = DayStarData(canChi: "Mậu Thân", goodStars: [], badStars: [.hoangSa, .khongPhong, .kiepSat])
        // Row 26: Kỷ Dậu
        data["Kỷ Dậu"] = DayStarData(canChi: "Kỷ Dậu", goodStars: [.satCong], badStars: [.hoangVu, .nguyetYem, .phiMaSat, .nguHu])
        // Row 27: Canh Tuất
        data["Canh Tuất"] = DayStarData(canChi: "Canh Tuất", goodStars: [.thienThuy], badStars: [.nguyetHu])
        // Row 28: Tân Hợi
        data["Tân Hợi"] = DayStarData(canChi: "Tân Hợi", goodStars: [], badStars: [.nguQuy])
        // Row 29: Nhâm Tý
        data["Nhâm Tý"] = DayStarData(canChi: "Nhâm Tý", goodStars: [.satCong], badStars: [])
        // Row 30: Quý Sửu
        data["Quý Sửu"] = DayStarData(canChi: "Quý Sửu", goodStars: [.trucLinh], badStars: [.cuuThoQuy, .thoOn, .khongPhong, .bangTieu])

        // MARK: Rows 31-40
        // Row 31: Giáp Dần
        data["Giáp Dần"] = DayStarData(canChi: "Giáp Dần", goodStars: [], badStars: [.hoangVu, .nguHu, .tuThoiCoQua])
        // Row 32: Ất Mão
        data["Ất Mão"] = DayStarData(canChi: "Ất Mão", goodStars: [.satCong], badStars: [.loiCong])
        // Row 33: Bính Thìn
        data["Bính Thìn"] = DayStarData(canChi: "Bính Thìn", goodStars: [.nhanChuyen], badStars: [.lySao, .thienHoa, .hoaTai, .nguyetHoa, .quyKhoc])
        // Row 34: Đinh Tỵ
        data["Đinh Tỵ"] = DayStarData(canChi: "Đinh Tỵ", goodStars: [], badStars: [.thoOn, .hoangVu, .huyenVu, .quaTu, .nguHu])
        // Row 35: Mậu Ngọ
        data["Mậu Ngọ"] = DayStarData(canChi: "Mậu Ngọ", goodStars: [], badStars: [.lySao, .tieuHao])
        // Row 36: Kỷ Mùi
        data["Kỷ Mùi"] = DayStarData(canChi: "Kỷ Mùi", goodStars: [], badStars: [.daiHao, .cauTran])
        // Row 37: Canh Thân
        data["Canh Thân"] = DayStarData(canChi: "Canh Thân", goodStars: [.satCong], badStars: [.kiepSat, .hoangSa, .khongPhong])
        // Row 38: Tân Dậu
        data["Tân Dậu"] = DayStarData(canChi: "Tân Dậu", goodStars: [], badStars: [.hoangVu, .nguyetYem, .phiMaSat, .nguHu])
        // Row 39: Nhâm Tuất
        data["Nhâm Tuất"] = DayStarData(canChi: "Nhâm Tuất", goodStars: [.thienAn], badStars: [.nguyetHu])
        // Row 40: Quý Hợi
        data["Quý Hợi"] = DayStarData(canChi: "Quý Hợi", goodStars: [], badStars: [.nguQuy])

        // MARK: Rows 41-50
        // Row 41: Giáp Tý
        data["Giáp Tý"] = DayStarData(canChi: "Giáp Tý", goodStars: [.satCong], badStars: [])
        // Row 42: Ất Sửu
        data["Ất Sửu"] = DayStarData(canChi: "Ất Sửu", goodStars: [.trucLinh, .ngoHop], badStars: [.cuuThoQuy, .thoOn, .bangTieu])
        // Row 43: Bính Dần
        data["Bính Dần"] = DayStarData(canChi: "Bính Dần", goodStars: [.nhanChuyen], badStars: [.hoangVu, .nguHu, .tuThoiCoQua])
        // Row 44: Đinh Mão
        data["Đinh Mào"] = DayStarData(canChi: "Đinh Mào", goodStars: [], badStars: [.loiCong])
        // Row 45: Mậu Thìn
        data["Mậu Thìn"] = DayStarData(canChi: "Mậu Thìn", goodStars: [.ngoHop], badStars: [.lySao, .thienHoa, .hoaTai, .nguyetHoa, .quyKhoc])
        // Row 46: Kỷ Tỵ
        data["Kỷ Tỵ"] = DayStarData(canChi: "Kỷ Tỵ", goodStars: [.satCong], badStars: [.lySao, .thoOn, .hoangVu, .huyenVu, .quaTu, .nguHu])
        // Row 47: Canh Ngọ
        data["Canh Ngọ"] = DayStarData(canChi: "Canh Ngọ", goodStars: [.thienAn], badStars: [.tieuHao])
        // Row 48: Tân Mùi
        data["Tân Mùi"] = DayStarData(canChi: "Tân Mùi", goodStars: [.satCong], badStars: [.daiHao, .cauTran])
        // Row 49: Nhâm Thân
        data["Nhâm Thân"] = DayStarData(canChi: "Nhâm Thân", goodStars: [.ngoHop], badStars: [.kiepSat, .hoangSa, .khongPhong])
        // Row 50: Quý Dậu
        data["Quý Dậu"] = DayStarData(canChi: "Quý Dậu", goodStars: [.trucLinh, .ngoHop], badStars: [.hoangVu, .nguyetYem, .phiMaSat, .nguHu])

        // MARK: Rows 51-60
        // Row 51: Giáp Tuất
        data["Giáp Tuất"] = DayStarData(canChi: "Giáp Tuất", goodStars: [.thienAn], badStars: [.nguyetHu])
        // Row 52: Ất Hợi
        data["Ất Hợi"] = DayStarData(canChi: "Ất Hợi", goodStars: [.trucLinh, .ngoHop], badStars: [.nguQuy])
        // Row 53: Bính Tý
        data["Bính Tý"] = DayStarData(canChi: "Bính Tý", goodStars: [.satCong], badStars: [.lySao])
        // Row 54: Đinh Sửu
        data["Đinh Sửu"] = DayStarData(canChi: "Đinh Sửu", goodStars: [.trucLinh], badStars: [.cuuThoQuy, .thoOn, .bangTieu])
        // Row 55: Mậu Dần
        data["Mậu Dần"] = DayStarData(canChi: "Mậu Dần", goodStars: [.thienThuy, .nhanChuyen], badStars: [.hoangVu, .nguHu, .tuThoiCoQua])
        // Row 56: Kỷ Mão
        data["Kỷ Mào"] = DayStarData(canChi: "Kỷ Mào", goodStars: [.satCong], badStars: [.lySao, .loiCong])
        // Row 57: Canh Thìn
        data["Canh Thìn"] = DayStarData(canChi: "Canh Thìn", goodStars: [.thienAn], badStars: [.thienHoa, .hoaTai, .nguyetHoa, .quyKhoc])
        // Row 58: Tân Tỵ
        data["Tân Tỵ"] = DayStarData(canChi: "Tân Tỵ", goodStars: [.satCong], badStars: [.thoOn, .hoangVu, .huyenVu, .quaTu, .nguHu])
        // Row 59: Nhâm Ngọ
        data["Nhâm Ngọ"] = DayStarData(canChi: "Nhâm Ngọ", goodStars: [.thienAn, .ngoHop], badStars: [.tieuHao])
        // Row 60: Quý Mùi
        data["Quý Mùi"] = DayStarData(canChi: "Quý Mùi", goodStars: [.ngoHop], badStars: [.daiHao, .cauTran])

        return data
    }
}

// MARK: - Data Completeness Check

extension Month8StarData {
    static var dataCompleteness: (completed: Int, total: Int) {
        let total = 60
        let completed = data.dayData.count
        return (completed, total)
    }

    static func printDataStatus() {
        let status = dataCompleteness
        let percentage = Double(status.completed) / Double(status.total) * 100.0
        print("Month 8 Star Data: \(status.completed)/\(status.total) entries (\(String(format: "%.1f", percentage))%)")

        if status.completed < status.total {
            print("WARNING: Incomplete data - need \(status.total - status.completed) more entries")
        } else {
            print("Complete data for all 60 Can-Chi combinations")
        }
    }
}
